import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "Reader") {
    archetype = new Reader(new Semaphores(), 0); // Example rank, adjust as needed
  } else if (runnable.className == "Writer") {
    archetype = new Writer(new Semaphores(), 0); // Example rank, adjust as needed
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class ReadWrite {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "ReadWrite";

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

class Semaphores {
  public count = new SharedNumber(0);
  public rw = new SharedBoolean(true);
  public w = new SharedBoolean(true);
  public mutex = new SharedBoolean(true);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Semaphores";

  constructor() {
    // Initialization is handled in the variable declaration
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

  // other methods omitted for brevity
}

class Reader implements Runnable {
  public semaphores: Semaphores;
  public rank = new SharedNumber(rank);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Reader";

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  public run(): void {
    // implementation
  }
}

class Writer implements Runnable {
  public semaphores: Semaphores;
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Writer";
  public rank = new SharedNumber(rank);

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  public run(): void {
    // implementation
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}