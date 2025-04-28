import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Warehouse {
    private capacity: any = getClass('number', 0);
    private currentLoad: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(capacity: number) {
        setValues(this.capacity, capacity);
        setValues(this.currentLoad, 0);
    }

    store(amount: number, workerName: string): void {
        {
            SynStart(this['synArray']);
            while (getValues(this.currentLoad) + amount > getValues(this.capacity)) {
                console.log(`${workerName} is waiting to store ${amount} units. Current load: ${getValues(this.currentLoad)}`);
            }
            setValues(this.currentLoad, getValues(this.currentLoad) + amount);
            console.log(`${workerName} stored ${amount} units. Current load: ${getValues(this.currentLoad)}`);
            SynEnd(this['synArray']);
        }
    }

    retrieve(amount: number, workerName: string): void {
        {
            SynStart(this['synArray']);
            while (getValues(this.currentLoad) < amount) {
                console.log(`${workerName} is waiting to retrieve ${amount} units. Current load: ${getValues(this.currentLoad)}`);
            }
            setValues(this.currentLoad, getValues(this.currentLoad) - amount);
            console.log(`${workerName} retrieved ${amount} units. Current load: ${getValues(this.currentLoad)}`);
            SynEnd(this['synArray']);
        }
    }

    getCurrentLoad(): number {
        {
            SynStart(this['synArray']);
            const load = getValues(this.currentLoad);
            SynEnd(this['synArray']);
            return load;
        }
    }
}

class Worker implements Runnable {

    private readonly name: any = getClass('string');
    private readonly warehouse: any = getClass('Warehouse');
    private readonly isStorer: any = getClass('boolean');
    private readonly amount: any = getClass('number');

    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(name: string, warehouse: Warehouse, isStorer: boolean, amount: number) {
        setValues(this.name, name);
        setValues(this.warehouse, warehouse);
        setValues(this.isStorer, isStorer);
        setValues(this.amount, amount);
    }

    run(): void {
        if (getValues(this.isStorer)) {
            getValues(this.warehouse.store(getValues(this.amount), getValues(this.name)));
        } else {
            getValues(this.warehouse.retrieve(getValues(this.amount), getValues(this.name)));
        }
    }
}

class WarehouseSimulation {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        let warehouse = new Warehouse(100);
        let workers: Thread[] = new Array(10);
        for (let i = 0; i < workers.length; i++) {
            if (i % 2 === 0) {
                workers[i] = new Thread(new Worker("Worker " + i, warehouse, true, 30));
            } else {
                workers[i] = new Thread(new Worker("Worker " + i, warehouse, false, 20));
            }
            workers[i].start();
        }
        console.log("Final load in warehouse: " + getValues(warehouse.getCurrentLoad()) + " units.");
    }
}