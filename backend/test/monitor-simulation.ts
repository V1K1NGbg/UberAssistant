import WebSocket from 'ws';
import http from 'http';

interface MonitorMessage {
    type: string;
    driverId?: string;
    customerId?: string;
    location?: { lat: number; lon: number };
    restTime?: number;
    request?: any;
    response?: string;
    timestamp?: number;
}

interface RideRequest {
    customer_id: string;
    from_location: any;
    to_location: any;
    price: number;
    duration_mins: number;
    advice?: string;
}

// ANSI color codes for better visualization
const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    dim: '\x1b[2m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m',
    red: '\x1b[31m',
};

// Track active drivers and their status
const drivers = new Map<string, any>();
let totalRidesCompleted = 0;
let totalRidesInProgress = 0;
let totalDriversAvailable = 0;
let totalEarnings = 0;

// Clear console and move cursor to top
function clearScreen() {
    console.clear();
}

// Draw a simple header
function drawHeader() {
    console.log(colors.bright + colors.cyan + '═'.repeat(80) + colors.reset);
    console.log(colors.bright + '🚗 UBER ASSISTANT - REAL-TIME SIMULATION MONITOR 🚗' + colors.reset);
    console.log(colors.cyan + '═'.repeat(80) + colors.reset);
    console.log();
}

// Draw statistics dashboard
function drawDashboard() {
    console.log(colors.bright + '📊 STATISTICS:' + colors.reset);
    console.log(`  ${colors.magenta}💰 Total Earnings: €${totalEarnings.toFixed(2)}${colors.reset}`);
    console.log(`  ${colors.green}Available Drivers: ${totalDriversAvailable}${colors.reset}`);
    console.log(`  ${colors.yellow}Rides In Progress: ${totalRidesInProgress}${colors.reset}`);
    console.log(`  ${colors.blue}Rides Completed: ${totalRidesCompleted}${colors.reset}`);
    console.log();
}

// Draw driver status table
function drawDriverTable() {
    console.log(colors.bright + '🚕 DRIVER STATUS:' + colors.reset);
    console.log(colors.dim + '─'.repeat(80) + colors.reset);
    console.log(
        colors.bright +
        'Driver ID'.padEnd(15) +
        'Status'.padEnd(15) +
        'Location'.padEnd(25) +
        'Rest Time'.padEnd(15) +
        colors.reset
    );
    console.log(colors.dim + '─'.repeat(80) + colors.reset);
    
    const driverList = Array.from(drivers.values()).sort((a, b) => 
        a.driverId.localeCompare(b.driverId)
    );
    
    for (const driver of driverList) {
        const status = driver.isBusy ? 
            `${colors.red}● BUSY${colors.reset}` : 
            `${colors.green}● AVAILABLE${colors.reset}`;
        
        const location = driver.location ? 
            `(${driver.location.lat.toFixed(4)}, ${driver.location.lon.toFixed(4)})` : 
            'Unknown';
        
        const restTime = driver.restTime >= 0 ? 
            `${driver.restTime}s` : 
            colors.red + 'On Trip' + colors.reset;
        
        console.log(
            driver.driverId.padEnd(15) +
            status.padEnd(15 + 9) + // +9 for ANSI codes
            location.padEnd(25) +
            restTime
        );
    }
    
    console.log(colors.dim + '─'.repeat(80) + colors.reset);
    console.log();
}

// Draw recent activity log
const activityLog: string[] = [];
const MAX_LOG_ENTRIES = 10;

function addActivity(message: string) {
    const timestamp = new Date().toLocaleTimeString();
    activityLog.unshift(`[${timestamp}] ${message}`);
    if (activityLog.length > MAX_LOG_ENTRIES) {
        activityLog.pop();
    }
}

function drawActivityLog() {
    console.log(colors.bright + '📝 RECENT ACTIVITY:' + colors.reset);
    console.log(colors.dim + '─'.repeat(80) + colors.reset);
    
    if (activityLog.length === 0) {
        console.log(colors.dim + '  No activity yet...' + colors.reset);
    } else {
        activityLog.forEach(log => {
            console.log(`  ${log}`);
        });
    }
    
    console.log(colors.dim + '─'.repeat(80) + colors.reset);
    console.log();
}

// Update display
function updateDisplay() {
    clearScreen();
    drawHeader();
    drawDashboard();
    drawDriverTable();
    drawActivityLog();
    console.log(colors.dim + 'Press Ctrl+C to exit' + colors.reset);
}

