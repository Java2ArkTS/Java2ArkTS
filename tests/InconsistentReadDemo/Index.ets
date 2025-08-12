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
  if (runnable.className === 'ConcurrencyCheckTask') {
    archetype = new ConcurrencyCheckTask(new InconsistentReadDemo());
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

export class InconsistentReadDemo {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'InconsistentReadDemo';

  count = new SharedNumber(1);

  static main(args: string[]): void {
    const demo = new InconsistentReadDemo();
    const thread = new Thread(new ConcurrencyCheckTask(demo));
    thread.start();
    while (true) {
      demo.count.setValue(demo.count.getValue() + 1);
    }
  }
}

class ConcurrencyCheckTask implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ConcurrencyCheckTask';

  private demo: InconsistentReadDemo;

  constructor(demo: InconsistentReadDemo) {
    this.demo = demo;
  }

  run(): void {
    let c = 0;
    for (let i = 0; ; i++) {
      const c1 = this.demo.count; // No transformation here as `count` belongs to `demo`, not this class.
      const c2 = this.demo.count; // No transformation here as `count` belongs to `demo`, not this class.
      if (c1 !== c2) {
        c++;
        console.error(
          `Inconsistent read observed!! Check time=${i + 1}, Occurrence=${c} (${(
            (c / (i + 1)) *
            100
          ).toFixed(2)}%), 1=${c1}, 2=${c2}`
        );
      }
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}