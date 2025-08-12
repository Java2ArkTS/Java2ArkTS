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
  if (runnable.className === 'P') {
    archetype = new P(new Semaphores());
  } else if (runnable.className === 'P1') {
    archetype = new P1(new Semaphores());
  } else if (runnable.className === 'P2') {
    archetype = new P2(new Semaphores());
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class ReadCompute {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ReadCompute';

  static main(args: string[]): void {
    const semaphores = new Semaphores();
    const p = new Thread(new P(semaphores));
    const p1 = new Thread(new P1(semaphores));
    const p2 = new Thread(new P2(semaphores));
    p.start();
    p1.start();
    p2.start();
  }
}

class Semaphores {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Semaphores';

  public mutex = new SharedBoolean(true);
  public full = new SharedNumber(0);
  public empty = new SharedNumber(50);

  public pMutex(): boolean {
    SynStart(this.syn);
    if (this.mutex.getValue()) {
      this.mutex.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public pFull(): boolean {
    SynStart(this.syn);
    if (this.full.getValue() > 0) {
      this.full.setValue(this.full.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public pEmpty(): boolean {
    SynStart(this.syn);
    if (this.empty.getValue() > 0) {
      this.empty.setValue(this.empty.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public vMutex(): void {
    SynStart(this.syn);
    this.mutex.setValue(true);
    SynEnd(this.syn);
  }

  public vFull(): void {
    SynStart(this.syn);
    this.full.setValue(this.full.getValue() + 1);
    SynEnd(this.syn);
  }

  public vEmpty(): void {
    SynStart(this.syn);
    this.empty.setValue(this.empty.getValue() + 1);
    SynEnd(this.syn);
  }
}

class P implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'P';

  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      while (!this.semaphores.pEmpty()) {}
      while (!this.semaphores.pMutex()) {}
      console.log('P reads data from device into the buffer.');
      this.semaphores.vMutex();
      this.semaphores.vFull();
    }
  }
}

class P1 implements Runnable {
  public semaphores: Semaphores;
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'P1';

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      while (!this.semaphores.pFull()) {}
      console.log('P1 gets one data from the buffer.');
      while (!this.semaphores.pFull()) {}
      console.log('P1 gets one data from the buffer.');
      console.log('P1 computes the datas.');
      this.semaphores.vEmpty();
      console.log('P1 prints the result.');
      this.semaphores.vEmpty();
      console.log('P1 prints the result.');
    }
  }
}

class P2 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'P2';

  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      while (!this.semaphores.pFull()) {}
      console.log('P2 gets one data from the buffer.');
      while (!this.semaphores.pFull()) {}
      console.log('P2 gets one data from the buffer.');
      console.log('P2 computes the datas.');
      this.semaphores.vEmpty();
      console.log('P2 prints the result.');
      this.semaphores.vEmpty();
      console.log('P2 prints the result.');
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}