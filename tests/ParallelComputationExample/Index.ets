import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "ST") {
        archetype = new ST([], 0, 0); // Example instantiation, adjust as needed
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class ParallelComputationExample {

    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "ParallelComputationExample";

    static main(args: string[]): void {
        const array: number[] = new Array(100);
        for (let i = 0; i < array.length; i++) {
            array[i] = i + 1;
        }
        const numThreads = 4;
        const chunkSize = Math.floor(array.length / numThreads);
        const threads: Thread[] = new Array(numThreads);
        const tasks: ST[] = new Array(numThreads);
        for (let i = 0; i < numThreads; i++) {
            const start = i * chunkSize;
            const end = (i === numThreads - 1) ? array.length : start + chunkSize;
            tasks[i] = new ST(array, start, end);
            threads[i] = new Thread(tasks[i]);
            threads[i].start();
        }
        let totalSum = 0;
        for (let i = 0; i < numThreads; i++) {
            try {
                threads[i].join();
                totalSum += tasks[i].getSum();
            } catch (e) {
                console.error(e);
            }
        }
        console.log("Total sum of squares: " + totalSum);
    }
}

class ST implements Runnable {

    private readonly array: number[];
    private readonly start: number;
    private readonly end: number;
    private sum = new SharedNumber(0);
    
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "ST";

    constructor(array: number[], start: number, end: number) {
        this.array = array;
        this.start = start;
        this.end = end;
        this.sum.setValue(0);
    }

    run(): void {
        for (let i = this.start; i < this.end; i++) {
            this.sum.setValue(this.sum.getValue() + this.array[i] * this.array[i]);
        }
    }

    getSum(): number {
        return this.sum.getValue();
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}