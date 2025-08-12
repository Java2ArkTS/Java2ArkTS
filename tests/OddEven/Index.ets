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

  if (runnable.className === 'P1') {
    archetype = new P1((runnable as P1).semaphores);
  } else if (runnable.className === 'P2') {
    archetype = new P2((runnable as P2).semaphores);
  } else if (runnable.className === 'P3') {
    archetype = new P3((runnable as P3).semaphores);
  } else {
    archetype = new Thread();
  }

  addFunc(runnable, archetype);
  runnable.run();
}

class OddEven {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'OddEven';

  static main(args: string[]): void {
    const semaphores = new Semaphores();
    const p1 = new Thread(new P1(semaphores));
    const p2 = new Thread(new P2(semaphores));
    const p3 = new Thread(new P3(semaphores));
    p1.start();
    p2.start();
    p3.start();
  }
}

class Semaphores extends Syc {
  public mutex = new SharedBoolean(true);
  public odd = new SharedNumber(0);
  public even = new SharedNumber(0);
  public empty = new SharedNumber(5);

  public pMutex(): boolean {
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

  public pOdd(): boolean {
    SynStart(this);
    if (this.odd.getValue() > 0) {
      this.odd.setValue(this.odd.getValue() - 1);
      SynEnd(this);
      return true;
    } else {
      SynEnd(this);
      return false;
    }
  }

  public pEven(): boolean {
    SynStart(this);
    if (this.even.getValue() > 0) {
      this.even.setValue(this.even.getValue() - 1);
      SynEnd(this);
      return true;
    } else {
      SynEnd(this);
      return false;
    }
  }

  public pEmpty(): boolean {
    SynStart(this);
    if (this.empty.getValue() > 0) {
      this.empty.setValue(this.empty.getValue() - 1);
      SynEnd(this);
      return true;
    } else {
      SynEnd(this);
      return false;
    }
  }

  public vMutex(): void {
    SynStart(this);
    this.mutex.setValue(true);
    SynEnd(this);
  }

  public vOdd(): void {
    SynStart(this);
    this.odd.setValue(this.odd.getValue() + 1);
    SynEnd(this);
  }

  public vEven(): void {
    SynStart(this);
    this.even.setValue(this.even.getValue() + 1);
    SynEnd(this);
  }

  public vEmpty(): void {
    SynStart(this);
    this.empty.setValue(this.empty.getValue() + 1);
    SynEnd(this);
  }
}

class P1 implements Runnable {
  public semaphores: Semaphores;
  public x = new SharedNumber(0);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'P1';

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      while (!this.semaphores.pEmpty()) {}
      while (!this.semaphores.pMutex()) {}
      console.log('P1 puts a number.');
      this.semaphores.vMutex();
      if (this.x.getValue() % 2 === 0) {
        this.semaphores.vEven();
      } else {
        this.semaphores.vOdd();
      }
      this.x.setValue(this.x.getValue() + 1);
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
      while (!this.semaphores.pOdd()) {}
      while (!this.semaphores.pMutex()) {}
      console.log('P2 gets an odd number.');
      this.semaphores.vMutex();
      this.semaphores.vEmpty();
      console.log('P2 counts an odd number.');
    }
  }
}

class P3 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'P3';
  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      while (!this.semaphores.pEven()) {}
      while (!this.semaphores.pMutex()) {}
      console.log('P3 gets an even number.');
      this.semaphores.vMutex();
      this.semaphores.vEmpty();
      console.log('P3 counts an even number.');
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}