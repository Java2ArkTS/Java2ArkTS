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

  if (runnable.className === 'WorkshopA') {
    archetype = new WorkshopA((runnable as WorkshopA).semaphores);
  } else if (runnable.className === 'WorkshopB') {
    archetype = new WorkshopB((runnable as WorkshopB).semaphores);
  } else if (runnable.className === 'WorkshopAsm') {
    archetype = new WorkshopAsm((runnable as WorkshopAsm).semaphores);
  } else {
    archetype = new Thread();
  }

  addFunc(runnable, archetype);
  runnable.run();
}

class Factory {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Factory';

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const workshopA = new Thread(new WorkshopA(semaphores));
    const workshopB = new Thread(new WorkshopB(semaphores));
    const workshopAsm = new Thread(new WorkshopAsm(semaphores));
    workshopA.start();
    workshopB.start();
    workshopAsm.start();
  }
}

class Semaphores {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Semaphores';

  public empty1 = new SharedNumber(10);
  public full1 = new SharedNumber(0);
  public empty2 = new SharedNumber(10);
  public full2 = new SharedNumber(0);
  public mutex1 = new SharedBoolean(true);
  public mutex2 = new SharedBoolean(true);

  public P_empty1(): boolean {
    SynStart(this.syn);
    if (this.empty1.getValue() > 0) {
      this.empty1.setValue(this.empty1.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_empty2(): boolean {
    SynStart(this.syn);
    if (this.empty2.getValue() > 0) {
      this.empty2.setValue(this.empty2.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_full1(): boolean {
    SynStart(this.syn);
    if (this.full1.getValue() > 0) {
      this.full1.setValue(this.full1.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_full2(): boolean {
    SynStart(this.syn);
    if (this.full2.getValue() > 0) {
      this.full2.setValue(this.full2.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_mutex1(): boolean {
    SynStart(this.syn);
    if (this.mutex1.getValue()) {
      this.mutex1.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_mutex2(): boolean {
    SynStart(this.syn);
    if (this.mutex2.getValue()) {
      this.mutex2.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public V_empty1(): void {
    SynStart(this.syn);
    this.empty1.setValue(this.empty1.getValue() + 1);
    SynEnd(this.syn);
  }

  public V_empty2(): void {
    SynStart(this.syn);
    this.empty2.setValue(this.empty2.getValue() + 1);
    SynEnd(this.syn);
  }

  public V_full1(): void {
    SynStart(this.syn);
    this.full1.setValue(this.full1.getValue() + 1);
    SynEnd(this.syn);
  }

  public V_full2(): void {
    SynStart(this.syn);
    this.full2.setValue(this.full2.getValue() + 1);
    SynEnd(this.syn);
  }

  public V_mutex1(): void {
    SynStart(this.syn);
    this.mutex1.setValue(true);
    SynEnd(this.syn);
  }

  public V_mutex2(): void {
    SynStart(this.syn);
    this.mutex2.setValue(true);
    SynEnd(this.syn);
  }
}

class WorkshopA implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'WorkshopA';

  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      console.log('Workshop A produces a production A.');
      while (!this.semaphores.P_empty1()) {}
      while (!this.semaphores.P_mutex1()) {}
      console.log('Workshop A puts a production A onto the shelf F1.');
      this.semaphores.V_mutex1();
      this.semaphores.V_full1();
    }
  }
}

class WorkshopB implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'WorkshopB';
  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      console.log('Workshop B produces a production B.');
      while (!this.semaphores.P_empty2()) {}
      while (!this.semaphores.P_mutex2()) {}
      console.log('Workshop B puts a production B onto the shelf F2.');
      this.semaphores.V_mutex2();
      this.semaphores.V_full2();
    }
  }
}

class WorkshopAsm implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'WorkshopAsm';

  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      while (!this.semaphores.P_full1()) {}
      while (!this.semaphores.P_mutex1()) {}
      console.log('WorkshopAsm gets a production A from the shelf F1.');
      this.semaphores.V_mutex1();
      this.semaphores.V_empty1();
      while (!this.semaphores.P_full2()) {}
      while (!this.semaphores.P_mutex2()) {}
      console.log('WorkshopAsm gets a production B from the shelf F2.');
      this.semaphores.V_mutex2();
      this.semaphores.V_empty2();
      console.log(
        'WorkshopAsm assemble production A and production B into the whole production.'
      );
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}