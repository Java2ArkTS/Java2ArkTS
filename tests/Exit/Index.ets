import { SynStart, SynEnd, SharedBoolean, SharedNumber, Syc, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "Visitor") {
        archetype = new Visitor(new Semaphores(), 0); // Assuming rank 0 for archetype
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class Exit {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Exit";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const visitor1 = new Thread(new Visitor(semaphores, 1));
        const visitor2 = new Thread(new Visitor(semaphores, 2));
        const visitor3 = new Thread(new Visitor(semaphores, 3));
        const visitor4 = new Thread(new Visitor(semaphores, 4));
        const visitor5 = new Thread(new Visitor(semaphores, 5));
        visitor1.start();
        visitor2.start();
        visitor3.start();
        visitor4.start();
        visitor5.start();
    }
}

class Semaphores {
    public empty = new SharedNumber(500);
    public mutex = new SharedBoolean(true);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Semaphores";

    public pEmpty(): boolean {
        SynStart(this.syn);
        if (this.empty.getValue() > 0) {
            this.empty.setValue(this.empty.getValue() - 1);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    public pMutex(): boolean {
        SynStart(this.syn);
        if (this.mutex.getValue()) {
            this.mutex.setValue(false);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    public vEmpty(): void {
        SynStart(this.syn);
        this.empty.setValue(this.empty.getValue() + 1);
        SynEnd(this.syn);
    }

    public vMutex(): void {
        SynStart(this.syn);
        this.mutex.setValue(true);
        SynEnd(this.syn);
    }
}

class Visitor implements Runnable {
    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Visitor";
    public rank = new SharedNumber(rank);

    constructor(semaphores: Semaphores, rank: number) {
        this.semaphores = semaphores;
        this.rank.setValue(rank);
    }

    public run(): void {
        while (!this.semaphores.pEmpty()) {
        }
        while (!this.semaphores.pMutex()) {
        }
        console.log(`Visitor ${this.rank.getValue()} enters the museum.`);
        this.semaphores.vMutex();
        console.log(`Visitor ${this.rank.getValue()} visits the museum.`);
        while (!this.semaphores.pMutex()) {
        }
        console.log(`Visitor ${this.rank.getValue()} leaves the museum.`);
        this.semaphores.vMutex();
        this.semaphores.vEmpty();
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}