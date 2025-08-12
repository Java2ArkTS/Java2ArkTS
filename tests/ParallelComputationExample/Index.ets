import {
  SynStart,
  SynEnd,
  wait,
  notify,
  SharedBoolean,
  SharedString,
  SharedNumber,
  Syc,
  isMainThread,
  addFunc,
  Runnable,
  Thread,
} from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className === "ParallelComputationExample") {
    archetype = new ParallelComputationExample();
  } else if (runnable.className === "ST") {
    archetype = new ST([], 0, 0); // Provide default values for constructor parameters
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

export class ParallelComputationExample implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "ParallelComputationExample";

  public run(): void {
    ParallelComputationExample.main([]);
  }

  public static main(args: string[]): void {
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
      const end = i === numThreads - 1 ? array.length : start + chunkSize;
      tasks[i] = new ST(array, start, end);
      threads[i] = new Thread(tasks[i]);
      threads[i].start();
    }

    let totalSum = 0;
    for (let i = 0; i < numThreads; i++) {
      try {
        // Simulate join by waiting for the thread to complete
        while (!tasks[i].syn.synArray[0]) {
          // Busy-wait until the thread signals completion
        }
        totalSum += tasks[i].getSum();
      } catch (e) {
        console.error(e);
      }
    }
    console.log("Total sum of squares: " + totalSum);
  }
}

class ST implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "ST";

  private readonly array: number[];
  private readonly start: number;
  private readonly end: number;
  private sum = new SharedNumber(0);

  constructor(array: number[], start: number, end: number) {
    this.array = array;
    this.start = start;
    this.end = end;
  }

  run(): void {
    for (let i = this.start; i < this.end; i++) {
      this.sum.setValue(this.sum.getValue() + this.array[i] * this.array[i]);
    }
    this.syn.synArray[0] = 1; // Signal completion
  }

  getSum(): number {
    return this.sum.getValue();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}