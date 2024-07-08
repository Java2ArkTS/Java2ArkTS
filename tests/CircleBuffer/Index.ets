import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class CircleBuffer {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const producer1 = new Thread(new Producer(semaphores, 1));
        const producer2 = new Thread(new Producer(semaphores, 2));
        const consumer1 = new Thread(new Consumer(semaphores, 1));
        const consumer2 = new Thread(new Consumer(semaphores, 2));
        getValues(producer1.start());
        getValues(producer2.start());
        getValues(consumer1.start());
        getValues(consumer2.start());
    }
}

class Semaphores {
    public mutex1: any = getClass('boolean', true);
    public mutex2: any = getClass('boolean', true);
    public empty: any = getClass('number', 1000);
    public full: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public pMutex1(): boolean {
        {
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
    }

    public pMutex2(): boolean {
        {
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
    }

    public pEmpty(): boolean {
        {
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
    }

    public pFull(): boolean {
        {
            SynStart(this['synArray']);
            if (getValues(this.full) > 0) {
                setValues(this.full, getValues(this.full) - 1);
                SynEnd(this['synArray']);
                return true;
            } else {
                SynEnd(this['synArray']);
                return false;
            }
        }
    }

    public vMutex1(): void {
        {
            SynStart(this['synArray']);
            setValues(this.mutex1, true);
            SynEnd(this['synArray']);
        }
    }

    public vMutex2(): void {
        {
            SynStart(this['synArray']);
            setValues(this.mutex2, true);
            SynEnd(this['synArray']);
        }
    }

    public vEmpty(): void {
        {
            SynStart(this['synArray']);
            setValues(this.empty, getValues(this.empty) + 1);
            SynEnd(this['synArray']);
        }
    }

    public vFull(): void {
        {
            SynStart(this['synArray']);
            setValues(this.full, getValues(this.full) + 1);
            SynEnd(this['synArray']);
        }
    }
}

class Producer implements Runnable {
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public rank: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores, rank: number) {
        setValues(this.semaphores, semaphores);
        setValues(this.rank, rank);
    }

    run(): void {
        while (true) {
            console.log(`Producer ${getValues(this.rank)} produces a production.`);
            while (!getValues(this.semaphores.pEmpty())) {
            }
            while (!getValues(this.semaphores.pMutex2())) {
            }
            console.log(`Producer ${getValues(this.rank)} puts a production into the buffer.`);
            getValues(this.semaphores.vMutex2());
            getValues(this.semaphores.vFull());
        }
    }
}

class Consumer implements Runnable {
    public semaphores: any = getClass('Semaphores', new Semaphores());
    public rank: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(semaphores: Semaphores, rank: number) {
        setValues(this.semaphores, semaphores);
        setValues(this.rank, rank);
    }

    run(): void {
        while (true) {
            while (!getValues(this.semaphores.pMutex1())) {
            }
            for (let i = 1; i <= 10; i++) {
                while (!getValues(this.semaphores.pFull())) {
                }
                while (!getValues(this.semaphores.pMutex2())) {
                }
                console.log(`Consumer ${this.rank} gets the ${i}st/nd/rd/th production from the buffer.`);
                getValues(this.semaphores.vMutex2());
                getValues(this.semaphores.vEmpty());
                console.log(`Consumer ${this.rank} consumes the ${i}st/nd/rd/th production.`);
            }
            getValues(this.semaphores.vMutex1());
        }
    }
}