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

  if (runnable.className === 'BarberProblem') {
    archetype = new BarberProblem();
  } else if (runnable.className === 'Semaphores') {
    archetype = new Semaphores();
  } else if (runnable.className === 'Barber') {
    archetype = new Barber(new Semaphores(), 0); // Default rank and semaphores for instantiation
  } else if (runnable.className === 'Customer') {
    archetype = new Customer(new Semaphores(), 0); // Default rank and semaphores for instantiation
  } else {
    archetype = new Thread();
  }

  addFunc(runnable, archetype);
  runnable.run();
}

export class BarberProblem implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'BarberProblem';

  public run(): void {
    BarberProblem.main([]);
  }

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const barber1 = new Thread(new Barber(semaphores, 1));
    const barber2 = new Thread(new Barber(semaphores, 2));
    const customer1 = new Thread(new Customer(semaphores, 1));
    const customer2 = new Thread(new Customer(semaphores, 2));
    const customer3 = new Thread(new Customer(semaphores, 3));
    barber1.start();
    barber2.start();
    customer1.start();
    customer2.start();
    customer3.start();
  }
}

class Semaphores implements Runnable {
  public waiting = new SharedNumber(0);
  public charis = new SharedNumber(3);
  public customers = new SharedNumber(0);
  public barbers = new SharedNumber(0);
  public mutex = new SharedBoolean(true);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Semaphores';

  public run(): void {
    // Semaphores do not have a specific run implementation
  }

  public pCustomers(): boolean {
    SynStart(this.syn);
    if (this.customers.getValue() > 0) {
      this.customers.setValue(this.customers.getValue() - 1);
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

  public pBarbers(): boolean {
    SynStart(this.syn);
    if (this.barbers.getValue() > 0) {
      this.barbers.setValue(this.barbers.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public vCustomers(): void {
    SynStart(this.syn);
    this.customers.setValue(this.customers.getValue() + 1);
    SynEnd(this.syn);
  }

  public vBarbers(): void {
    SynStart(this.syn);
    this.barbers.setValue(this.barbers.getValue() + 1);
    SynEnd(this.syn);
  }

  public vMutex(): void {
    SynStart(this.syn);
    this.mutex.setValue(true);
    SynEnd(this.syn);
  }
}

class Barber implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Barber';

  public semaphores: Semaphores;

  public rank = new SharedNumber();

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  run(): void {
    while (true) {
      while (!this.semaphores.pCustomers()) {}
      while (!this.semaphores.pMutex()) {}
      this.semaphores.waiting.setValue(this.semaphores.waiting.getValue() - 1);
      console.log(`Barber ${this.rank.getValue()} is cutting hair.`);
      this.semaphores.vBarbers();
      this.semaphores.vMutex();
    }
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

  public run(): void {
    while (!this.semaphores.pMutex()) {}
    if (this.semaphores.waiting.getValue() < this.semaphores.charis.getValue()) {
      this.semaphores.waiting.setValue(this.semaphores.waiting.getValue() + 1);
      console.log(`Customer ${this.rank.getValue()} is waiting.`);
      this.semaphores.vCustomers();
      this.semaphores.vMutex();
      while (!this.semaphores.pBarbers()) {}
    } else {
      console.log(`Customer ${this.rank.getValue()} leaves.`);
      this.semaphores.vMutex();
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}