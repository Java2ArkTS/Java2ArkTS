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

class ThreeThreads {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ThreeThreads';

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

class Semaphores {
  public s1 = new SharedNumber(1);
  public s2 = new SharedNumber(0);
  public s3 = new SharedNumber(0);
  public sb = new SharedNumber(0);
  public sy = new SharedNumber(0);
  public sz = new SharedNumber(0);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Semaphores';

  public Ps1(): boolean {
    SynStart(this.syn);
    if (this.s1.getValue() > 0) {
      this.s1.setValue(this.s1.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public Ps2(): boolean {
    SynStart(this.syn);
    if (this.s2.getValue() > 0) {
      this.s2.setValue(this.s2.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public Ps3(): boolean {
    SynStart(this.syn);
    if (this.s3.getValue() > 0) {
      this.s3.setValue(this.s3.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public Psb(): boolean {
    SynStart(this.syn);
    if (this.sb.getValue() > 0) {
      this.sb.setValue(this.sb.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public Psy(): boolean {
    SynStart(this.syn);
    if (this.sy.getValue() > 0) {
      this.sy.setValue(this.sy.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public Psz(): boolean {
    SynStart(this.syn);
    if (this.sz.getValue() > 0) {
      this.sz.setValue(this.sz.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public Vs1(): void {
    SynStart(this.syn);
    this.s1.setValue(this.s1.getValue() + 1);
    SynEnd(this.syn);
  }

  public Vs2(): void {
    SynStart(this.syn);
    this.s2.setValue(this.s2.getValue() + 1);
    SynEnd(this.syn);
  }

  public Vs3(): void {
    SynStart(this.syn);
    this.s3.setValue(this.s3.getValue() + 1);
    SynEnd(this.syn);
  }

  public Vsb(): void {
    SynStart(this.syn);
    this.sb.setValue(this.sb.getValue() + 1);
    SynEnd(this.syn);
  }

  public Vsy(): void {
    SynStart(this.syn);
    this.sy.setValue(this.sy.getValue() + 1);
    SynEnd(this.syn);
  }

  public Vsz(): void {
    SynStart(this.syn);
    this.sz.setValue(this.sz.getValue() + 1);
    SynEnd(this.syn);
  }
}

class P1 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'P1';
  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (!this.semaphores.Ps1()) {}
    console.log('P1 reads a from the input device.');
    this.semaphores.Vs2();
    while (!this.semaphores.Psb()) {}
    console.log('P1 computes x = a + b.');
    while (!this.semaphores.Psy()) {}
    while (!this.semaphores.Psz()) {}
    console.log('P1 prints the results of x, y and z.');
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
    while (!this.semaphores.Ps2()) {}
    console.log('P2 reads b from the input device.');
    this.semaphores.Vs3();
    this.semaphores.Vsb();
    console.log('P2 computes y = a * b.');
    this.semaphores.Vsy();
    this.semaphores.Vsy();
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
    while (!this.semaphores.Ps3()) {}
    console.log('P3 reads c from the input device.');
    while (!this.semaphores.Psy()) {}
    console.log('P3 computes z = y + c - a.');
    this.semaphores.Vsz();
  }
}

if (isMainThread()) {
  ThreeThreads.main([]);
}