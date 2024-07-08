import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class QueuingMachine {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const server = new Thread(new Server(semaphores));
        const customer1 = new Thread(new Customer(semaphores, 1));
        const customer2 = new Thread(new Customer(semaphores, 2));
        const customer3 = new Thread(new Customer(semaphores, 3));
        const customer4 = new Thread(new Customer(semaphores, 4);
        getValues(server.start());
        getValues(customer1.start());
        getValues(customer2.start());
        getValues(customer3.start());
        getValues(customer4.start());
    }
}

class Semaphores {
    public synArray: any = getSyc();
    public sharedType: string = "object";
    
    public empty: any = getClass('number', 10);
    public mutex: any = getClass('boolean', true);
    public full: any = getClass('number', 0);
    public service: any = getClass('boolean', false);

    public pEmpty(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.empty) > 0) {
            setValues(this.empty, getValues(this.empty) - 1);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public pFull(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.full) > 0) {
            setValues(this.full, getValues(this.full) - 1);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public pMutex(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.mutex)) {
            setValues(this.mutex, false);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public pService(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.service)) {
            setValues(this.service, false);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public vEmpty(): void {
        SynStart(this['synArray']);
        setValues(this.empty, getValues(this.empty) + 1);
        SynEnd(this['synArray']);
    }

    public vFull(): void {
        SynStart(this['synArray']);
        setValues(this.full, getValues(this.full) + 1);
        SynEnd(this['synArray']);
    }

    public vMutex(): void {
        SynStart(this['synArray']);
        setValues(this.mutex, true);
        SynEnd(this['synArray']);
    }

    public vService(): void {
        SynStart(this['synArray']);
        setValues(this.service, true);
        SynEnd(this['synArray']);
    }
}

class Customer implements Runnable {

    public synArray: any = getSyc();
    public sharedType: string = "object";
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public rank: any = getClass('number', 0);

    constructor(semaphores: Semaphores, rank: number) {
        setValues(this.semaphores, semaphores);
        setValues(this.rank, rank);
    }

    public run(): void {
        while (!getValues(this.semaphores.pEmpty())) {
        }
        while (!getValues(this.semaphores.pMutex())) {
        }
        console.log("Customer " + getValues(this.rank) + " takes a number.");
        getValues(this.semaphores.vMutex());
        getValues(this.semaphores.vFull());
        while (!getValues(this.semaphores.pService())) {
        }
        console.log("Customer " + getValues(this.rank) + " gets service.");
    }
}

class Server implements Runnable {

    public synArray: any = getSyc();
    public sharedType: string = "object";
    public semaphores: Semaphores = getClass('Semaphores', new Semaphores());

    constructor(semaphores: Semaphores) {
        setValues(this.semaphores, semaphores);
    }

    public run(): void {
        while (true) {
            while (!getValues(this.semaphores.pFull())) {
            }
            getValues(this.semaphores.vEmpty());
            getValues(this.semaphores.vService());
            console.log("Server serves.");
        }
    }
}