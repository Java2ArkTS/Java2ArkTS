import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class OddEven {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const p1 = new Thread(new P1(semaphores));
        const p2 = new Thread(new P2(semaphores));
        const p3 = new Thread(new P3(semaphores));
        getValues(p1.start());
        getValues(p2.start());
        getValues(p3.start());
    }
}


class Semaphores {

    public synArray : any = getSyc();
    public sharedType: string = "object";

    public mutex: any = getClass('boolean', true);

    public odd: any = getClass('number', 0);

    public even: any = getClass('number', 0);

    public empty: any = getClass('number', 5);

    public pMutex(): boolean {
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

    public pOdd(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.odd) > 0) {
            setValues(this.odd, getValues(this.odd) - 1);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public pEven(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.even) > 0) {
            setValues(this.even, getValues(this.even) - 1);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public pEmpty(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.empty) > 0) {
            setValues(this.empty, getValues(this.empty) - 1);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public vMutex(): void {
        SynStart(this['synArray']);
        setValues(this.mutex, true);
        SynEnd(this['synArray']);
    }

    public vOdd(): void {
        SynStart(this['synArray']);
        setValues(this.odd, getValues(this.odd) + 1);
        SynEnd(this['synArray']);
    }

    public vEven(): void {
        SynStart(this['synArray']);
        setValues(this.even, getValues(this.even) + 1);
        SynEnd(this['synArray']);
    }

    public vEmpty(): void {
        SynStart(this['synArray']);
        setValues(this.empty, getValues(this.empty) + 1);
        SynEnd(this['synArray']);
    }
}


class P1 implements Runnable {

    public semaphores: any = getClass('Semaphores', new Semaphores());
    public x: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores) {
        setValues(this.semaphores, semaphores);
    }

    run() {
        while (true) {
            while (!getValues(this.semaphores.pEmpty())) {}
            while (!getValues(this.semaphores.pMutex())) {}
            console.log("P1 puts a number.");
            getValues(this.semaphores.vMutex());
            if (getValues(this.x)++ % 2 === 0) {
                getValues(this.semaphores.vEven());
            } else {
                getValues(this.semaphores.vOdd());
            }
        }
    }
}


class P2 implements Runnable {

    public synArray: any = getSyc();
    public sharedType: string = "object";
    public semaphores: any = getClass('Semaphores', undefined);

    constructor(semaphores: Semaphores) {
        setValues(this.semaphores, semaphores);
    }

    run() {
        while (true) {
            while (!getValues(this.semaphores.pOdd())) {
            }
            while (!getValues(this.semaphores.pMutex())) {
            }
            console.log("P2 gets an odd number.");
            getValues(this.semaphores.vMutex());
            getValues(this.semaphores.vEmpty());
            console.log("P2 counts an odd number.");
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
            while (!getValues(this.semaphores.pEven())) {
            }
            while (!getValues(this.semaphores.pMutex())) {
            }
            console.log(getValues("P3 gets an even number."));
            getValues(this.semaphores.vMutex());
            getValues(this.semaphores.vEmpty());
            console.log(getValues("P3 counts an even number."));
        }
    }
}