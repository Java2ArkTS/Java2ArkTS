import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Smokers {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const thread1 = new Thread(new P1(semaphores));
        const thread2 = new Thread(new P2(semaphores));
        const thread3 = new Thread(new P3(semaphores));
        const thread4 = new Thread(new P4(semaphores));
        getValues(thread1.start());
        getValues(thread2.start());
        getValues(thread3.start());
        getValues(thread4.start());
    }
}

class Semaphores {
    public synArray: any = getSyc();
    public sharedType: string = "object";
    public num: any = getClass('number', 0);
    public offer1: any = getClass('boolean', false);
    public offer2: any = getClass('boolean', false);
    public offer3: any = getClass('boolean', false);
    public finish: any = getClass('boolean', false);

    public V_offer1(): void {
        SynStart(getValues(this['synArray']));
        setValues(this.offer1, true);
        SynEnd(getValues(this['synArray']));
    }

    public V_offer2(): void {
        SynStart(getValues(this['synArray']));
        setValues(this.offer2, true);
        SynEnd(getValues(this['synArray']));
    }

    public V_offer3(): void {
        SynStart(getValues(this['synArray']));
        setValues(this.offer3, true);
        SynEnd(getValues(this['synArray']));
    }

    public V_finish(): void {
        SynStart(getValues(this['synArray']));
        setValues(this.finish, true);
        SynEnd(getValues(this['synArray']));
    }

    public P_finish(): boolean {
        SynStart(getValues(this['synArray']));
        if (getValues(this.finish)) {
            setValues(this.finish, false);
            SynEnd(getValues(this['synArray']));
            return true;
        } else {
            SynEnd(getValues(this['synArray']));
            return false;
        }
    }

    public P_offer1(): boolean {
        SynStart(getValues(this['synArray']));
        if (getValues(this.offer1)) {
            setValues(this.offer1, false);
            SynEnd(getValues(this['synArray']));
            return true;
        } else {
            SynEnd(getValues(this['synArray']));
            return false;
        }
    }

    public P_offer2(): boolean {
        SynStart(getValues(this['synArray']));
        if (getValues(this.offer2)) {
            setValues(this.offer2, false);
            SynEnd(getValues(this['synArray']));
            return true;
        } else {
            SynEnd(getValues(this['synArray']));
            return false;
        }
    }

    public P_offer3(): boolean {
        SynStart(getValues(this['synArray']));
        if (getValues(this.offer3)) {
            setValues(this.offer3, false);
            SynEnd(getValues(this['synArray']));
            return true;
        } else {
            SynEnd(getValues(this['synArray']));
            return false;
        }
    }
}

class P1 implements Runnable {
    public semaphores: any = getClass('Semaphores', null);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores) {
        setValues(this.semaphores, semaphores);
    }

    public run(): void {
        while (true) {
            setValues(this.semaphores.num, getValues(this.semaphores.num) + 1);
            setValues(this.semaphores.num, getValues(this.semaphores.num) % 3);
            if (getValues(this.semaphores.num) === 0) {
                getValues(this.semaphores.V_offer1());
            } else if (getValues(this.semaphores.num) === 1) {
                getValues(this.semaphores.V_offer2());
            } else {
                getValues(this.semaphores.V_offer3());
            }
            console.log("P1 put things onto the table.");
            while (!getValues(this.semaphores.P_finish())) {
            }
        }
    }
}

class P2 implements Runnable {
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores) {
        setValues(this.semaphores, semaphores);
    }

    public run(): void {
        while (true) {
            while (!getValues(this.semaphores.P_offer3())) {
            }
            console.log("P2 is smoking.");
            getValues(this.semaphores.V_finish());
        }
    }
}

class P3 implements Runnable {
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores) {
        setValues(this.semaphores, semaphores);
    }

    public run(): void {
        while (true) {
            while (!getValues(this.semaphores.P_offer2())) {
            }
            console.log("P3 is smoking.");
            getValues(this.semaphores.V_finish());
        }
    }
}

class P4 implements Runnable {
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores) {
        setValues(this.semaphores, semaphores);
    }

    public run(): void {
        while (true) {
            while (!getValues(this.semaphores.P_offer1())) {
            }
            console.log("P4 is smoking.");
            getValues(this.semaphores.V_finish());
        }
    }
}