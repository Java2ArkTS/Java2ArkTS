import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "Older") {
    archetype = new Older(new Semaphores(), 1); // Example rank, adjust as needed
  } else if (runnable.className == "Younger") {
    archetype = new Younger(new Semaphores(), 1); // Example rank, adjust as needed
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Temple {

    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Temple";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const younger1 = new Thread(new Younger(semaphores, 1));
        const younger2 = new Thread(new Younger(semaphores, 2));
        const older1 = new Thread(new Older(semaphores, 1));
        const older2 = new Thread(new Older(semaphores, 2));
        younger1.start();
        younger2.start();
        older1.start();
        older2.start();
    }
}

class Semaphores {

    public well = new SharedBoolean(true);
    public vat = new SharedBoolean(true);
    public empty = new SharedNumber(10);
    public full = new SharedNumber(0);
    public pail = new SharedNumber(3);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Semaphores";

    public P_well(): boolean {
        SynStart(this.syn);
        if (this.well.getValue()) {
            this.well.setValue(false);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    // Other methods omitted for brevity

}

class Older implements Runnable {

    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Older";
    public rank = new SharedNumber(rank);

    constructor(semaphores: Semaphores, rank: number) {
        this.semaphores = semaphores;
        this.rank.setValue(rank);
    }

    public run(): void {
        while (true) {
            while (!this.semaphores.P_full()) {}
            while (!this.semaphores.P_pail()) {}
            while (!this.semaphores.P_vat()) {}
            console.log(`Old monk ${this.rank.getValue()} gets a bucket of water from the tank.`);
            this.semaphores.V_vat();
            this.semaphores.V_empty();
            console.log(`Old monk ${this.rank.getValue()} drinks water.`);
            this.semaphores.V_pail();
        }
    }
}

class Younger implements Runnable {

    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Younger";
    public rank = new SharedNumber(rank);

    constructor(semaphores: Semaphores, rank: number) {
        this.semaphores = semaphores;
        this.rank.setValue(rank);
    }

    public run(): void {
        while (true) {
            while (!this.semaphores.P_empty()) {}
            while (!this.semaphores.P_pail()) {}
            while (!this.semaphores.P_well()) {}
            console.log(`Young monk ${this.rank.getValue()} gets a bucket of water from the well.`);
            this.semaphores.V_well();
            while (!this.semaphores.P_vat()) {}
            console.log(`Young monk ${this.rank.getValue()} pour the water to the tank.`);
            this.semaphores.V_vat();
            this.semaphores.V_full();
            this.semaphores.V_pail();
        }
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}