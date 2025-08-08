import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "Producer") {
        archetype = new Producer(new Semaphores(new Syc()), 0); // Assuming rank 0 for instantiation
    } else if (runnable.className == "Consumer") {
        archetype = new Consumer(new Semaphores(new Syc()), 0); // Assuming rank 0 for instantiation
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class CircleBuffer {

    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "CircleBuffer";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const producer1 = new Thread(new Producer(semaphores, 1));
        const producer2 = new Thread(new Producer(semaphores, 2));
        const consumer1 = new Thread(new Consumer(semaphores, 1));
        const consumer2 = new Thread(new Consumer(semaphores, 2));
        producer1.start();
        producer2.start();
        consumer1.start();
        consumer2.start();
    }
}

class Semaphores {

    public mutex1 = new SharedBoolean(true);
    public mutex2 = new SharedBoolean(true);
    public empty = new SharedNumber(1000);
    public full = new SharedNumber(0);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Semaphores";

    constructor(syn: Syc) {
        this.syn = syn;
    }

    public pMutex1(): boolean {
        SynStart(this.syn);
        if (this.mutex1.getValue()) {
            this.mutex1.setValue(false);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    // other methods omitted for brevity

}

class Producer implements Runnable {

    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Producer";
    public rank = new SharedNumber(rank);

    constructor(semaphores: Semaphores, rank: number) {
        this.semaphores = semaphores;
        this.rank.setValue(rank);
    }

    public run(): void {
        while (true) {
            console.log(`Producer ${this.rank.getValue()} produces a production.`);
            while (!this.semaphores.pEmpty()) {}
            while (!this.semaphores.pMutex2()) {}
            console.log(`Producer ${this.rank.getValue()} puts a production into the buffer.`);
            this.semaphores.vMutex2();
            this.semaphores.vFull();
        }
    }
}

class Consumer implements Runnable {

    public semaphores: Semaphores;
    public rank = new SharedNumber(rank);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Consumer";

    constructor(semaphores: Semaphores, rank: number) {
        this.semaphores = semaphores;
        this.rank.setValue(rank);
    }

    public run(): void {
        while (true) {
            while (!this.semaphores.pMutex1()) {}
            for (let i = 1; i <= 10; i++) {
                while (!this.semaphores.pFull()) {}
                while (!this.semaphores.pMutex2()) {}
                console.log(`Consumer ${this.rank.getValue()} gets the ${i}st/nd/rd/th production from the buffer.`);
                this.semaphores.vMutex2();
                this.semaphores.vEmpty();
                console.log(`Consumer ${this.rank.getValue()} consumes the ${i}st/nd/rd/th production.`);
            }
            this.semaphores.vMutex1();
        }
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}