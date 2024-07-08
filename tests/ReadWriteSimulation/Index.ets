import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number) {
    let archetype = Thread.runnableList[threadId];
    archetype.run();
}

class CustomReadWriteLock {
    private readers: any = getClass('number', 0);
    private writing: any = getClass('boolean', false);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public lockRead() {
        SynStart(this['synArray']);
        while (getValues(this.writing)) {
        }
        setValues(this.readers, getValues(this.readers) + 1);
        SynEnd(this['synArray']);
    }

    public unlockRead() {
        SynStart(this['synArray']);
        setValues(this.readers, getValues(this.readers) - 1);
        if (getValues(this.readers) === 0) {
        }
        SynEnd(this['synArray']);
    }

    public lockWrite() {
        SynStart(this['synArray']);
        while (getValues(this.readers) > 0 || getValues(this.writing)) {
        }
        setValues(this.writing, true);
        SynEnd(this['synArray']);
    }

    public unlockWrite() {
        SynStart(this['synArray']);
        setValues(this.writing, false);
        SynEnd(this['synArray']);
    }
}

class SharedData {
    private lock: any = getClass('CustomReadWriteLock', new CustomReadWriteLock());
    private data: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public readData(readerName: string): void {
        getValues(this.lock.lockRead());
        console.log(readerName + " is reading data: " + getValues(this.data));
        for (let j = 0; j < 1000; j++) ;
        getValues(this.lock.unlockRead());
    }

    public writeData(writerName: string, newData: number): void {
        getValues(this.lock.lockWrite());
        console.log(writerName + " is writing data: " + getValues(newData));
        setValues(this.data, newData);
        for (let j = 0; j < 1000; j++) ;
        getValues(this.lock.unlockWrite());
    }
}

class ReaderWorker implements Runnable {
    private readonly name: any = getClass('string', '');
    private readonly sharedData: any = getClass('SharedData', new SharedData());
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(name: string, sharedData: SharedData) {
        setValues(this.name, name);
        setValues(this.sharedData, sharedData);
    }

    run(): void {
        for (let i = 0; i < 5; i++) {
            getValues(this.sharedData.readData(getValues(this.name)));
            try {
                getValues(Thread.sleep(200));
            } catch (e) {
                console.error(e);
            }
        }
    }
}

class WriterWorker implements Runnable {
    public synArray: any = getSyc();
    public sharedType: string = "object";
    private readonly name: any = getClass('string', '');
    private readonly sharedData: any = getClass('SharedData', new SharedData());

    constructor(name: string, sharedData: SharedData) {
        setValues(this.name, name);
        setValues(this.sharedData, sharedData);
    }

    run(): void {
        for (let i = 0; i < 5; i++) {
            getValues(this.sharedData.writeData(getValues(this.name), i));
            try {
                Thread.sleep(200);
            } catch (e) {
                console.error(e);
            }
        }
    }
}

class ReadWriteSimulation {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    static main(args: string[]) {
        const sharedData = new SharedData();
        const reader1 = new Thread(new ReaderWorker('Reader 1', sharedData));
        const reader2 = new Thread(new ReaderWorker('Reader 2', sharedData));
        const writer1 = new Thread(new WriterWorker('Writer 1', sharedData));
        const writer2 = new Thread(new WriterWorker('Writer 2', sharedData));

        reader1.start();
        reader2.start();
        writer1.start();
        writer2.start();
    }
}