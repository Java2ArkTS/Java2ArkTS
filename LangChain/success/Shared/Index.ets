import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Counter {

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
}

class Task implements Runnable {

    private counter: any = getClass('Counter', new Counter());
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(counter: Counter) {
        setValues(this.counter, counter);
    }

    run(): void {
        for (let i = 0; i < 1000; i++) {
            this.counter.increment();
        }
    }
}

class Main {
    public synArray : any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const counter = new Counter();
        const t1 = new Thread(new Task(counter));
        const t2 = new Thread(new Task(counter));
        t1.start();
        t2.start();
        console.log("increment", counter.getCount());
    }
}