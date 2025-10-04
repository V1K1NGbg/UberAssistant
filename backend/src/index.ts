import express, { Request, Response } from 'express';
import http from 'http';
import WebSocket from 'ws';
import StorageManager, { Customer, CustomerRequest, Driver, DriverStatus } from './storage';

const app = express();
const PORT = 3000;
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

interface WebSocketMessage {
    type: string;
    driverId: string;
    location?: { lat: number; lon: number; };
    restTime?: number;
    request?: CustomerRequest;
    customerId?: string;
    response?: 'accept' | 'deny';
}

// Initialize storage manager
const storageManager = new StorageManager();

// Store pending requests waiting for driver responses
const pendingRequests = new Map<string, {
    request: CustomerRequest;
    triedDrivers: string[];
    sortedDrivers: Array<{ driverId: string; distance: number }>;
    currentDriverId?: string;
    timeoutId?: NodeJS.Timeout;
}>();

// Helper function to calculate distance between two points (Haversine formula)
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Earth's radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = 
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

// Function to get all active drivers sorted by distance
function getDriversSortedByDistance(request: CustomerRequest): Array<{ driverId: string; distance: number }> {
    const driverStatuses = storageManager.getAllDriverStatuses();
    const activeDrivers = driverStatuses.filter(status => 
        storageManager.getActiveConnection(status.driver_id)
    );

    const driversWithDistance = activeDrivers.map(driver => ({
        driverId: driver.driver_id,
        distance: calculateDistance(
            request.from_location.lat,
            request.from_location.lon,
            driver.location.lat,
            driver.location.lon
        )
    }));

    return driversWithDistance.sort((a, b) => a.distance - b.distance);
}

// Placeholder function for getting advice on whether to accept the request
// TODO: Implement the actual advice logic
function getAdviceForRequest(request: CustomerRequest, driver: DriverStatus): string {
    if (request.price/request.duration_mins > 0.5) {
        return 'yes';
    } else {
        return 'no';
    }
}

// Function to send request to driver via WebSocket
function sendRequestToDriver(driverId: string, request: CustomerRequest): boolean {
    const ws = storageManager.getActiveConnection(driverId);
    if (!ws) {
        return false;
    }

    try {
        ws.send(JSON.stringify({
            type: 'ride_request',
            driverId: driverId,
            request: request,
        }));
        return true;
    } catch (error) {
        console.error(`Error sending request to driver ${driverId}:`, error);
        return false;
    }
}

// Function to try next driver in the list
function tryNextDriver(customerId: string): void {
    const pending = pendingRequests.get(customerId);
    if (!pending) {
        console.log(`No pending request found for customer ${customerId}`);
        return;
    }

    // Clear any existing timeout
    if (pending.timeoutId) {
        clearTimeout(pending.timeoutId);
        pending.timeoutId = undefined;
    }

    const { request, triedDrivers, sortedDrivers } = pending;

    // Find the next driver who hasn't been tried yet
    const nextDriver = sortedDrivers.find(d => !triedDrivers.includes(d.driverId));

    if (!nextDriver) {
        console.log(`No more available drivers for customer ${customerId}`);
        pendingRequests.delete(customerId);
        return;
    }

    // Get driver info
    const driverStatus = storageManager.getDriverStatus(nextDriver.driverId);
    if (!driverStatus || driverStatus.restTime < 0) {
        console.log(`Driver ${nextDriver.driverId} unavailable, trying next driver`);
        triedDrivers.push(nextDriver.driverId);
        tryNextDriver(customerId);
        return;
    }

    // Get advice for this driver
    request.advice = getAdviceForRequest(request, driverStatus);

    // Send request to driver
    const sent = sendRequestToDriver(nextDriver.driverId, request);
    
    if (sent) {
        triedDrivers.push(nextDriver.driverId);
        pending.currentDriverId = nextDriver.driverId;
        
        // Set a 25-second timeout for driver response
        pending.timeoutId = setTimeout(() => {
            console.log(`Driver ${nextDriver.driverId} did not respond within 25 seconds. Moving to next driver...`);
            tryNextDriver(customerId);
        }, 25000); // 25 seconds
        
        console.log(`Sent request from customer ${customerId} to driver ${nextDriver.driverId} (distance: ${nextDriver.distance.toFixed(2)}km, advice: ${request.advice})`);
    } else {
        console.log(`Failed to send request to driver ${nextDriver.driverId}, trying next driver`);
        triedDrivers.push(nextDriver.driverId);
        tryNextDriver(customerId);
    }
}


// Middleware
app.use(express.json());

// Routes
// Health check endpoint
app.get('/', (req: Request, res: Response) => {
    res.json({ message: 'API is running!' });
});

