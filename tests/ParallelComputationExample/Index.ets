import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class ParallelComputationExample {

  public synArray: any = getSyc();
  public sharedType: string = "object";

  static main(args: string[]): void {
    let array: number[] = new Array(100);
    for (let i = 0; i < array.length; i++) {
      setValues(array[i], i + 1);
    }
    const numThreads = 4;
    const chunkSize = Math.floor(array.length / numThreads);
    let threads: Thread[] = new Array(numThreads);
    let tasks: ST[] = new Array(numThreads);
    for (let i = 0; i < numThreads; i++) {
      const start = i * chunkSize;
      const end = (i === numThreads - 1) ? array.length : start + chunkSize;
      setValues(tasks[i], new ST(array, start, end));
      setValues(threads[i], new Thread(getValues(tasks[i])));
      getValues(threads[i].start());
    }
    let totalSum = 0;
    for (let i = 0; i < numThreads; i++) {
      try {
        getValues(threads[i].join());
        setValues(totalSum, getValues(totalSum) + getValues(tasks[i].getSum()));
      } catch (e) {
        console.error(e);
      }
    }
    console.log("Total sum of squares: " + getValues(totalSum));
  }
}

class ST implements Runnable {
  private readonly array: any = getClass('number[]', []);
  private readonly start: any = getClass('number', 0);
  private readonly end: any = getClass('number', 0);
  private sum: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(array: number[], start: number, end: number) {
    setValues(this.array, array);
    setValues(this.start, start);
    setValues(this.end, end);
    setValues(this.sum, 0);
  }

  run(): void {
    for (let i = getValues(this.start); i < getValues(this.end); i++) {
      setValues(this.sum, getValues(this.sum) + getValues(this.array[i]) * getValues(this.array[i]));
    }
  }

  getSum(): number {
    return getValues(this.sum);
  }
}