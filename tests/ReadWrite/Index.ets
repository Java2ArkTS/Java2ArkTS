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
  if (runnable.className === 'Reader') {
    archetype = new Reader(
      (runnable as Reader).semaphores,
      (runnable as Reader).rank.getValue()
    );
  } else if (runnable.className === 'Writer') {
    archetype = new Writer(
      (runnable as Writer).semaphores,
      (runnable as Writer).rank.getValue()
    );
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

export class ReadWrite {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ReadWrite';

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const thread0 = new Thread(new Reader(semaphores, 0));
    const thread1 = new Thread(new Reader(semaphores, 1));
    const thread2 = new Thread(new Reader(semaphores, 2));
    const thread3 = new Thread(new Writer(semaphores, 3));
    const thread4 = new Thread(new Writer(semaphores, 4));
    thread0.start();
    thread1.start();
    thread2.start();
    thread3.start();
    thread4.start();
  }
}

class Semaphores extends Syc {
  public count = new SharedNumber();
  public rw = new SharedBoolean(true);
  public w = new SharedBoolean(true);
  public mutex = new SharedBoolean(true);

  constructor() {
    super();
    this.count.setValue(0);
    this.rw.setValue(true);
    this.w.setValue(true);
    this.mutex.setValue(true);
  }

  public Pw(): boolean {
    SynStart(this);
    if (this.w.getValue()) {
      this.w.setValue(false);
      SynEnd(this);
      return true;
    } else {
      SynEnd(this);
      return false;
    }
  }

  public Pmutex(): boolean {
    SynStart(this);
    if (this.mutex.getValue()) {
      this.mutex.setValue(false);
      SynEnd(this);
      return true;
    } else {
      SynEnd(this);
      return false;
    }
  }

  public Prw(): boolean {
    SynStart(this);
    if (this.rw.getValue()) {
      this.rw.setValue(false);
      SynEnd(this);
      return true;
    } else {
      SynEnd(this);
      return false;
    }
  }

  public Vmutex(): void {
    SynStart(this);
    this.mutex.setValue(true);
    SynEnd(this);
  }

  public Vw(): void {
    SynStart(this);
    this.w.setValue(true);
    SynEnd(this);
  }

  public Vrw(): void {
    SynStart(this);
    this.rw.setValue(true);
    SynEnd(this);
  }
}

class Reader implements Runnable {
  public semaphores: Semaphores;

  public rank = new SharedNumber();

  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Reader';

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  public run(): void {
    while (true) {
      while (!this.semaphores.Pw()) {}
      while (!this.semaphores.Pmutex()) {}
      if (this.semaphores.count.getValue() === 0) {
        while (!this.semaphores.Prw()) {}
      }
      this.semaphores.count.setValue(this.semaphores.count.getValue() + 1);
      this.semaphores.Vmutex();
      this.semaphores.Vw();
      console.log(`Thread ${this.rank.getValue()} is reading.`);
      while (!this.semaphores.Pmutex()) {}
      this.semaphores.count.setValue(this.semaphores.count.getValue() - 1);
      if (this.semaphores.count.getValue() === 0) {
        this.semaphores.Vrw();
      }
      this.semaphores.Vmutex();
    }
  }
}

class Writer implements Runnable {
  public semaphores: Semaphores;

  public rank = new SharedNumber();

  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Writer';

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  run(): void {
    while (true) {
      while (!this.semaphores.Pw()) {}
      while (!this.semaphores.Prw()) {}
      console.log(`Thread ${this.rank.getValue()} is writing.`);
      this.semaphores.Vrw();
      this.semaphores.Vw();
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}