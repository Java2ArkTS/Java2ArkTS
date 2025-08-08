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
  Thread
} from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "HightPriority") {
    archetype = new HightPriority();
  } else if (runnable.className == "LowPriority") {
    archetype = new LowPriority();
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

export class PriorityDemo {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "PriorityDemo";
  
  public static count = new SharedNumber(0);
  
  public static main(args: string[]): void {
    const high: Thread = new HightPriority();
    const low: Thread = new LowPriority();
    high.setPriority(Thread.MAX_PRIORITY);
    low.setPriority(Thread.MIN_PRIORITY);
    low.start();
    high.start();
  }
}

class HightPriority extends Thread {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "HightPriority";
  
  public run(): void {
    while (true) {
      {
        SynStart(PriorityDemo.syn);
        PriorityDemo.count++;
        if (PriorityDemo.count > 1000000) {
          console.log("HightPriority is complete!");
          break;
        }
        SynEnd(PriorityDemo.syn);
      }
    }
  }
}

class LowPriority extends Thread {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "LowPriority";
  
  public run(): void {
    while (true) {
      {
        SynStart(PriorityDemo.syn);
        PriorityDemo.count.setValue(PriorityDemo.count.getValue() + 1);
        if (PriorityDemo.count.getValue() > 1000000) {
          console.log("LowPriority is complete!");
          break;
        }
        SynEnd(PriorityDemo.syn);
      }
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}