import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Bridge {
    public synArray: any = getSyc();
    public sharedType: string = "object";
    private capacity: any = getClass('number', 0);
    private vehicles: any = getClass('Array', []);
    private count: any = getClass('number', 0);

    constructor(capacity: number) {
        setValues(this.capacity, capacity);
        setValues(this.vehicles, new Array(capacity));
        setValues(this.count, 0);
    }

    cross(vehicleName: string): void {
        {
            SynStart(this['synArray']);
            while (getValues(this.count) >= getValues(this.capacity)) {
                console.log(vehicleName + " is waiting to cross the bridge.");
            }
            setValues(this.vehicles[getValues(this.count)], vehicleName);
            setValues(this.count, getValues(this.count) + 1);
            console.log(vehicleName + " is crossing the bridge.");
            for (let i = 0; i < 1000; i++);
            setValues(this.count, getValues(this.count) - 1);
            console.log(vehicleName + " has crossed the bridge.");
            for (let i = 0; i < getValues(this.count); i++) {
                setValues(this.vehicles[i], getValues(this.vehicles[i + 1]));
            }
            setValues(this.vehicles[getValues(this.count)], null);
            SynEnd(this['synArray']);
        }
    }
}

class Vehicle implements Runnable {
    private name: any = getClass('string');
    private bridge: any = getClass('Bridge');
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(name: string, bridge: Bridge) {
        setValues(this.name, name);
        setValues(this.bridge, bridge);
    }

    run(): void {
        getValues(this.bridge.cross(getValues(this.name)));
    }
}

class Car {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const bridge = new Bridge(2);
        for (let i = 1; i <= 5; i++) {
            const vehicleThread = Thread(new Vehicle("Vehicle " + i, bridge));
            getValues(vehicleThread.start());
        }
    }
}