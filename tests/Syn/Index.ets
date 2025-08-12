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
  if (runnable.className === 'TestThread') {
    archetype = new TestThread();
  } else if (runnable.className === 'Syn') {
    archetype = new Syn();
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class TestThread implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'TestThread';

  private tickets = new SharedNumber(10000);

  run(): void {
    while (true) {
      this.sale();
    }
  }

  sale(): void {
    {
      SynStart(this.syn);
      if (this.tickets.getValue() > 0) {
        if (this.tickets.getValue() % 100 === 0) {
          console.log('is sailing ticket' + this.tickets.getValue());
        }
        this.tickets.setValue(this.tickets.getValue() - 1);
      }
      SynEnd(this.syn);
    }
  }

  sum(a: number, b: number): number {
    return a + b;
  }
}

export class Syn implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Syn';

  run(): void {
    // Implementation for Syn's run method
  }

  public static main(args: string[]): void {
    const tt = new TestThread();
    new Thread(tt).start();
    new Thread(tt).start();
    new Thread(tt).start();
    new Thread(tt).start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}