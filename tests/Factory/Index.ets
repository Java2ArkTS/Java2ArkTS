import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Factory {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const workshopA = new Thread(new WorkshopA(semaphores));
        const workshopB = new Thread(new WorkshopB(semaphores));
        const workshopAsm = new Thread(new WorkshopAsm(semaphores));
        getValues(workshopA.start());
        getValues(workshopB.start());
        getValues(workshopAsm.start());
    }
}

class Semaphores {
    public empty1: any = getClass('number', 10);
    public full1: any = getClass('number', 0);
    public empty2: any = getClass('number', 10);
    public full2: any = getClass('number', 0);
    public mutex1: any = getClass('boolean', true);
    public mutex2: any = getClass('boolean', true);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public P_empty1(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.empty1) > 0) {
            setValues(this.empty1, getValues(this.empty1) - 1);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public P_empty2(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.empty2) > 0) {
            setValues(this.empty2, getValues(this.empty2) - 1);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public P_full1(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.full1) > 0) {
            setValues(this.full1, getValues(this.full1) - 1);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public P_full2(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.full2) > 0) {
            setValues(this.full2, getValues(this.full2) - 1);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public P_mutex1(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.mutex1)) {
            setValues(this.mutex1, false);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public P_mutex2(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.mutex2)) {
            setValues(this.mutex2, false);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public V_empty1(): void {
        SynStart(this['synArray']);
        setValues(this.empty1, getValues(this.empty1) + 1);
        SynEnd(this['synArray']);
    }

    public V_empty2(): void {
        SynStart(this['synArray']);
        setValues(this.empty2, getValues(this.empty2) + 1);
        SynEnd(this['synArray']);
    }

    public V_full1(): void {
        SynStart(this['synArray']);
        setValues(this.full1, getValues(this.full1) + 1);
        SynEnd(this['synArray']);
    }

    public V_full2(): void {
        SynStart(this['synArray']);
        setValues(this.full2, getValues(this.full2) + 1);
        SynEnd(this['synArray']);
    }

    public V_mutex1(): void {
        SynStart(this['synArray']);
        setValues(this.mutex1, true);
        SynEnd(this['synArray']);
    }

    public V_mutex2(): void {
        SynStart(this['synArray']);
        setValues(this.mutex2, true);
        SynEnd(this['synArray']);
    }
}

class WorkshopA implements Runnable {
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores) {
        setValues(this.semaphores, semaphores);
    }

    public run(): void {
        while (true) {
            console.log("Workshop A produces a production A.");
            while (!getValues(this.semaphores.P_empty1())) {}
            while (!getValues(this.semaphores.P_mutex1())) {}
            console.log("Workshop A puts a production A onto the shelf F1.");
            getValues(this.semaphores.V_mutex1());
            getValues(this.semaphores.V_full1());
        }
    }
}

class WorkshopB implements Runnable {
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores) {
        setValues(this.semaphores, semaphores);
    }

    public run(): void {
        while (true) {
            console.log("Workshop B produces a production B.");
            while (!getValues(this.semaphores.P_empty2())) {}
            while (!getValues(this.semaphores.P_mutex2())) {}
            console.log("Workshop B puts a production B onto the shelf F2.");
            getValues(this.semaphores.V_mutex2());
            getValues(this.semaphores.V_full2());
        }
    }
}

class WorkshopAsm implements Runnable {
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores) {
        setValues(this.semaphores, semaphores);
    }

    public run(): void {
        while (true) {
            while (!getValues(this.semaphores.P_full1())) {}
            while (!getValues(this.semaphores.P_mutex1())) {}
            console.log("WorkshopAsm gets a production A from the shelf F1.");
            getValues(this.semaphores.V_mutex1());
            getValues(this.semaphores.V_empty1());
            while (!getValues(this.semaphores.P_full2())) {}
            while (!getValues(this.semaphores.P_mutex2())) {}
            console.log("WorkshopAsm gets a production B from the shelf F2.");
            getValues(this.semaphores.V_mutex2());
            getValues(this.semaphores.V_empty2());
            console.log("WorkshopAsm assemble production A and production B into the whole production.");
        }
    }
}