import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "Reader") {
    archetype = new Reader(new SharedResource());
  } else if (runnable.className == "Writer") {
    archetype = new Writer(new SharedResource(), 0);
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class SharedResource {

    private data = new SharedNumber(0);

    private isWriting = new SharedBoolean(false);

    private readers = new SharedNumber(0);

    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "SharedResource";

    public async readData(): Promise<void> {
        while (this.isWriting.getValue()) {
            for (let i = 0; i < 1000; i++);
        }
        {
            SynStart(this.syn);
            this.readers.setValue(this.readers.getValue() + 1);
            SynEnd(this.syn);
        }
        console.log("Reading data: " + this.data.getValue());
        {
            SynStart(this.syn);
            this.readers.setValue(this.readers.getValue() - 1);
            SynEnd(this.syn);
        }
    }

    public async writeData(newData: number): Promise<void> {
        while (this.readers.getValue() > 0 || this.isWriting.getValue()) {
            for (let i = 0; i < 1000; i++);
        }
        {
            SynStart(this.syn);
            this.isWriting.setValue(true);
            console.log("Writing data: " + newData);
            this.data.setValue(newData);
            this.isWriting.setValue(false);
            SynEnd(this.syn);
        }
    }
}


class Reader implements Runnable {

    private resource: SharedResource;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Reader";

    constructor(resource: SharedResource) {
        this.resource = resource;
    }

    run(): void {
        try {
            this.resource.readData();
        } catch (e) {
            if (e instanceof Error) {
                console.error(e.stack);
            }
        }
    }
}


class Writer implements Runnable {

    private resource: SharedResource;

    private newData = new SharedNumber(0);

    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Writer";

    constructor(resource: SharedResource, newData: number) {
        this.resource = resource;
        this.newData.setValue(newData);
    }

    run(): void {
        try {
            this.resource.writeData(this.newData.getValue());
        } catch (e) {
            if (e instanceof InterruptedException) {
                console.error(e);
            }
        }
    }
}


class Main {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Main";

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

if (isMainThread()) {
  // You can put the entry of your code here to test.
}