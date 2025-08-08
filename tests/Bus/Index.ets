import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "Driver") {
    archetype = new Driver(new Semaphores());
  } else if (runnable.className == "Conductor") {
    archetype = new Conductor(new Semaphores());
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Bus {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Bus";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const driver = new Thread(new Driver(semaphores));
        const conductor = new Thread(new Conductor(semaphores));
        driver.start();
        conductor.start();
    }
}

class Semaphores {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Semaphores";
    public s1 = new SharedBoolean(false);
    public s2 = new SharedBoolean(false);

    public ps1(): boolean {
        SynStart(this.syn);
        if (this.s1.getValue()) {
            this.s1.setValue(false);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    public ps2(): boolean {
        SynStart(this.syn);
        if (this.s2.getValue()) {
            this.s2.setValue(false);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    public vs1(): void {
        SynStart(this.syn);
        this.s1.setValue(true);
        SynEnd(this.syn);
    }

    public vs2(): void {
        SynStart(this.syn);
        this.s2.setValue(true);
        SynEnd(this.syn);
    }
}

class Driver implements Runnable {
    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Driver";
    
    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    run(): void {
        while (true) {
            while (!this.semaphores.ps1()) {
            }
            console.log("Bus starts.");
            console.log("Driver is driving.");
            console.log("Bus stops.");
            this.semaphores.vs2();
        }
    }
}

class Conductor implements Runnable {
    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Conductor";
    
    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    public run(): void {
        while (true) {
            console.log("Conductor closes the door.");
            this.semaphores.vs1();
            console.log("Conductor sells tickets.");
            while (!this.semaphores.ps2()) {
            }
            console.log("Conductor opens the door.");
            console.log("Customers get on/off the bus.");
        }
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}