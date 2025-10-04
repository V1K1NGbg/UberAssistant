import WebSocket from 'ws';
import fs from 'fs';
import path from 'path';
import http from 'http';
import { getRequests, timeDelay } from './../src/utilities';

const driversCount = 10;

interface Location {
    lat: number;
    lon: number;
}

interface HeatmapEntry {
    hour: number;
    map_id: string;
    region: string;
    metric_type: string;
    hex_id: string;
    lat: number;
    lon: number;
    value: boolean;
}

interface DriverSimulation {
    driverId: string;
    location: Location;
    restTime: number;
    ws: WebSocket | null;
    isBusy: boolean;
}

interface RideRequest {
    customer_id: string;
    from_location: {
        lat: number;
        lon: number;
        address: string;
    };
    to_location: {
        lat: number;
        lon: number;
        address: string;
    };
    price: number;
    duration_mins: number;
}

// Load heatmap data to get random locations
function loadHeatmapData(): Location[] {
    const heatmapPath = path.join(__dirname, '../../data/uber_hackathon_v2_mock_data.xlsx - rides_trips.csv');
    const csvData = fs.readFileSync(heatmapPath, 'utf-8');
    const lines = csvData.split('\n').slice(1); // Skip header
    
    const locations: Location[] = [];
    
    for (const line of lines) {
        if (!line.trim()) continue;
        
        const parts = line.split(',');

        if (parts.length >= 7 && parseInt(parts[3]) === 1) {
            const lat = parseFloat(parts[9]);
            const lon = parseFloat(parts[10]);
            
            if (!isNaN(lat) && !isNaN(lon)) {
                locations.push({ lat, lon });
            }
        }
    }
    
    return locations;
}

// Load sample ride requests
function loadSampleRequests(): RideRequest[] {
    const requests = getRequests();
    return requests.slice(0, 200);
}

// Get a random location from the dataset
function getRandomLocation(locations: Location[]): Location {
    const randomIndex = Math.floor(Math.random() * locations.length);
    return locations[randomIndex];
}

// Create driver simulations
function createDriverSimulations(count: number): DriverSimulation[] {
    const locations = loadHeatmapData();
    console.log(`Loaded ${locations.length} unique locations from heatmap data`);
    
    const drivers: DriverSimulation[] = [];
    
    for (let i = 1; i <= count; i++) {
        const driverId = `D_${200010 + i}`;
        const location = getRandomLocation(locations);
        const restTime = Math.floor(Math.random() * 300) + 60; // Random rest time between 60-360 seconds
        
        drivers.push({
            driverId,
            location,
            restTime,
            ws: null,
            isBusy: false
        });
    }
    
    return drivers;
}

