import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class DiningPhilosophers {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const mutexes = new Mutexes();
        const thread0 = new Thread(new Pi(mutexes, 0));
        const thread1 = new Thread(new Pi(mutexes, 1));
        const thread2 = new Thread(new Pi(mutexes, 2));
        const thread3 = new Thread(new Pi(mutexes, 3));
        const thread4 = new Thread(new Pi(mutexes, 4));
        getValues(thread0.start());
        getValues(thread1.start());
        getValues(thread2.start());
        getValues(thread3.start());
        getValues(thread4.start());
    }
}

class Mutexes {
    public chopsticks: any = getClass('boolean[]', [true, true, true, true, true]);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public getLeftChopstick(i: number): boolean {
        SynStart(getValues(this['synArray']));
        if (getValues(this.chopsticks[i])) {
            setValues(this.chopsticks[i], false);
            SynEnd(getValues(this['synArray']));
            return true;
        } else {
            SynEnd(getValues(this['synArray']));
            return false;
        }
    }

    public getRightChopstick(i: number): boolean {
        SynStart(getValues(this['synArray']));
        if (getValues(this.chopsticks[(i + 1) % 5])) {
            setValues(this.chopsticks[(i + 1) % 5], false);
            SynEnd(getValues(this['synArray']));
            return true;
        } else {
            SynEnd(getValues(this['synArray']));
            return false;
        }
    }

    public returnChopsticks(i: number): void {
        SynStart(getValues(this['synArray']));
        setValues(this.chopsticks[i], true);
        setValues(this.chopsticks[(i + 1) % 5], true);
        SynEnd(getValues(this['synArray']));
    }
}

class Pi implements Runnable {
    public mutexes: any = getClass('Mutexes', new Mutexes());
    public i: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(mutexes: Mutexes, i: number) {
        setValues(this.mutexes, mutexes);
        setValues(this.i, i);
    }

    public run(): void {
        while (true) {
            getValues(this.mutexes.getLeftChopstick(getValues(this.i)));
            getValues(this.mutexes.getRightChopstick(getValues(this.i)));
            console.log("P" + getValues(this.i) + " is eating.");
            getValues(this.mutexes.returnChopsticks(getValues(this.i)));
            console.log("P" + getValues(this.i) + " is thinking.");
        }
    }
}