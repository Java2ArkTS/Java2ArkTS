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
  if (runnable.className === 'Counter') {
    archetype = new Counter();
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Counter implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Counter';

  private count = new SharedNumber(0);

  public increment(): void {
    {
      SynStart(this.syn);
      this.count.setValue(this.count.getValue() + 1);
      SynEnd(this.syn);
    }
  }

  public getCount(): number {
    {
      SynStart(this.syn);
      return this.count.getValue();
      SynEnd(this.syn);
    }
  }

  run(): void {
    for (let i = 0; i < 10000; i++) {
      this.increment();
    }
  }
}

class ThreadExample {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ThreadExample';

  static main(args: string[]): void {
    const counter = new Counter();
    const thread1 = new Thread(counter);
    const thread2 = new Thread(counter);
    thread1.start();
    thread2.start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}