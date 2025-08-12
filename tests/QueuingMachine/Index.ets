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
  if (runnable.className === 'Customer') {
    archetype = new Customer(new Semaphores(), 0); // Example instantiation with default values
  } else if (runnable.className === 'Server') {
    archetype = new Server(new Semaphores()); // Example instantiation with default values
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class QueuingMachine {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'QueuingMachine';

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const server = new Thread(new Server(semaphores));
    const customer1 = new Thread(new Customer(semaphores, 1));
    const customer2 = new Thread(new Customer(semaphores, 2));
    const customer3 = new Thread(new Customer(semaphores, 3));
    const customer4 = new Thread(new Customer(semaphores, 4));
    server.start();
    customer1.start();
    customer2.start();
    customer3.start();
    customer4.start();
  }
}

class Semaphores {
  public empty = new SharedNumber(10);
  public mutex = new SharedBoolean(true);
  public full = new SharedNumber(0);
  public service = new SharedBoolean(false);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Semaphores';

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

  public pService(): boolean {
    SynStart(this.syn);
    if (this.service.getValue()) {
      this.service.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public vEmpty(): void {
    SynStart(this.syn);
    this.empty.setValue(this.empty.getValue() + 1);
    SynEnd(this.syn);
  }

  public vFull(): void {
    SynStart(this.syn);
    this.full.setValue(this.full.getValue() + 1);
    SynEnd(this.syn);
  }

  public vMutex(): void {
    SynStart(this.syn);
    this.mutex.setValue(true);
    SynEnd(this.syn);
  }

  public vService(): void {
    SynStart(this.syn);
    this.service.setValue(true);
    SynEnd(this.syn);
  }
}

class Customer implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Customer';
  public semaphores: Semaphores;
  public rank = new SharedNumber();

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  run(): void {
    while (!this.semaphores.pEmpty()) {}
    while (!this.semaphores.pMutex()) {}
    console.log(`Customer ${this.rank.getValue()} takes a number.`);
    this.semaphores.vMutex();
    this.semaphores.vFull();
    while (!this.semaphores.pService()) {}
    console.log(`Customer ${this.rank.getValue()} gets service.`);
  }
}

class Server implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Server';
  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      while (!this.semaphores.pFull()) {}
      this.semaphores.vEmpty();
      this.semaphores.vService();
      console.log('Server serves.');
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}