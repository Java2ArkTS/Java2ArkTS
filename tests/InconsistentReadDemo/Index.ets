import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class InconsistentReadDemo {
    count: any = getClass('number', 1);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]) {
        const demo = new InconsistentReadDemo();
        const thread = new Thread(new ConcurrencyCheckTask(demo));
        thread.start();
        while (true) {
            setValues(demo.count, getValues(demo.count) + 1);
        }
    }
}

class ConcurrencyCheckTask implements Runnable {
    private demo: InconsistentReadDemo;

    constructor(demo: InconsistentReadDemo) {
        this.demo = demo;
    }

    public run() {
        // Implement the logic for the task
    }
}

class ConcurrencyCheckTask implements Runnable {

    public synArray: any = getSyc();
    public sharedType: string = "object";

    private demo: any = getClass('InconsistentReadDemo', new InconsistentReadDemo());

    constructor(demo: InconsistentReadDemo) {
        setValues(this.demo, demo);
    }

    run(): void {
        let c = 0;
        for (let i = 0; ; i++) {
            const c1 = getValues(this.demo.count);
            const c2 = getValues(this.demo.count);
            if (c1 !== c2) {
                c++;
                console.error(`Inconsistent read observed!! Check time=${i + 1}, Occurrence=${c} (${(c / (i + 1) * 100)}%), 1=${c1}, 2=${c2}`);
            }
        }
    }
}