import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "CounterIncrementer") {
    archetype = new CounterIncrementer();
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class CounterIncrementer implements Runnable {
    private counter = new SharedNumber(0);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "CounterIncrementer";

    run(): void {
        for (let i = 0; i < 1000; i++) {
            this.incrementCounter();
        }
    }

    private incrementCounter(): void {
        {
            SynStart(this.syn);
            this.counter.setValue(this.counter.getValue() + 1);
            SynEnd(this.syn);
        }
    }
}

class SimpleThreadExample {
    private static counter = new SharedNumber(0);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "SimpleThreadExample";

    public static main(args: string[]): void {
        const thread1 = new Thread(new CounterIncrementer());
        const thread2 = new Thread(new CounterIncrementer());
        thread1.start();
        thread2.start();
        console.log("Final counter value: " + SimpleThreadExample.counter.getValue());
    }

    static class CounterIncrementer implements Runnable {
        run(): void {
            for (let i = 0; i < 1000; i++) {
                this.incrementCounter();
            }
        }

        private incrementCounter(): void {
            Syc.lock(SimpleThreadExample);
            try {
                SimpleThreadExample.counter.setValue(SimpleThreadExample.counter.getValue() + 1);
            } finally {
                Syc.unlock(SimpleThreadExample);
            }
        }
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}