import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "Worker") {
        archetype = new Worker("", new Warehouse(0), false, 0);
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class Warehouse {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Warehouse";

    private readonly capacity: number;
    private currentLoad = new SharedNumber(0);

    constructor(capacity: number) {
        this.capacity = capacity;
    }

    store(amount: number, workerName: string): void {
        SynStart(this.syn);
        while (this.currentLoad.getValue() + amount > this.capacity) {
            console.log(`${workerName} is waiting to store ${amount} units. Current load: ${this.currentLoad.getValue()}`);
        }
        this.currentLoad.setValue(this.currentLoad.getValue() + amount);
        console.log(`${workerName} stored ${amount} units. Current load: ${this.currentLoad.getValue()}`);
        SynEnd(this.syn);
    }

    retrieve(amount: number, workerName: string): void {
        SynStart(this.syn);
        while (this.currentLoad.getValue() < amount) {
            console.log(`${workerName} is waiting to retrieve ${amount} units. Current load: ${this.currentLoad.getValue()}`);
        }
        this.currentLoad.setValue(this.currentLoad.getValue() - amount);
        console.log(`${workerName} retrieved ${amount} units. Current load: ${this.currentLoad.getValue()}`);
        SynEnd(this.syn);
    }

    getCurrentLoad(): number {
        SynStart(this.syn);
        const load = this.currentLoad.getValue();
        SynEnd(this.syn);
        return load;
    }
}

class Worker implements Runnable {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Worker";

    private readonly name = new SharedString(name);
    private readonly warehouse: Warehouse;
    private readonly isStorer = new SharedBoolean(isStorer);
    private readonly amount = new SharedNumber(amount);

    constructor(name: string, warehouse: Warehouse, isStorer: boolean, amount: number) {
        this.name.setValue(name);
        this.warehouse = warehouse;
        this.isStorer.setValue(isStorer);
        this.amount.setValue(amount);
    }

    run(): void {
        if (this.isStorer.getValue()) {
            this.warehouse.store(this.amount.getValue(), this.name.getValue());
        } else {
            this.warehouse.retrieve(this.amount.getValue(), this.name.getValue());
        }
    }
}

class WarehouseSimulation {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "WarehouseSimulation";

    public static main(args: string[]): void {
        const warehouse = new Warehouse(100);
        const workers: Thread[] = new Array(10);
        for (let i = 0; i < workers.length; i++) {
            if (i % 2 === 0) {
                workers[i] = new Thread(new Worker("Worker " + i, warehouse, true, 30));
            } else {
                workers[i] = new Thread(new Worker("Worker " + i, warehouse, false, 20));
            }
            workers[i].start();
        }
        console.log("Final load in warehouse: " + warehouse.getCurrentLoad() + " units.");
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}