const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;
const FEPORT = 4000;
const AIPORT = 5000;
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Storage file paths
const STORAGE_DIR = path.join(__dirname, 'storage');
const CUSTOMER_REQUESTS_FILE = path.join(STORAGE_DIR, 'customer_requests.json');
const DRIVERS_FILE = path.join(STORAGE_DIR, 'drivers.json');

// Ensure storage directory exists
if (!fs.existsSync(STORAGE_DIR)) {
    fs.mkdirSync(STORAGE_DIR, { recursive: true });
}

// Load data from files
const loadData = () => {
    let customerRequests = [];
    let driversData = {};

    try {
        if (fs.existsSync(CUSTOMER_REQUESTS_FILE)) {
            customerRequests = JSON.parse(fs.readFileSync(CUSTOMER_REQUESTS_FILE, 'utf8'));
        }
    } catch (error) {
        console.error('Error loading customer requests:', error);
    }

    try {
        if (fs.existsSync(DRIVERS_FILE)) {
            driversData = JSON.parse(fs.readFileSync(DRIVERS_FILE, 'utf8'));
        }
    } catch (error) {
        console.error('Error loading drivers:', error);
    }

    return { customerRequests, driversData };
};

// Save data to files
const saveCustomerRequests = () => {
    try {
        fs.writeFileSync(CUSTOMER_REQUESTS_FILE, JSON.stringify(storage.customerRequests, null, 2));
    } catch (error) {
        console.error('Error saving customer requests:', error);
    }
};

const saveDrivers = () => {
    try {
        const driversObj = Object.fromEntries(storage.drivers);
        fs.writeFileSync(DRIVERS_FILE, JSON.stringify(driversObj, null, 2));
    } catch (error) {
        console.error('Error saving drivers:', error);
    }
};

// Initialize storage with loaded data
const { customerRequests, driversData } = loadData();

// Persistent storage
const storage = {
    customerRequests: customerRequests, // Stores all customer requests
    drivers: new Map(Object.entries(driversData)), // Stores driver locations and rest times (key: driverId, value: { location, restTime, lastUpdate })
    activeConnections: new Map() // Stores active WebSocket connections (key: driverId, value: ws) - not persisted
};

console.log(`Loaded ${storage.customerRequests.length} customer requests and ${storage.drivers.size} drivers from storage`);

// Middleware
app.use(express.json());

// Routes
// Health check endpoint
app.get('/', (req, res) => {
    res.json({ message: 'API is running!' });
});

// Get all customer requests
app.get('/api/customer_request', (req, res) => {
    res.json({
        success: true,
        count: storage.customerRequests.length,
        data: storage.customerRequests
    });
});

// Create a new customer request
app.post('/api/customer_request', (req, res) => {
    const customerRequest = {
        id: Date.now().toString(),
        ...req.body,
        createdAt: new Date().toISOString()
    };

    storage.customerRequests.push(customerRequest);
    saveCustomerRequests(); // Persist to disk

    res.status(201).json({
        success: true,
        data: customerRequest
    });
});

// Get all active drivers
app.get('/api/drivers', (req, res) => {
    const drivers = Array.from(storage.drivers.entries()).map(([id, data]) => ({
        id,
        ...data
    }));

    res.json({
        success: true,
        count: drivers.length,
        data: drivers
    });
});

// WebSocket connection handler
wss.on('connection', (ws) => {
    let driverId = null;

    console.log('New WebSocket client connected');

    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);

            // Handle driver registration
            if (data.type === 'register' && data.driverId) {
                driverId = data.driverId;
                storage.activeConnections.set(driverId, ws);
                console.log(`Driver ${driverId} registered`);
            }

            // Save/update driver location and rest time
            if (data.type === 'update' && driverId) {
                storage.drivers.set(driverId, {
                    location: data.location || null,
                    restTime: data.restTime || 0,
                    lastUpdate: new Date().toISOString()
                });
                saveDrivers(); // Persist to disk
                console.log(`Driver ${driverId} location/status updated`);
            }
        } catch (error) {
            console.error('Error processing WebSocket message:', error);
        }
    });

    ws.on('close', () => {
        if (driverId) {
            storage.activeConnections.delete(driverId);
            console.log(`Driver ${driverId} disconnected`);
        } else {
            console.log('Client disconnected');
        }
    });
});

// Periodic task to interact with AI model server
setInterval(() => {
    // TODO: Implement AI model server interaction
    // Periodically save data as a backup
    saveCustomerRequests();
    saveDrivers();
}, 10000);

// Graceful shutdown - save data before exit
process.on('SIGINT', () => {
    console.log('\nShutting down gracefully...');
    saveCustomerRequests();
    saveDrivers();
    console.log('Data saved. Exiting.');
    process.exit(0);
});

process.on('SIGTERM', () => {
    console.log('\nShutting down gracefully...');
    saveCustomerRequests();
    saveDrivers();
    console.log('Data saved. Exiting.');
    process.exit(0);
});

// Start server with WebSocket support
server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});