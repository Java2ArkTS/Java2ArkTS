import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Bread {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const thread_consumer_1 = new Thread(new Consumer(semaphores, 1));
        const thread_consumer_2 = new Thread(new Consumer(semaphores, 2));
        const thread_seller_1 = new Thread(new Seller(semaphores, 1));
        const thread_seller_2 = new Thread(new Seller(semaphores, 2));
        getValues(thread_consumer_1.start());
        getValues(thread_consumer_2.start());
        getValues(thread_seller_1.start());
        getValues(thread_seller_2.start());
    }
}

class Semaphores {
    public i: any = getClass('number', 0);
    public j: any = getClass('number', 0);
    public mutex_i: any = getClass('boolean', true);
    public mutex_j: any = getClass('boolean', true);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public P_mutex_i(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.mutex_i)) {
            setValues(this.mutex_i, false);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public P_mutex_j(): boolean {
        SynStart(this['synArray']);
        if (getValues(this.mutex_j)) {
            setValues(this.mutex_j, false);
            SynEnd(this['synArray']);
            return true;
        } else {
            SynEnd(this['synArray']);
            return false;
        }
    }

    public V_mutex_i(): void {
        SynStart(this['synArray']);
        setValues(this.mutex_i, true);
        SynEnd(this['synArray']);
    }

    public V_mutex_j(): void {
        SynStart(this['synArray']);
        setValues(this.mutex_j, true);
        SynEnd(this['synArray']);
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

    public run(): void {
        while (true) {
            console.log(`Consumer ${getValues(this.rank)} enter the bakery.`);
            while (!getValues(this.semaphores.P_mutex_i())) {
            }
            console.log(`Consumer ${getValues(this.rank)} get the number ${getValues(this.semaphores.i)}.`);
            setValues(this.semaphores.i, getValues(this.semaphores.i) + 1);
            getValues(this.semaphores.V_mutex_i());
            console.log(`Consumer ${getValues(this.rank)} is waiting for buying bread.`);
        }
    }
}

class Seller implements Runnable {
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
            while (!getValues(this.semaphores.P_mutex_j())) {
            }
            if (getValues(this.semaphores.j) < getValues(this.semaphores.i)) {
                console.log(`Seller ${getValues(this.rank)} calls number ${getValues(this.semaphores.j)}.`);
                setValues(this.semaphores.j, getValues(this.semaphores.j) + 1);
                getValues(this.semaphores.V_mutex_j());
            } else {
                getValues(this.semaphores.V_mutex_j());
                console.log(`Seller ${getValues(this.rank)} is free.`);
            }
        }
    }
}