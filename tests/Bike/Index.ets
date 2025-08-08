import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "Worker1") {
        archetype = new Worker1(new Semaphores());
    } else if (runnable.className == "Worker2") {
        archetype = new Worker2(new Semaphores());
    } else if (runnable.className == "Worker3") {
        archetype = new Worker3(new Semaphores());
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class Bike {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Bike";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const worker1 = new Thread(new Worker1(semaphores));
        const worker2 = new Thread(new Worker2(semaphores));
        const worker3 = new Thread(new Worker3(semaphores));
        worker1.start();
        worker2.start();
        worker3.start();
    }
}

class Semaphores {
    public empty = new SharedNumber(5);
    public wheel = new SharedNumber(0);
    public frame = new SharedNumber(0);
    public s1 = new SharedNumber(3);
    public s2 = new SharedNumber(4);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Semaphores";

    public ps1(): boolean {
        SynStart(this.syn);
        if (this.s1.getValue() > 0) {
            this.s1.setValue(this.s1.getValue() - 1);
            SynEnd(this.syn);
            return true;
        }
        SynEnd(this.syn);
        return false;
    }

    public ps2(): boolean {
        SynStart(this.syn);
        if (this.s2.getValue() > 0) {
            this.s2.setValue(this.s2.getValue() - 1);
            SynEnd(this.syn);
            return true;
        }
        SynEnd(this.syn);
        return false;
    }

    public pEmpty(): boolean {
        SynStart(this.syn);
        if (this.empty.getValue() > 0) {
            this.empty.setValue(this.empty.getValue() - 1);
            SynEnd(this.syn);
            return true;
        }
        SynEnd(this.syn);
        return false;
    }

    public pWheel(): boolean {
        SynStart(this.syn);
        if (this.wheel.getValue() > 0) {
            this.wheel.setValue(this.wheel.getValue() - 1);
            SynEnd(this.syn);
            return true;
        }
        SynEnd(this.syn);
        return false;
    }

    public pFrame(): boolean {
        SynStart(this.syn);
        if (this.frame.getValue() > 0) {
            this.frame.setValue(this.frame.getValue() - 1);
            SynEnd(this.syn);
            return true;
        }
        SynEnd(this.syn);
        return false;
    }

    public vs1(): void {
        SynStart(this.syn);
        this.s1.setValue(this.s1.getValue() + 1);
        SynEnd(this.syn);
    }

    public vs2(): void {
        SynStart(this.syn);
        this.s2.setValue(this.s2.getValue() + 1);
        SynEnd(this.syn);
    }

    public vEmpty(): void {
        SynStart(this.syn);
        this.empty.setValue(this.empty.getValue() + 1);
        SynEnd(this.syn);
    }

    public vWheel(): void {
        SynStart(this.syn);
        this.wheel.setValue(this.wheel.getValue() + 1);
        SynEnd(this.syn);
    }

    public vFrame(): void {
        SynStart(this.syn);
        this.frame.setValue(this.frame.getValue() + 1);
        SynEnd(this.syn);
    }
}

class Worker1 implements Runnable {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Worker1";
    public semaphores: Semaphores;

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    run(): void {
        while (true) {
            console.log("Worker1 produces a frame.");
            while (!this.semaphores.ps1()) {}
            while (!this.semaphores.pEmpty()) {}
            console.log("Worker1 puts a frame into the box.");
            this.semaphores.vFrame();
        }
    }
}

class Worker2 implements Runnable {
    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Worker2";

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    run(): void {
        while (true) {
            console.log("Worker2 produces a wheel.");
            while (!this.semaphores.ps2()) {}
            while (!this.semaphores.pEmpty()) {}
            console.log("Worker2 puts a wheel into the box.");
            this.semaphores.vWheel();
        }
    }
}

class Worker3 implements Runnable {
    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Worker3";

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    public run(): void {
        while (true) {
            while (!this.semaphores.pFrame()) {}
            console.log("Worker3 gets a frame from the box.");
            this.semaphores.vEmpty();
            this.semaphores.vs1();
            while (!this.semaphores.pWheel()) {}
            while (!this.semaphores.pWheel()) {}
            console.log("Worker3 gets two wheels from the box.");
            this.semaphores.vEmpty();
            this.semaphores.vEmpty();
            this.semaphores.vs2();
            this.semaphores.vs2();
            console.log("Worker3 assembles a frame and two wheels to produce a bike.");
        }
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}