// Register a driver via WebSocket
function registerDriver(driver: DriverSimulation, serverUrl: string): Promise<void> {
    return new Promise((resolve, reject) => {
        const ws = new WebSocket(serverUrl);
        
        ws.on('open', () => {
            console.log(`Driver ${driver.driverId} connecting...`);
            
            // Send registration message
            ws.send(JSON.stringify({
                type: 'register',
                driverId: driver.driverId,
                location: driver.location,
                restTime: driver.restTime
            }));
            
            driver.ws = ws;
            console.log(`✓ Driver ${driver.driverId} registered at location (${driver.location.lat.toFixed(4)}, ${driver.location.lon.toFixed(4)}) with rest time ${driver.restTime}s`);
            
            // Start periodic location and rest time updates every 10 seconds
            setInterval(() => {
                if (driver.ws && driver.ws.readyState === WebSocket.OPEN && !driver.isBusy) {
                    // Increment rest time by 10
                    driver.restTime += 10;
                    
                    // Send update message
                    driver.ws.send(JSON.stringify({
                        type: 'update',
                        driverId: driver.driverId,
                        location: driver.location,
                        restTime: driver.restTime
                    }));
                    
                    console.log(`Driver ${driver.driverId} updated - location: (${driver.location.lat.toFixed(4)}, ${driver.location.lon.toFixed(4)}), rest time: ${driver.restTime}s`);
                }
            }, 10 * timeDelay()); // 10 seconds
            
            resolve();
        });
        
        ws.on('message', (data: WebSocket.Data) => {
            try {
                const message = JSON.parse(data.toString());
                
                if (message.type === 'ride_request') {
                    // Skip if driver is busy
                    if (driver.isBusy) {
                        console.log(`Driver ${driver.driverId} is busy, ignoring ride request`);
                        return;
                    }
                    
                    console.log(`Driver ${driver.driverId} received ride request from customer ${message.request.customer_id}`);
                    console.log(`  Advice: ${message.request.advice || 'N/A'}`);
                    console.log(`  Price: $${message.request.price.toFixed(2)}, Duration: ${message.request.duration_mins} mins`);
                    
                    
                    // if (true) {
                    // if (Math.random() < 0.4) {
                    if ((message.request.advice && message.request.advice.toLowerCase() === 'yes')) {
                        // Accept the request
                        driver.isBusy = true;
                        driver.restTime = -1; // Mark as busy
                        
                        // Send acceptance response
                        ws.send(JSON.stringify({
                            type: 'response',
                            driverId: driver.driverId,
                            customerId: message.request.customer_id,
                            response: 'accept',
                            location: driver.location,
                            restTime: driver.restTime
                        }));
                        
                        console.log(`Driver ${driver.driverId} ✓ accepted the ride request`);
                        
                        const rideDurationMs = message.request.duration_mins * timeDelay();
                        
                        setTimeout(() => {
                            // Update location to destination
                            driver.location = {
                                lat: message.request.to_location.lat,
                                lon: message.request.to_location.lon
                            };
                            
                            // Reset rest time to 0
                            driver.restTime = 0;
                            driver.isBusy = false;
                            
                            // Send update to server
                            if (driver.ws && driver.ws.readyState === WebSocket.OPEN) {
                                driver.ws.send(JSON.stringify({
                                    type: 'update',
                                    driverId: driver.driverId,
                                    location: driver.location,
                                    restTime: driver.restTime
                                }));
                            }
                            
                            console.log(`Driver ${driver.driverId} completed ride - new location: (${driver.location.lat.toFixed(4)}, ${driver.location.lon.toFixed(4)}), rest time reset to 0s`);
                        }, rideDurationMs);
                    } else {
                        // Decline the request
                        ws.send(JSON.stringify({
                            type: 'response',
                            driverId: driver.driverId,
                            customerId: message.request.customer_id,
                            response: 'deny',
                            location: driver.location,
                            restTime: driver.restTime
                        }));
                        
                        console.log(`Driver ${driver.driverId} ✗ denied the ride request`);
                    }
                }
            } catch (error) {
                console.error(`Error processing message for driver ${driver.driverId}:`, error);
            }
        });
        
        ws.on('error', (error) => {
            console.error(`WebSocket error for driver ${driver.driverId}:`, error);
            reject(error);
        });
        
        ws.on('close', () => {
            console.log(`Driver ${driver.driverId} disconnected`);
        });
    });
}