// Create a new customer request
app.post('/api/customer_request', (req: Request, res: Response) => {
    const customerRequest: CustomerRequest = {
        customer_id: req.body.customer_id,
        from_location: {
            lat: req.body.from_location.lat,
            lon: req.body.from_location.lon,
            address: req.body.from_location.address
        },
        to_location: {
            lat: req.body.to_location.lat,
            lon: req.body.to_location.lon,
            address: req.body.to_location.address
        },
        price: req.body.price * 0.8,
        duration_mins: req.body.duration_mins
    };

    storageManager.addCustomerRequest(customerRequest);

    // Get all drivers sorted by distance
    const sortedDrivers = getDriversSortedByDistance(customerRequest);

    // Store the pending request
    pendingRequests.set(customerRequest.customer_id, {
        request: customerRequest,
        triedDrivers: [],
        sortedDrivers: sortedDrivers
    });

    // Try the first (closest) driver
    tryNextDriver(customerRequest.customer_id);

    res.status(201).json({
        success: true,
        data: customerRequest,
        message: `Request sent to closest driver`
    });
});

// Get all active drivers
app.get('/api/drivers', (req: Request, res: Response) => {
    const drivers = storageManager.getAllDrivers();

    res.json({
        success: true,
        count: drivers.length,
        data: drivers
    });
});

// Get all active customers
app.get('/api/customers', (req: Request, res: Response) => {
    const customers = storageManager.getAllCustomers();

    res.json({
        success: true,
        count: customers.length,
        data: customers
    });
});

// WebSocket connection handler
wss.on('connection', (ws: WebSocket) => {
    let driverId: string;

    console.log('Driver connected');

    ws.on('message', (message: WebSocket.Data) => {
        try {
            const data: WebSocketMessage = JSON.parse(message.toString());

            // Handle driver registration
            if (data.type === 'register' && data.driverId) {
                driverId = data.driverId;
                storageManager.setActiveConnection(driverId, ws);
                console.log(`Driver ${driverId} registered`);
                if (data.location && data.restTime !== undefined) {
                    storageManager.setDriverStatus(driverId, {
                        driver_id: driverId,
                        location: data.location,
                        restTime: data.restTime
                    });
                    console.log(`Driver ${driverId} location/status updated`);
                } else {
                    console.log(`Driver ${driverId} location/status update failed`);
                    console.log(data)
                }
            }

            // Handle driver deregistration
            if (data.type === 'deregister' && data.driverId) {
                driverId = data.driverId;
                storageManager.deleteActiveConnection(driverId);
                console.log(`Driver ${driverId} deregistered`);
            }

            // Save/update driver location and rest time
            if (data.type === 'update' && driverId) {
                if (data.location && data.restTime !== undefined) {
                    storageManager.setDriverStatus(driverId, {
                        driver_id: driverId,
                        location: data.location,
                        restTime: data.restTime
                    });
                    console.log(`Driver ${driverId} location/status updated`);
                } else {
                    console.log(`Driver ${driverId} location/status update failed`);
                    console.log(data)
                }
            }

            // Handle driver response to ride request
            if (data.type === 'response' && driverId && data.response) {
                if (data.response === 'deny' && data.customerId) {
                    const customerId = data.customerId
                    const pending = pendingRequests.get(customerId);
                    
                    // Clear the timeout since we got a response
                    if (pending?.timeoutId) {
                        clearTimeout(pending.timeoutId);
                        pending.timeoutId = undefined;
                    }
                    
                    console.log(`Driver ${driverId} denied request from customer ${customerId}. Trying next driver...`);
                    
                    // Try the next closest driver
                    tryNextDriver(customerId);
                } else if (data.response === 'accept' && data.customerId) {
                    const customerId = data.customerId
                    const pending = pendingRequests.get(customerId);
                    
                    // Clear the timeout since we got a response
                    if (pending?.timeoutId) {
                        clearTimeout(pending.timeoutId);
                        pending.timeoutId = undefined;
                    }
                    
                    console.log(`Driver ${driverId} accepted request from customer ${customerId}`);
                    
                    // Remove from pending requests
                    pendingRequests.delete(customerId);
                }
                if (data.location && data.restTime !== undefined) {
                    storageManager.setDriverStatus(driverId, {
                        driver_id: driverId,
                        location: data.location,
                        restTime: data.restTime
                    });
                    console.log(`Driver ${driverId} location/status updated`);
                } else {
                    console.log(`Driver ${driverId} location/status update failed`);
                    console.log(data)
                }
            }
        } catch (error) {
            console.error('Error processing WebSocket message:', error);
        }
    });

    ws.on('close', () => {
        if (driverId) {
            storageManager.deleteActiveConnection(driverId);
            console.log(`Driver ${driverId} deregistered and disconnected`);
        } else {
            console.log('Client disconnected');
        }
    });
});

// Graceful shutdown - save data before exit
process.on('SIGINT', () => {
    console.log('\nShutting down gracefully...');
    storageManager.saveAll();
    console.log('Data saved. Exiting.');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\nShutting down gracefully...');
    storageManager.saveAll();
    console.log('Data saved. Exiting.');
    process.exit(0);
});

// Start server with WebSocket support
server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});