// Calculate statistics
function updateStatistics() {
    totalDriversAvailable = 0;
    totalRidesInProgress = 0;
    
    for (const driver of drivers.values()) {
        if (driver.isBusy) {
            totalRidesInProgress++;
        } else {
            totalDriversAvailable++;
        }
    }
}

// Monitor server via WebSocket
function monitorServer(serverUrl: string) {
    const ws = new WebSocket(serverUrl);
    
    ws.on('open', () => {
        addActivity(colors.green + '✓ Connected to server' + colors.reset);
        updateDisplay();
        
        // Send monitor registration
        ws.send(JSON.stringify({
            type: 'monitor'
        }));
    });
    
    ws.on('message', (data: WebSocket.Data) => {
        try {
            const message: MonitorMessage = JSON.parse(data.toString());
            
            switch (message.type) {
                case 'register':
                    if (message.driverId) {
                        drivers.set(message.driverId, {
                            driverId: message.driverId,
                            location: message.location,
                            restTime: message.restTime,
                            isBusy: false
                        });
                        addActivity(
                            `${colors.cyan}📍 Driver ${message.driverId} registered${colors.reset}`
                        );
                    }
                    break;
                    
                case 'update':
                    if (message.driverId && drivers.has(message.driverId)) {
                        const driver = drivers.get(message.driverId);
                        driver.location = message.location;
                        driver.restTime = message.restTime;
                        
                        // Check if driver just became available (restTime changed from -1 to 0)
                        if (driver.isBusy && message.restTime === 0) {
                            driver.isBusy = false;
                            totalRidesCompleted++;
                            // Add earnings from completed ride
                            if (driver.currentRidePrice) {
                                totalEarnings += driver.currentRidePrice;
                                addActivity(
                                    `${colors.green}✓ Driver ${message.driverId} completed ride - earned €${driver.currentRidePrice.toFixed(2)}${colors.reset}`
                                );
                                driver.currentRidePrice = undefined;
                            } else {
                                addActivity(
                                    `${colors.green}✓ Driver ${message.driverId} completed ride${colors.reset}`
                                );
                            }
                        }
                    }
                    break;
                    
                case 'ride_request':
                    if (message.driverId) {
                        addActivity(
                            `${colors.yellow}🚗 Ride request sent to ${message.driverId}${colors.reset} ` +
                            `(Customer: ${message.request?.customer_id})`
                        );
                    }
                    break;
                    
                case 'response':
                    if (message.driverId && message.response) {
                        if (message.response === 'accept') {
                            const driver = drivers.get(message.driverId);
                            if (driver) {
                                driver.isBusy = true;
                                driver.restTime = -1;
                                // Track the current ride price for this driver
                                if (message.request && typeof message.request.price === 'number') {
                                    driver.currentRidePrice = message.request.price;
                                }
                            }
                            addActivity(
                                `${colors.green}✓ Driver ${message.driverId} accepted ride${colors.reset} ` +
                                `(Customer: ${message.customerId})`
                            );
                        } else {
                            addActivity(
                                `${colors.red}✗ Driver ${message.driverId} rejected ride${colors.reset} ` +
                                `(Customer: ${message.customerId})`
                            );
                        }
                    }
                    break;
                    
                case 'deregister':
                    if (message.driverId) {
                        const driver = drivers.get(message.driverId);
                        drivers.delete(message.driverId);
                        addActivity(
                            `${colors.red}📍 Driver ${message.driverId} disconnected${colors.reset}`
                        );
                        // Force immediate statistics and display update
                        updateStatistics();
                        updateDisplay();
                    }
                    break;
            }
            
            updateStatistics();
            updateDisplay();
        } catch (error) {
            console.error('Error processing message:', error);
        }
    });
    
    ws.on('error', (error) => {
        addActivity(colors.red + '✗ WebSocket error: ' + error.message + colors.reset);
        updateDisplay();
    });
    
    ws.on('close', () => {
        addActivity(colors.red + '✗ Disconnected from server' + colors.reset);
        updateDisplay();
        console.log('\nConnection lost. Exiting...');
        process.exit(1);
    });
    
    return ws;
}

// Main function
async function main() {
    const SERVER_URL = 'ws://localhost:3000';
    
    console.log('Starting simulation monitor...\n');
    console.log('Connecting to server at ' + SERVER_URL + '...\n');
    
    const ws = monitorServer(SERVER_URL);
    
    // Update display every second
    setInterval(() => {
        updateDisplay();
    }, 1000);
    
    // Handle graceful shutdown
    process.on('SIGINT', () => {
        console.log('\n\nShutting down monitor...');
        ws.close();
        console.log('Goodbye!');
        process.exit(0);
    });
}

// Run the monitor
main().catch(console.error);
