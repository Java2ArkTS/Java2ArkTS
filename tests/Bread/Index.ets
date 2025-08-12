import {
  SynStart,
  SynEnd,
  SharedBoolean,
  SharedNumber,
  Syc,
  addFunc,
  Runnable,
  Thread,
  isMainThread,
} from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className === 'Consumer') {
    archetype = new Consumer(new Semaphores(), 0);
  } else if (runnable.className === 'Seller') {
    archetype = new Seller(new Semaphores(), 0);
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Bread {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Bread';
}

class Semaphores {
  public i = new SharedNumber(0);
  public j = new SharedNumber(0);
  public mutex_i = new SharedBoolean(true);
  public mutex_j = new SharedBoolean(true);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Semaphores';

  public P_mutex_i(): boolean {
    SynStart(this.syn);
    if (this.mutex_i.getValue()) {
      this.mutex_i.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_mutex_j(): boolean {
    SynStart(this.syn);
    if (this.mutex_j.getValue()) {
      this.mutex_j.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public V_mutex_i(): void {
    SynStart(this.syn);
    this.mutex_i.setValue(true);
    SynEnd(this.syn);
  }

  public V_mutex_j(): void {
    SynStart(this.syn);
    this.mutex_j.setValue(true);
    SynEnd(this.syn);
  }
}

class Consumer implements Runnable {
  public semaphores: Semaphores;
  public rank = new SharedNumber();
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Consumer';

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  public run(): void {
    while (true) {
      console.log(`Consumer ${this.rank.getValue()} enter the bakery.`);
      while (!this.semaphores.P_mutex_i()) {}
      console.log(`Consumer ${this.rank.getValue()} get the number ${this.semaphores.i.getValue()}.`);
      this.semaphores.i.setValue(this.semaphores.i.getValue() + 1);
      this.semaphores.V_mutex_i();
      console.log(`Consumer ${this.rank.getValue()} is waiting for buying bread.`);
    }
  }
}

class Seller implements Runnable {
  public semaphores: Semaphores;
  public rank = new SharedNumber();
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Seller';

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  run(): void {
    while (true) {
      while (!this.semaphores.P_mutex_j()) {}
      if (this.semaphores.j.getValue() < this.semaphores.i.getValue()) {
        console.log(`Seller ${this.rank.getValue()} calls number ${this.semaphores.j.getValue()}.`);
        this.semaphores.j.setValue(this.semaphores.j.getValue() + 1);
        this.semaphores.V_mutex_j();
      } else {
        this.semaphores.V_mutex_j();
        console.log(`Seller ${this.rank.getValue()} is free.`);
      }
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}