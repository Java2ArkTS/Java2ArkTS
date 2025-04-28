import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class TestThread implements Runnable {
    private tickets: any = getClass('number', 10000);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public run(): void {
        while (true) {
            this.sale();
        }
    }

    public sale(): void {
        SynStart(1, this.synArray);
        if (getValues(this.tickets) > 0) {
            if (getValues(this.tickets) % 100 === 0) {
                console.log("is sailing ticket" + getValues(this.tickets));
            }
            setValues(this.tickets, getValues(this.tickets) - 1);
        }
        SynEnd(1, this.synArray);
    }

    public sum(a: number, b: number): number {
        return a + b;
    }
}

class Syn {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const tt = new TestThread();
        new Thread(tt).start();
        new Thread(tt).start();
        new Thread(tt).start();
        new Thread(tt).start();
    }
}