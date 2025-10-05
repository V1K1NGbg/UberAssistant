import fs from 'fs';
import path from 'path';
import WebSocket from 'ws';

export interface Customer {
    customer_id: string;
    customer_name: string;
    customer_rating: number;
}

export interface CustomerRequest {
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
    duration_mins: number;
    price: number;
    advice?: string;
}

export interface Driver {
    driver_id: string;
    driver_name: string;
    driver_rating: number;
    driver_gender: string;
}

export interface DriverStatus {
    driver_id: string;
    location: {
        lat: number;
        lon: number;
    };
    restTime: number;
}

interface Storage {
    customers: Map<string, Customer>;
    customerRequests: CustomerRequest[];
    drivers: Map<string, Driver>;
    driverStatuses: Map<string, DriverStatus>;
    activeConnections: Map<string, WebSocket>;
}

class StorageManager {
    private storage: Storage;
    private storageDir: string;
    private driversFile: string;
    private customersFile: string;

    constructor(storageDirPath?: string) {
        this.storageDir = storageDirPath || path.join(__dirname, '../storage');
        this.driversFile = path.join(this.storageDir, 'drivers.json');
        this.customersFile = path.join(this.storageDir, 'customers.json');

        // Ensure storage directory exists
        if (!fs.existsSync(this.storageDir)) {
            fs.mkdirSync(this.storageDir, { recursive: true });
        }

        // Initialize storage
        this.storage = {
            customers: new Map(),
            customerRequests: [],
            drivers: new Map(),
            driverStatuses: new Map(),
            activeConnections: new Map()
        };

        // Load existing data
        this.loadAllData();
    }

    private loadAllData(): void {
        this.loadDrivers();
        this.loadCustomers();
        console.log(`Loaded ${this.storage.drivers.size} drivers and ${this.storage.customers.size} customers from storage`);
    }

    private loadDrivers(): void {
        try {
            if (fs.existsSync(this.driversFile)) {
                const data = JSON.parse(fs.readFileSync(this.driversFile, 'utf8'));
                this.storage.drivers = new Map(Object.entries(data));
            }
        } catch (error) {
            console.error('Error loading drivers:', error);
        }
    }

    private loadCustomers(): void {
        try {
            if (fs.existsSync(this.customersFile)) {
                const data = JSON.parse(fs.readFileSync(this.customersFile, 'utf8'));
                this.storage.customers = new Map(Object.entries(data));
            }
        } catch (error) {
            console.error('Error loading customers:', error);
        }
    }

    // Save methods
    saveDrivers(): void {
        try {
            const driversObj = Object.fromEntries(this.storage.drivers);
            fs.writeFileSync(
                this.driversFile,
                JSON.stringify(driversObj, null, 2)
            );
        } catch (error) {
            console.error('Error saving drivers:', error);
        }
    }

    saveCustomers(): void {
        try {
            const customersObj = Object.fromEntries(this.storage.customers);
            fs.writeFileSync(
                this.customersFile,
                JSON.stringify(customersObj, null, 2)
            );
        } catch (error) {
            console.error('Error saving customers:', error);
        }
    }

    saveAll(): void {
        this.saveDrivers();
        this.saveCustomers();
    }

    // Customer Request methods
    addCustomerRequest(request: CustomerRequest): void {
        this.storage.customerRequests.push(request);
    }

    getCustomerRequests(): CustomerRequest[] {
        return this.storage.customerRequests;
    }

    clearCustomerRequests(): void {
        this.storage.customerRequests = [];
    }

    // Driver methods
    setDriver(driverId: string, driver: Driver): void {
        this.storage.drivers.set(driverId, driver);
        this.saveDrivers();
    }

    getDriver(driverId: string): Driver | undefined {
        return this.storage.drivers.get(driverId);
    }

    getAllDrivers(): Array<{ id: string } & Driver> {
        return Array.from(this.storage.drivers.entries()).map(([id, data]) => ({
            id,
            ...data
        }));
    }

    getAllCustomers(): Array<{ id: string } & Customer> {
        return Array.from(this.storage.customers.entries()).map(([id, data]) => ({
            id,
            ...data
        }));
    }

    deleteDriver(driverId: string): boolean {
        const result = this.storage.drivers.delete(driverId);
        if (result) {
            this.saveDrivers();
        }
        return result;
    }

    // Customer methods
    setCustomer(customerId: string, customer: Customer): void {
        this.storage.customers.set(customerId, customer);
        this.saveCustomers();
    }

    getCustomer(customerId: string): Customer | undefined {
        return this.storage.customers.get(customerId);
    }

    // Driver Status methods
    setDriverStatus(driverId: string, status: DriverStatus): void {
        this.storage.driverStatuses.set(driverId, status);
    }

    getDriverStatus(driverId: string): DriverStatus | undefined {
        return this.storage.driverStatuses.get(driverId);
    }

    getAllDriverStatuses(): Array<{ id: string } & DriverStatus> {
        return Array.from(this.storage.driverStatuses.entries()).map(([id, data]) => ({
            id,
            ...data
        }));
    }

    deleteDriverStatus(driverId: string): boolean {
        return this.storage.driverStatuses.delete(driverId);
    }

    // WebSocket connection methods
    setActiveConnection(driverId: string, ws: WebSocket): void {
        this.storage.activeConnections.set(driverId, ws);
    }

    getActiveConnection(driverId: string): WebSocket | undefined {
        return this.storage.activeConnections.get(driverId);
    }

    deleteActiveConnection(driverId: string): boolean {
        return this.storage.activeConnections.delete(driverId);
    }

    getActiveConnectionsCount(): number {
        return this.storage.activeConnections.size;
    }
}

export default StorageManager;
