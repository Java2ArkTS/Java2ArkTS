import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number) {
    let archetype = Thread.runnableList[threadId];
    archetype.run();
}

class LetterBox {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const a = new Thread(new A(semaphores));
        const b = new Thread(new B(semaphores));
        a.start();
        b.start();
    }
}

class Semaphores {
    // ... (same as original)

    public vMutexB(): void {
        SynStart(this['synArray']);
        setValues(this.mutexB, true);
        SynEnd(this['synArray']);
    }
}

class A implements Runnable {
    // ... (same as original)
}

class B implements Runnable {
    // ... (same as original)
}