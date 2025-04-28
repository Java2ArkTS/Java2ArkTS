import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class CounterIncrementer implements Runnable {
    public synArray: any = getSyc();
    public sharedType: string = "object";
    private synArray: any = {}; 

    run(): void {
        for (let i = 0; i < 1000; i++) {
            getValues(this.incrementCounter());
        }
    }

    private incrementCounter(): void {
        SynStart(this.synArray);
        setValues(counter, getValues(counter) + 1);
        SynEnd(this.synArray);
    }
}

class SimpleThreadExample {
    private static counter: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const thread1 = new Thread(new SimpleThreadExample.CounterIncrementer());
        const thread2 = new Thread(new SimpleThreadExample.CounterIncrementer());
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
            const obj = getClass(SimpleThreadExample);
            synchronized(obj, () => {
                setValues(SimpleThreadExample.counter, getValues(SimpleThreadExample.counter) + 1);
            });
        }
    }
}