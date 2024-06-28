import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Counter {

  private count: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public increment(): void {
    SynStart(1, this.synArray);
    setValues(this.count, getValues(this.count) + 1);
    console.log(" incremented count to " + getValues(this.count));
    SynEnd(1, this.synArray);
  }

  public decrement(): void {
    SynStart(2, this.synArray);
    setValues(this.count, getValues(this.count) - 1);
    console.log(" decremented count to " + getValues(this.count));
    SynEnd(2, this.synArray);
  }

  public getCount(): number {
    let result: number;
    SynStart(3, this.synArray);
    setValues(result, getValues(this.count));
    SynEnd(3, this.synArray);
    return getValues(result);
  }
}

class IncrementTask implements Runnable {

  private counter: any = getClass('Counter', new Counter());
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(counter: Counter) {
    setValues(this.counter, counter);
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      getValues(this.counter.increment());
    }
  }
}

class DecrementTask implements Runnable {

  private counter: any = getClass('Counter', new Counter());
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(counter: Counter) {
    setValues(this.counter, counter);
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      getValues(this.counter.decrement());
    }
  }
}

class CounterTest {

  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const counter = new Counter();
    const incrementTask = new IncrementTask(counter);
    const decrementTask = new DecrementTask(counter);
    const incrementThread = new Thread(incrementTask);
    const decrementThread = new Thread(decrementTask);
    incrementThread.start();
    decrementThread.start();
    console.log("Final count: " + getValues(counter.getCount()));
  }
}