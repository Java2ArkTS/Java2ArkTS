import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class SharedResource {
    private data: any = getClass('number', 0);
    private isWriting: any = getClass('boolean', false);
    private readers: any = getClass('number', 0);

    public synArray: any = getSyc();
    public sharedType: string = "object";

    public async readData(): Promise<void> {
        while (getValues(this.isWriting)) {
            for (let i = 0; i < 1000; i++);
        }
        {
            SynStart(this['synArray']);
            setValues(this.readers, getValues(this.readers) + 1);
            SynEnd(this['synArray']);
        }
        console.log("Reading data: " + getValues(this.data));
        {
            SynStart(this['synArray']);
            setValues(this.readers, getValues(this.readers) - 1);
            SynEnd(this['synArray']);
        }
    }

    public async writeData(newData: number): Promise<void> {
        while (getValues(this.readers) > 0 || getValues(this.isWriting)) {
            for (let i = 0; i < 1000; i++);
        }
        {
            SynStart(this['synArray']);
            setValues(this.isWriting, true);
            SynEnd(this['synArray']);
        }
        console.log("Writing data: " + newData);
        {
            SynStart(this['synArray']);
            setValues(this.data, newData);
            SynEnd(this['synArray']);
        }
        {
            SynStart(this['synArray']);
            setValues(this.isWriting, false);
            SynEnd(this['synArray']);
        }
    }
}

class Reader implements Runnable {
    private sharedResource: SharedResource;

    constructor(sharedResource: SharedResource) {
        this.sharedResource = sharedResource;
    }

    public run(): void {
        getValues(this.sharedResource.readData().catch(e => console.error(e)));
    }
}

class Writer implements Runnable {
    private sharedResource: SharedResource;
    private newData: any = getClass('number', this.newData);

    constructor(sharedResource: SharedResource, newData: number) {
        this.sharedResource = sharedResource;
        this.newData = newData;
    }

    public run(): void {
        getValues(this.sharedResource.writeData(this.newData).catch(e => console.error(e)));
    }
}

class Main {
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const resource = new SharedResource();
        for (let i = 0; i < 5; i++) {
            const readerThread = new Thread(new Reader(resource));
            readerThread.start();
        }
        const newData = 42;
        const writerThread = new Thread(new Writer(resource, newData));
        writerThread.start();
    }
}