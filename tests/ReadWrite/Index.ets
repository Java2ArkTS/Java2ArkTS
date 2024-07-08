import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number) {
    let archetype = Thread.runnableList[threadId];
    archetype.run();
}

class ReadWrite {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const thread0 = new Thread(new Reader(getValues(semaphores), 0));
        const thread1 = new Thread(new Reader(getValues(semaphores), 1));
        const thread2 = new Thread(new Thread(new Reader(getValues(semaphores), 2)));
        const thread3 = new Thread(new Writer(getValues(semaphores), 3));
        const thread4 = new Thread(new Writer(getValues(semaphores), 4));
        getValues(thread0.start());
        getValues(thread1.start());
        getValues(thread2.start());
        getValues(thread3.start());
        getValues(thread4.start());
    }
}

class Semaphores {
    public count: any = getClass('number', 0);
    public rw: any = getClass('boolean', true);
    public w: any = getClass('boolean', true);
    public mutex: any = getClass('boolean', true);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor() {
        setValues(this.count, 0);
        setValues(this.rw, true);
        setValues(this.w, true);
        setValues(this.mutex, true);
    }

    public Pw(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.w)) {
            setValues(this.w, false);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public Pmutex(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.mutex)) {
            setValues(this.mutex, false);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public Prw(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.rw)) {
            setValues(this.rw, false);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public Vmutex(): void {
        SynStart(this['synArray']);
        setValues(this.mutex, true);
        SynEnd(this['synArray']);
    }

    public Vw(): void {
        SynStart(this['synArray']);
        setValues(this.w, true);
        SynEnd(this['synArray']);
    }

    public Vrw(): void {
        SynStart(this['synArray']);
        setValues(this.rw, true);
        SynEnd(this['synArray']);
    }
}

class Reader implements Runnable {
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public rank: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores, rank: number) {
        setValues(this.semaphores, semaphores);
        setValues(this.rank, rank);
    }

    public run(): void {
        while (true) {
            while (!getValues(this.semaphores.Pw())) {
            }
            while (!getValues(this.semaphores.Pmutex())) {
            }
            if (getValues(this.semaphores.count) === 0) {
                while (!getValues(this.semaphores.Prw())) {
                }
            }
            setValues(this.semaphores.count, getValues(this.semaphores.count) + 1);
            getValues(this.semaphores.Vmutex());
            getValues(this.semaphores.Vw());
            console.log("Thread " + getValues(this.rank) + " is reading.");
            while (!getValues(this.semaphores.Pmutex())) {
            }
            setValues(this.semaphores.count, getValues(this.semaphores.count) - 1);
            if (getValues(this.semaphores.count) === 0) {
                getValues(this.semaphores.Vrw());
            }
            getValues(this.semaphores.Vmutex());
        }
    }
}

class Writer implements Runnable {
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public rank: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores, rank: number) {
        setValues(this.semaphores, semaphores);
        setValues(this.rank, rank);
    }

    public run(): void {
        while (true) {
            while (!getValues(this.semaphores.Pw())) {
            }
            while (!getValues(this.semaphores.Prw())) {
            }
            console.log("Thread " + getValues(this.rank) + " is writing.");
            getValues(this.semaphores.Vrw());
            getValues(this.semaphores.Vw());
        }
    }
}