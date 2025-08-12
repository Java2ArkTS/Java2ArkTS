import {
  SynStart,
  SynEnd,
  wait,
  notify,
  SharedBoolean,
  SharedString,
  SharedNumber,
  Syc,
  isMainThread,
  addFunc,
  Runnable,
  Thread,
} from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;

  if (runnable.className === 'ReaderWorker') {
    archetype = new ReaderWorker('Archetype Reader', new SharedData());
  } else if (runnable.className === 'WriterWorker') {
    archetype = new WriterWorker('Archetype Writer', new SharedData());
  } else {
    archetype = new Thread();
  }

  addFunc(runnable, archetype);
  runnable.run();
}

class CustomReadWriteLock {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'CustomReadWriteLock';

  private readers = new SharedNumber(0);
  private writing = new SharedBoolean(false);

  public lockRead(): void {
    {
      SynStart(this.syn);
      while (this.writing.getValue()) {}
      this.readers.setValue(this.readers.getValue() + 1);
      SynEnd(this.syn);
    }
  }

  public unlockRead(): void {
    {
      SynStart(this.syn);
      this.readers.setValue(this.readers.getValue() - 1);
      if (this.readers.getValue() === 0) {}
      SynEnd(this.syn);
    }
  }

  public lockWrite(): void {
    {
      SynStart(this.syn);
      while (this.readers.getValue() > 0 || this.writing.getValue()) {}
      this.writing.setValue(true);
      SynEnd(this.syn);
    }
  }

  public unlockWrite(): void {
    {
      SynStart(this.syn);
      this.writing.setValue(false);
      SynEnd(this.syn);
    }
  }
}

class SharedData {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'SharedData';

  private lock: CustomReadWriteLock = new CustomReadWriteLock();
  private data = new SharedNumber(0);

  public readData(readerName: string): void {
    this.lock.lockRead();
    console.log(`${readerName} is reading data: ${this.data.getValue()}`);
    for (let j = 0; j < 1000; j++) {}
    this.lock.unlockRead();
  }

  public writeData(writerName: string, newData: number): void {
    this.lock.lockWrite();
    console.log(`${writerName} is writing data: ${newData}`);
    this.data.setValue(newData);
    for (let j = 0; j < 1000; j++) {}
    this.lock.unlockWrite();
  }
}

class ReaderWorker implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ReaderWorker';

  private readonly name = new SharedString();
  private readonly sharedData: SharedData;

  constructor(name: string, sharedData: SharedData) {
    this.name.setValue(name);
    this.sharedData = sharedData;
  }

  run(): void {
    for (let i = 0; i < 5; i++) {
      this.sharedData.readData(this.name.getValue());
      try {
        wait(new Syc()); // Replace Thread.sleep with wait
      } catch (e) {
        console.error(e);
      }
    }
  }
}

class WriterWorker implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'WriterWorker';

  private readonly name = new SharedString();
  private readonly sharedData: SharedData;

  constructor(name: string, sharedData: SharedData) {
    this.name.setValue(name);
    this.sharedData = sharedData;
  }

  run(): void {
    for (let i = 0; i < 5; i++) {
      this.sharedData.writeData(this.name.getValue(), i);
      try {
        wait(new Syc()); // Replace Thread.sleep with wait
      } catch (e) {
        console.error(e);
      }
    }
  }
}

class ReadWriteSimulation {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ReadWriteSimulation';

  static main(args: string[]): void {
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

if (isMainThread()) {
  ReadWriteSimulation.main([]);
}