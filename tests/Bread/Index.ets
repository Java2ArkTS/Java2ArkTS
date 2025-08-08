import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "Consumer") {
    archetype = new Consumer(new Semaphores(), 1); // Example rank, adjust as needed
  } else if (runnable.className == "Seller") {
    archetype = new Seller(new Semaphores(), 1); // Example rank, adjust as needed
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Bread {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Bread";

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const thread_consumer_1 = new Thread(new Consumer(semaphores, 1));
    const thread_consumer_2 = new Thread(new Consumer(semaphores, 2));
    const thread_seller_1 = new Thread(new Seller(semaphores, 1));
    const thread_seller_2 = new Thread(new Seller(semaphores, 2));
    thread_consumer_1.start();
    thread_consumer_2.start();
    thread_seller_1.start();
    thread_seller_2.start();
  }
}

class Semaphores {
  public i = new SharedNumber(0);
  public j = new SharedNumber(0);
  public mutex_i = new SharedBoolean(true);
  public mutex_j = new SharedBoolean(true);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Semaphores";

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
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Consumer";
  public rank = new SharedNumber(rank);

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  public run(): void {
    while (true) {
      console.log(`Consumer ${this.rank.getValue()} enter the bakery.`);
      while (!this.semaphores.P_mutex_i()) {}
      console.log(`Consumer ${this.rank.getValue()} get the number ${this.semaphores.i}.`);
      this.semaphores.i++;
      this.semaphores.V_mutex_i();
      console.log(`Consumer ${this.rank.getValue()} is waiting for buying bread.`);
    }
  }
}

class Seller implements Runnable {
  public semaphores: Semaphores;
  public rank = new SharedNumber(rank);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Seller";

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  public run(): void {
    while (true) {
      while (!this.semaphores.P_mutex_j()) {}
      if (this.semaphores.j < this.semaphores.i) {
        console.log(`Seller ${this.rank.getValue()} calls number ${this.semaphores.j}.`);
        this.semaphores.j++;
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