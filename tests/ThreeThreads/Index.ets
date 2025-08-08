import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "P1") {
        archetype = new P1(new Semaphores(new Syc()));
    } else if (runnable.className == "P2") {
        archetype = new P2(new Semaphores(new Syc()));
    } else if (runnable.className == "P3") {
        archetype = new P3(new Semaphores(new Syc()));
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class ThreeThreads {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "ThreeThreads";
    
    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const p1 = new Thread(new P1(semaphores));
        const p2 = new Thread(new P2(semaphores));
        const p3 = new Thread(new P3(semaphores));
        p1.start();
        p2.start();
        p3.start();
    }
}

class Semaphores {
    public s1 = new SharedNumber(1);
    public s2 = new SharedNumber(0);
    public s3 = new SharedNumber(0);
    public sb = new SharedNumber(0);
    public sy = new SharedNumber(0);
    public sz = new SharedNumber(0);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Semaphores";

    constructor(syn: Syc) {
        this.syn = syn;
    }

    public Ps1(): boolean {
        SynStart(this.syn);
        if (this.s1.getValue() > 0) {
            this.s1.setValue(this.s1.getValue() - 1);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    // Other PsX(), VsX() methods omitted for brevity

    public Vsz(): void {
        SynStart(this.syn);
        this.sz.setValue(this.sz.getValue() + 1);
        SynEnd(this.syn);
    }
}

class P1 implements Runnable {
    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "P1";

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    public run(): void {
        while (!this.semaphores.Ps1()) {
        }
        console.log("P1 reads a from the input device.");
        this.semaphores.Vs2();
        // Other steps omitted for brevity
    }
}

class P2 implements Runnable {
    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "P2";

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    public run(): void {
        while (!this.semaphores.Ps2()) {
        }
        console.log("P2 reads b from the input device.");
        // Other steps omitted for brevity
    }
}

class P3 implements Runnable {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "P3";
    
    public semaphores: Semaphores;

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    run(): void {
        while (!this.semaphores.Ps3()) {
        }
        console.log("P3 reads c from the input device.");
        // Other steps omitted for brevity
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}