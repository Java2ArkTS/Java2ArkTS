import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class ConcurrencyCheckTask1 implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  run(): void {
    console.log("ConcurrencyCheckTask1 started!");
    while (true) {
      {
        SynStart(getValues(lock1['synArray']));
        {
          SynStart(getValues(lock2['synArray']));
          console.log("Hello1");
          SynEnd(getValues(lock2['synArray']));
        }
        SynEnd(getValues(lock1['synArray']));
      }
    }
  }
}

class SimpleThreadExample {
  private static counter: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const thread1: Thread = new Thread(new SimpleThreadExample.CounterIncrementer());
    const thread2: Thread = new Thread(new SimpleThreadExample.CounterIncrementer());
    thread1.start();
    thread2.start();
    console.log("Final counter value: " + getValues(SimpleThreadExample.counter));
  }

  static CounterIncrementer = class implements Runnable {
    run(): void {
      for (let i = 0; i < 1000; i++) {
        getValues(this.incrementCounter());
      }
    }

    private incrementCounter(): void {
      SynStart(SimpleThreadExample.CounterIncrementer);
      try {
        setValues(SimpleThreadExample.counter, getValues(SimpleThreadExample.counter) + 1);
      } finally {
        SynEnd(SimpleThreadExample.CounterIncrementer);
      }
    }
  }
}

import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

const ADD_COUNT = 10000;

class Listener {}

class SynchronizationOnMutableFieldDemo {
  private listeners: any = getClass('Listener[]', []);
  private size: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  static async main(args: string[]): Promise<void> {
    const demo = new SynchronizationOnMutableFieldDemo();
    const thread1 = new Thread(demo.getConcurrencyCheckTask());
    thread1.start();
    const thread2 = new Thread(demo.getConcurrencyCheckTask());
    thread2.start();

    await thread1.join();
    await thread2.join();

    const actualSize = getValues(demo.size);
    const expectedSize = ADD_COUNT * 2;
    if (getValues(actualSize) !== expectedSize) {
      console.error(`Lost update on mutable field! actual ${getValues(actualSize)} expected ${expectedSize}.`);
    } else {
      console.log("Got the expected size!");
    }
  }

  addListener(listener: Listener): void {
    SynStart(this['synArray']);
    if (getValues(this.size) === this.listeners.length) {
      const newCapacity = (this.listeners.length === 0) ? 1 : this.listeners.length * 2;
      const newListeners = new Array<Listener>(newCapacity);
      for (let i = 0; i < getValues(this.size); i++) {
        newListeners[i] = this.listeners[i];
      }
      setValues(this.listeners, newListeners);
    }
    setValues(this.listeners[getValues(this.size)++], listener);
    SynEnd(this['synArray']);
  }

  getConcurrencyCheckTask(): Runnable {
    return new ConcurrencyCheckTask(this);
  }

  private class ConcurrencyCheckTask implements Runnable {
    private parent: any = getClass('SynchronizationOnMutableFieldDemo', parent);

    constructor(parent: SynchronizationOnMutableFieldDemo) {
      this.parent = parent;
    }

    run(): void {
      console.log("ConcurrencyCheckTask started!");
      for (let i = 0; i < ADD_COUNT; ++i) {
        getValues(this.parent.addListener(new Listener()));
      }
      console.log("ConcurrencyCheckTask stopped!");
    }
  }
}