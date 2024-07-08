import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number) {
    let archetype = Thread.runnableList[threadId];
    archetype.run();
}

class SimpleConcurrentExample {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const thread1: Thread = new Thread(new RunnableTask());
        const thread2: Thread = new Thread(new RunnableTask());
        getValues(thread1.start());
        getValues(thread2.start());
        console.log("Main thread is running...");
    }
}

class RunnableTask implements Runnable {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    run(): void {
        for (let i = 0; i < 5; i++) {
            console.log(`${getValues(Thread.currentThread().getName())} - Count: ${i}`);
            for (let j = 0; j < 2000; j++);
        }
        console.log(`${getValues(Thread.currentThread().getName())} is finished.`);
    }
}