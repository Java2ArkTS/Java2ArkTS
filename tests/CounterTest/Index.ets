import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "DecrementTask") {
    archetype = new DecrementTask(new Counter());
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Counter {
  private count = new SharedNumber(0);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Counter";

  public increment(): void {
    {
      SynStart(this.syn);
      this.count.setValue(this.count.getValue() + 1);
      console.log(" incremented count to " + this.count.getValue());
      SynEnd(this.syn);
    }
  }

  public decrement(): void {
    {
      SynStart(this.syn);
      this.count.setValue(this.count.getValue() - 1);
      console.log(" decremented count to " + this.count.getValue());
      SynEnd(this.syn);
    }
  }

  public getCount(): number {
    {
      SynStart(this.syn);
      const result = this.count.getValue();
      SynEnd(this.syn);
      return result;
    }
  }
}

class ExampleClass {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "ExampleClass";

  constructor() {
    // constructor logic
  }

  someMethod() {
    // method logic
  }
}

class DecrementTask implements Runnable {
  private counter: Counter;
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "DecrementTask";

  constructor(counter: Counter) {
    this.counter = counter;
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      this.counter.decrement();
    }
  }
}

class CounterTest {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "CounterTest";

  public static main(args: string[]): void {
    const counter = new Counter();
    const incrementThread = new Thread(new IncrementTask(counter));
    const decrementThread = new Thread(new DecrementTask(counter));
    incrementThread.start();
    decrementThread.start();
    console.log("Final count: " + counter.getCount());
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}