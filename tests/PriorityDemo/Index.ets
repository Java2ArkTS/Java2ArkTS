import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

export class PriorityDemo {
  public static count: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const high = new HighPriority();
    const low = new LowPriority();
    setValues(high.setPriority, getValues(Thread.MAX_PRIORITY));
    setValues(low.setPriority, getValues(Thread.MIN_PRIORITY));
    getValues(low.start());
    getValues(high.start());
  }
}

class HighPriority extends Thread {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public run(): void {
    while (true) {
      synchronized(PriorityDemo, () => {
        getValues(synchronize_method1());
      });
    }
  }
}

class LowPriority extends Thread {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public run(): void {
    while (true) {
      synchronized(PriorityDemo, () => {
        getValues(synchronize_method2());
      });
    }
  }
}

function synchronize_method1(): void {
  // 高优先级线程执行的逻辑
}

function synchronize_method2(): void {
  // 低优先级线程执行的逻辑
}

class HightPriority extends Thread {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public run() {
    while (true) {
      {
        SynStart(PriorityDemo.synArray);
        setValues(PriorityDemo.count, getValues(PriorityDemo.count) + 1);
        if (getValues(PriorityDemo.count) > 1000000) {
          console.log("HightPriority is complete!");
          SynEnd(PriorityDemo.synArray);
          break;
        }
        SynEnd(PriorityDemo.synArray);
      }
    }
  }
}

class LowPriority extends Thread {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public run() {
    while (true) {
      {
        getValues(SynStart(PriorityDemo['synArray']));
        setValues(PriorityDemo.count, getValues(PriorityDemo.count) + 1);
        if (getValues(PriorityDemo.count) > 1000000) {
          console.log("LowPriority is complete!");
          getValues(SynEnd(PriorityDemo['synArray']));
          break;
        }
        getValues(SynEnd(PriorityDemo['synArray']));
      }
    }
  }
}