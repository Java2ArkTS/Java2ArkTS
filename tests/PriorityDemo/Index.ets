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

  if (runnable.className === 'HightPriority') {
    archetype = new HightPriority();
  } else if (runnable.className === 'LowPriority') {
    archetype = new LowPriority();
  } else {
    archetype = new Thread();
  }

  addFunc(runnable, archetype);
  runnable.run();
}

export class PriorityDemo {
  public static count = new SharedNumber(0);

  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'PriorityDemo';

  public static main(args: string[]): void {
    const high: Thread = new HightPriority();
    const low: Thread = new LowPriority();
    low.start();
    high.start();
  }
}

class HightPriority extends Thread {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'HightPriority';

  run(): void {
    while (true) {
      {
        SynStart(this.syn);
        PriorityDemo.count.setValue(PriorityDemo.count.getValue() + 1);
        if (PriorityDemo.count.getValue() > 1000000) {
          console.log('HightPriority is complete!');
          SynEnd(this.syn);
          break;
        }
        SynEnd(this.syn);
      }
    }
  }
}

class LowPriority extends Thread {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'LowPriority';

  run(): void {
    while (true) {
      {
        SynStart(this.syn);
        PriorityDemo.count.setValue(PriorityDemo.count.getValue() + 1);
        if (PriorityDemo.count.getValue() > 1000000) {
          console.log('LowPriority is complete!');
          SynEnd(this.syn);
          break;
        }
        SynEnd(this.syn);
      }
    }
  }
}

if (isMainThread()) {
  PriorityDemo.main([]);
}