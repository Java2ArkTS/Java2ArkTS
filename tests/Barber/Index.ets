import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class BarberProblem {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  static main(args: string[]) {
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

import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

class Semaphores {
  public waiting: any = getClass('number', 0);
  public charis: any = getClass('number', 3);
  public customers: any = getClass('number', 0);
  public barbers: any = getClass('number', 0);
  public mutex: any = getClass('boolean', true);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public pCustomers(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.customers) > 0) {
      setValues(this.customers, getValues(this.customers) - 1);
      SynEnd(this['synArray']);
      return true;
    } else {
      SynEnd(this['synArray']);
      return false;
    }
  }

  public pMutex(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.mutex)) {
      setValues(this.mutex, false);
      SynEnd(this['synArray']);
      return true;
    } else {
      SynEnd(this['synArray']);
      return false;
    }
  }

  public pBarbers(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.barbers) > 0) {
      setValues(this.barbers, getValues(this.barbers) - 1);
      SynEnd(this['synArray']);
      return true;
    } else {
      SynEnd(this['synArray']);
      return false;
    }
  }

  public vCustomers(): void {
    SynStart(this['synArray']);
    setValues(this.customers, getValues(this.customers) + 1);
    SynEnd(this['synArray']);
  }

  public vBarbers(): void {
    SynStart(this['synArray']);
    setValues(this.barbers, getValues(this.barbers) + 1);
    SynEnd(this['synArray']);
  }

  public vMutex(): void {
    SynStart(this['synArray']);
    setValues(this.mutex, true);
    SynEnd(this['synArray']);
  }
}

class Barber implements Runnable {
  public semaphores: any = getClass('Semaphores', new Semaphores());
  public rank: any = getClass('number', 1);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public constructor(semaphores: Semaphores, rank: number) {
    setValues(this.semaphores, semaphores);
    setValues(this.rank, rank);
  }

  public run(): void {
    while (true) {
      while (!getValues(this.semaphores.pCustomers())) {
      }
      while (!getValues(this.semaphores.pMutex())) {
      }
      setValues(this.semaphores.waiting, getValues(this.semaphores.waiting) - 1);
      console.log(`Barber ${getValues(this.rank)} is cutting hair.`);
      getValues(this.semaphores.vBarbers());
      getValues(this.semaphores.vMutex());
    }
  }
}

class Customer implements Runnable {
  public semaphores: any = getClass('Semaphores', new Semaphores());
  public rank: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank = rank;
  }

  public run(): void {
    while (!getValues(this.semaphores.pMutex())) { }
    if (getValues(this.semaphores.waiting) < getValues(this.semaphores.charis)) {
      setValues(this.semaphores.waiting, getValues(this.semaphores.waiting) + 1);
      console.log("Customer " + getValues(this.rank) + " is waiting.");
      getValues(this.semaphores.vCustomers());
      getValues(this.semaphores.vMutex());
      while (!getValues(this.semaphores.pBarbers())) { }
    } else {
      console.log("Customer " + getValues(this.rank) + " leaves.");
      getValues(this.semaphores.vMutex());
    }
  }
}