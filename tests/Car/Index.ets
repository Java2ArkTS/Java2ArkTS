import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "Vehicle") {
        archetype = new Vehicle("Archetype Vehicle", new Bridge(1));
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class Bridge {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Bridge";

    private capacity: number;
    private vehicles: string[];
    private count = new SharedNumber(0);

    constructor(capacity: number) {
        this.capacity = capacity;
        this.vehicles = new Array<string>(capacity);
    }

    public cross(vehicleName: string): void {
        SynStart(this.syn);
        while (this.count.getValue() >= this.capacity) {
            console.log(vehicleName + " is waiting to cross the bridge.");
        }
        this.vehicles[this.count.getValue()] = vehicleName;
        this.count.setValue(this.count.getValue() + 1);
        console.log(vehicleName + " is crossing the bridge.");

        for (let i = 0; i < 1000; i++);
        
        this.count.setValue(this.count.getValue() - 1);
        console.log(vehicleName + " has crossed the bridge.");

        for (let i = 0; i < this.count.getValue(); i++) {
            this.vehicles[i] = this.vehicles[i + 1];
        }
        this.vehicles[this.count.getValue()] = null;
        SynEnd(this.syn);
    }
}

class Vehicle implements Runnable {
    private name: SharedString;
    private bridge: Bridge;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Vehicle";

    constructor(name: string, bridge: Bridge) {
        this.name = new SharedString(name);
        this.bridge = bridge;
    }

    run(): void {
        this.bridge.cross(this.name.getValue());
    }
}

class Car {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Car";

    public static main(args: string[]): void {
        const bridge = new Bridge(2);
        for (let i = 1; i <= 5; i++) {
            const vehicleThread = new Thread(new Vehicle(`Vehicle ${i}`, bridge));
            vehicleThread.start();
        }
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}