// Send ride requests in timeslots
async function sendRideRequests(requests: RideRequest[], serverPort: number) {
    const TIMESLOTS = 20;
    const REQUESTS_PER_TIMESLOT = driversCount;
    const totalRequests = TIMESLOTS * REQUESTS_PER_TIMESLOT;
    
    console.log(`\n=== Starting to send ${totalRequests} ride requests in ${TIMESLOTS} timeslots (${REQUESTS_PER_TIMESLOT} requests per timeslot) ===\n`);
    
    let requestIndex = 0;
    
    for (let timeslot = 0; timeslot < TIMESLOTS; timeslot++) {
        console.log(`\n--- TIMESLOT ${timeslot + 1}/${TIMESLOTS} ---`);
        
        // Send n requests in this timeslot
        for (let j = 0; j < REQUESTS_PER_TIMESLOT; j++) {
            if (requestIndex >= requests.length) {
                console.log(`  ⚠ Ran out of requests, stopping...`);
                break;
            }
            
            const request = requests[requestIndex];
            
            console.log(`\n[Request ${requestIndex + 1}/${totalRequests}] Sending ride request for customer ${request.customer_id}`);
            console.log(`  From: (${request.from_location.lat.toFixed(4)}, ${request.from_location.lon.toFixed(4)})`);
            console.log(`  To: (${request.to_location.lat.toFixed(4)}, ${request.to_location.lon.toFixed(4)})`);
            console.log(`  Price: $${request.price.toFixed(2)}, Duration: ${request.duration_mins} mins`);
            
            // Prepare the request body
            const postData = JSON.stringify(request);
            
            // Send HTTP POST request
            await new Promise<void>((resolve, reject) => {
                const options = {
                    hostname: 'localhost',
                    port: serverPort,
                    path: '/api/customer_request',
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Content-Length': Buffer.byteLength(postData)
                    }
                };
                
                const req = http.request(options, (res) => {
                    let responseData = '';
                    
                    res.on('data', (chunk) => {
                        responseData += chunk;
                    });
                    
                    res.on('end', () => {
                        if (res.statusCode === 201) {
                            console.log(`  ✓ Request sent successfully to API`);
                            try {
                                const response = JSON.parse(responseData);
                                console.log(`  Server response: ${response.message}`);
                            } catch (e) {
                                // Ignore JSON parse errors
                            }
                        } else {
                            console.log(`  ✗ Request failed with status ${res.statusCode}`);
                        }
                        resolve();
                    });
                });
                
                req.on('error', (error) => {
                    console.error(`  ✗ Error sending request:`, error.message);
                    resolve(); // Continue with next request even if this one fails
                });
                
                req.write(postData);
                req.end();
            });
            
            requestIndex++;
        }
        
        // Wait 20-40 seconds before the next timeslot (except for the last one)
        if (timeslot < TIMESLOTS - 1) {
            const waitTime = 20 + Math.random() * 20; // Random between 20-40 seconds
            console.log(`\n  ⏳ Waiting ${waitTime.toFixed(1)} seconds before next timeslot...`);
            await new Promise(resolve => setTimeout(resolve, waitTime * timeDelay()));
        }
    }
    
    console.log(`\n=== All ${requestIndex} ride requests have been sent ===\n`);
}

// Main function
async function main() {
    const SERVER_URL = 'ws://localhost:3000';
    const SERVER_PORT = 3000;
    const DRIVER_COUNT = driversCount;
    
    console.log('=== Driver Simulation Starting ===\n');
    console.log(`Creating ${DRIVER_COUNT} driver simulations...\n`);
    
    const drivers = createDriverSimulations(DRIVER_COUNT);
    
    console.log('\nRegistering drivers with the server...\n');
    
    // Register all drivers
    for (const driver of drivers) {
        try {
            await registerDriver(driver, SERVER_URL);
            // Small delay between registrations
            await new Promise(resolve => setTimeout(resolve, 500));
        } catch (error) {
            console.error(`Failed to register driver ${driver.driverId}:`, error);
        }
    }
    
    console.log('\n=== All drivers registered successfully ===\n');
    console.log('Waiting 3 seconds before starting ride requests...\n');
    
    // Wait a bit to ensure all drivers are fully registered
    await new Promise(resolve => setTimeout(resolve, 3 * timeDelay()));
    
    // Load and send ride requests
    const requests = loadSampleRequests();
    await sendRideRequests(requests, SERVER_PORT);
    
    // Handle graceful shutdown
    process.on('SIGINT', () => {
        console.log('\n\nShutting down driver simulation...');
        drivers.forEach(driver => {
            if (driver.ws) {
                driver.ws.send(JSON.stringify({
                    type: 'deregister',
                    driverId: driver.driverId
                }));
                driver.ws.close();
            }
        });
        console.log('All drivers disconnected. Goodbye!');
        process.exit(0);
    });
}

// Run the simulation
main().catch(console.error);
