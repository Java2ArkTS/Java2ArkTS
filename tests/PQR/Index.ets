import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "P") {
        archetype = new P(new Semaphores());
    } else if (runnable.className == "Q") {
        archetype = new Q(new Semaphores());
    } else if (runnable.className == "R") {
        archetype = new R(new Semaphores());
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class PQR {

    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "PQR";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const p = new Thread(new P(semaphores));
        const q = new Thread(new Q(semaphores));
        const r = new Thread(new R(semaphores));
        p.start();
        q.start();
        r.start();
    }
}

class Semaphores {

    public full = new SharedBoolean(false);
    public empty = new SharedBoolean(true);
    public mutex = new SharedBoolean(true);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Semaphores";

    public pFull(): boolean {
        SynStart(this.syn);
        if (this.full.getValue()) {
            this.full.setValue(false);
            SynEnd(this.syn);
            return true;
        }
        SynEnd(this.syn);
        return false;
    }

    public pEmpty(): boolean {
        SynStart(this.syn);
        if (this.empty.getValue()) {
            this.empty.setValue(false);
            SynEnd(this.syn);
            return true;
        }
        SynEnd(this.syn);
        return false;
    }

    public pMutex(): boolean {
        SynStart(this.syn);
        if (this.mutex.getValue()) {
            this.mutex.setValue(false);
            SynEnd(this.syn);
            return true;
        }
        SynEnd(this.syn);
        return false;
    }

    public vFull(): void {
        SynStart(this.syn);
        this.full.setValue(true);
        SynEnd(this.syn);
    }

    public vEmpty(): void {
        SynStart(this.syn);
        this.empty.setValue(true);
        SynEnd(this.syn);
    }

    public vMutex(): void {
        SynStart(this.syn);
        this.mutex.setValue(true);
        SynEnd(this.syn);
    }
}

class P implements Runnable {

    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "P";
    public semaphores: Semaphores;

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    run(): void {
        while (true) {
            while (!this.semaphores.pEmpty()) {
            }
            while (!this.semaphores.pMutex()) {
            }
            console.log("P produces one.");
            this.semaphores.vMutex();
            this.semaphores.vFull();
        }
    }
}

class Q implements Runnable {

    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Q";

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    public run(): void {
        while (true) {
            while (!this.semaphores.pFull()) {
            }
            while (!this.semaphores.pMutex()) {
            }
            console.log("Q consumes one.");
            this.semaphores.vMutex();
            this.semaphores.vEmpty();
        }
    }
}

class R implements Runnable {

    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "R";

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    public run(): void {
        while (true) {
            if (this.semaphores.empty.getValue()) {
                while (!this.semaphores.pEmpty()) {
                }
                while (!this.semaphores.pMutex()) {
                }
                console.log("R produces one.");
                this.semaphores.vMutex();
                this.semaphores.vFull();
            }
            if (this.semaphores.full.getValue()) {
                while (!this.semaphores.pFull()) {
                }
                while (!this.semaphores.pMutex()) {
                }
                console.log("R consumes one.");
                this.semaphores.vMutex();
                this.semaphores.vEmpty();
            }
        }
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}