import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Exit {

    public synArray: any = getSyc();
    public sharedType: string = "object";
    
    public static main(args: string[]): void {
        const semaphores = getValues(new Semaphores());
        const visitor1 = getValues(new Thread(getValues(new Visitor(semaphores, 1))));
        const visitor2 = getValues(new Thread(getValues(new Visitor(semaphores, 2))));
        const visitor3 = getValues(new Thread(getValues(new Visitor(semaphores, 3))));
        const visitor4 = getValues(new Thread(getValues(new Visitor(semaphores, 4))));
        const visitor5 = getValues(new Thread(getValues(new Visitor(semaphores, 5))));
        getValues(visitor1.start());
        getValues(visitor2.start());
        getValues(visitor3.start());
        getValues(visitor4.start());
        getValues(visitor5.start());
    }
}

class Semaphores {
    
    public empty: any = getClass('number', 500);

    public mutex: any = getClass('boolean', true);

    public synArray: any = getSyc();
    public sharedType: string = "object";

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

    public vEmpty(): void {
        SynStart(this['synArray']);
        setValues(this.empty, getValues(this.empty) + 1);
        SynEnd(this['synArray']);
    }

    public vMutex(): void {
        SynStart(this['synArray']);
        setValues(this.mutex, true);
        SynEnd(this['synArray']);
    }
}

class Visitor implements Runnable {

    public semaphores: any = getClass('Semaphores', new Semaphores());
    public rank: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores, rank: number) {
        setValues(this.semaphores, semaphores);
        setValues(this.rank, rank);
    }

    public run() {
        while (!getValues(this.semaphores.pEmpty())) {
        }
        while (!getValues(this.semaphores.pMutex())) {
        }
        console.log("Visitor " + getValues(this.rank) + " enters the museum.");
        getValues(this.semaphores.vMutex());
        console.log("Visitor " + getValues(this.rank) + " visits the museum.");
        while (!getValues(this.semaphores.pMutex())) {
        }
        console.log("Visitor " + getValues(this.rank) + " leaves the museum.");
        getValues(this.semaphores.vMutex());
        getValues(this.semaphores.vEmpty());
    }
}