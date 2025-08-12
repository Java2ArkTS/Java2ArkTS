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
  if (runnable.className === 'AdderTask') {
    archetype = new AdderTask(new Accumulator(), 0);
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Accumulator {
  private sum = new SharedNumber(0);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Accumulator';

  public addToSum(value: number): void {
    {
      SynStart(this.syn);
      this.sum.setValue(this.sum.getValue() + value);
      console.log(` added ${value}. Current sum: ${this.sum.getValue()}`);
      SynEnd(this.syn);
    }
  }

  public getSum(): number {
    {
      SynStart(this.syn);
      const result = this.sum.getValue();
      SynEnd(this.syn);
      return result;
    }
  }
}

class AdderTask implements Runnable {
  private accumulator: Accumulator;
  private valueToAdd = new SharedNumber();
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'AdderTask';

  constructor(accumulator: Accumulator, valueToAdd: number) {
    this.accumulator = accumulator;
    this.valueToAdd.setValue(valueToAdd);
  }

  run(): void {
    this.accumulator.addToSum(this.valueToAdd.getValue());
  }
}

class MultiThreadAccumulator {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'MultiThreadAccumulator';

  static main(args: string[]): void {
    const accumulator = new Accumulator();
    const thread1 = new Thread(new AdderTask(accumulator, 5));
    const thread2 = new Thread(new AdderTask(accumulator, 10));
    thread1.start();
    thread2.start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}