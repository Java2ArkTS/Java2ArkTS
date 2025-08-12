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

  if (runnable.className === 'ConcurrencyCheckTask1') {
    archetype = new ConcurrencyCheckTask1();
  } else if (runnable.className === 'ConcurrencyCheckTask2') {
    archetype = new ConcurrencyCheckTask2();
  } else {
    archetype = new Thread();
  }

  addFunc(runnable, archetype);
  runnable.run();
}

class ConcurrencyCheckTask1 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ConcurrencyCheckTask1';

  run(): void {
    console.log('ConcurrencyCheckTask1 started!');
    while (true) {
      {
        SynStart(lock1.syn);
        {
          SynStart(lock2.syn);
          console.log('Hello1');
          SynEnd(lock2.syn);
        }
        SynEnd(lock1.syn);
      }
    }
  }
}

class ConcurrencyCheckTask2 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ConcurrencyCheckTask2';

  run(): void {
    console.log('ConcurrencyCheckTask2 started!');
    while (true) {
      {
        SynStart(lock2.syn);
        {
          SynStart(lock1.syn);
          console.log('Hello2');
          SynEnd(lock1.syn);
        }
        SynEnd(lock2.syn);
      }
    }
  }
}

export class SymmetricLockDeadlockDemo {
  static readonly lock1 = {};
  static readonly lock2 = {};

  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'SymmetricLockDeadlockDemo';

  public static async main(): Promise<void> {
    const thread1 = new Thread(new ConcurrencyCheckTask1());
    thread1.start();
    const thread2 = new Thread(new ConcurrencyCheckTask2());
    thread2.start();
  }
}

// threadAble_class
class ConcurrencyCheckTask1 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ConcurrencyCheckTask1';

  run(): void {
    console.log('ConcurrencyCheckTask1 started!');
    while (true) {
      synchronized(SymmetricLockDeadlockDemo.lock1, () => {
        synchronized(SymmetricLockDeadlockDemo.lock2, () => {
          console.log('Hello1');
        });
      });
    }
  }
}

// threadAble_class
class ConcurrencyCheckTask2 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ConcurrencyCheckTask2';

  run(): void {
    console.log('ConcurrencyCheckTask2 started!');
    while (true) {
      synchronized(SymmetricLockDeadlockDemo.lock2, () => {
        synchronized(SymmetricLockDeadlockDemo.lock1, () => {
          console.log('Hello2');
        });
      });
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}