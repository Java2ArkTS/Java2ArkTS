import {
    setValues,
    getSyc,
    getClass,
    getValues,
    SynStart,
    SynEnd,
    addFunc,
    Runnable,
    Thread,
    wait,
    notify
} from './ThreadBridge';

export function sharedWash(threadId: number) {
    let archetype = Thread.runnableList[threadId];
    archetype.run();
}

class CustomBlockingQueue {
    private queue: any = getClass('number[]', []);
    private size: any = getClass('number', 0);
    private capacity: any = getClass('number', 0);
    private front: any = getClass('number', 0);
    private rear: any = getClass('number', -1);

    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(capacity: number) {
        setValues(this.queue, new Array<number>(capacity));
        setValues(this.size, 0);
        setValues(this.capacity, capacity);
        setValues(this.front, 0);
        setValues(this.rear, -1);
    }

    async put(item: number): Promise<void> {
        SynStart(getValues(this['synArray']));
        while (getValues(this.size) === getValues(this.capacity)) {
            await wait(getValues(this['synArray']));
        }
        setValues(this.rear, (getValues(this.rear) + 1) % getValues(this.capacity));
        setValues(this.queue[this.rear], item);
        setValues(this.size, getValues(this.size) + 1);
        console.log("producer: " + getValues(item));
        notify(getValues(this['synArray']));
        SynEnd(getValues(this['synArray']));
    }

    async take(): Promise<number> {
        SynStart(getValues(this['synArray']));
        while (getValues(this.size) === 0) {
            await wait(getValues(this['synArray']));
        }
        const item = getValues(this.queue[this.front]);
        setValues(this.front, (getValues(this.front) + 1) % getValues(this.capacity));
        setValues(this.size, getValues(this.size) - 1);
        console.log("consumer: " + getValues(item));
        notify(getValues(this['synArray']));
        SynEnd(getValues(this['synArray']));
        return getValues(item);
    }
}

class Producer implements Runnable {
    public synArray: any = getSyc();
    public sharedType: string = "object";
    private queue: any = getClass('CustomBlockingQueue', new CustomBlockingQueue(5));

    constructor(queue: CustomBlockingQueue) {
        setValues(this.queue, queue);
    }

    run(): void {
        for (let i = 0; i < 10; i++) {
            try {
                getValues(this.queue.put(i));
                for (let j = 0; j < 10; j++) {}
            } catch (e) {
                if (e instanceof InterruptedException) {
                    getValues(Thread.currentThread().interrupt());
                    return;
                }
            }
        }
    }
}

class Consumer implements Runnable {
    private queue: any = getClass('CustomBlockingQueue', new CustomBlockingQueue(5));
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(queue: CustomBlockingQueue) {
        setValues(this.queue, queue);
    }

    run(): void {
        for (let i = 0; i < 10; i++) {
            try {
                const item = getValues(this.queue.take());
                for (let j = 0; j < 5; j++) {}
            } catch (e) {
                if (e instanceof InterruptedException) {
                    getValues(Thread.currentThread().interrupt());
                    return;
                }
                throw getValues(e);
            }
        }
    }
}

class ProducerConsumerExample {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const queue = new CustomBlockingQueue(5);
        const producer = new Producer(queue);
        const consumer = new Consumer(queue);
        const producerThread = new Thread(producer);
        const consumerThread = new Thread(consumer);
        getValues(producerThread.start());
        getValues(consumerThread.start());
    }
}