import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number) {
    let archetype = Thread.runnableList[threadId];
    archetype.run();
}

class Counter implements Runnable {
    private count: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public increment(): void {
        {
            SynStart(1, this.synArray);
            setValues(this.count, getValues(this.count) + 1);
            SynEnd(1, this.synArray);
        }
    }

    public getCount(): number {
        {
            SynStart(2, this.synArray);
            const result = getValues(this.count);
            SynEnd(2, this.synArray);
            return result;
        }
    }

    public run(): void {
        for (let i = 0; i < 10000; i++) {
            this.increment();
        }
    }
}

class ThreadExample {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const counter = new Counter();
        const thread1 = new Thread(counter);
        const thread2 = new Thread(counter);
        thread1.start();
        thread2.start();
    }
}