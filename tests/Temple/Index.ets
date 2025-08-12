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

  if (runnable.className === 'Older') {
    archetype = new Older(
      (runnable as Older).semaphores,
      (runnable as Older).rank.getValue()
    );
  } else if (runnable.className === 'Younger') {
    archetype = new Younger(
      (runnable as Younger).semaphores,
      (runnable as Younger).rank.getValue()
    );
  } else {
    archetype = new Thread();
  }

  addFunc(runnable, archetype);
  runnable.run();
}

class Temple {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Temple';

  static main(args: string[]): void {
    const semaphores = new Semaphores();
    const younger1 = new Thread(new Younger(semaphores, 1));
    const younger2 = new Thread(new Younger(semaphores, 2));
    const older1 = new Thread(new Older(semaphores, 1));
    const older2 = new Thread(new Older(semaphores, 2));
    younger1.start();
    younger2.start();
    older1.start();
    older2.start();
  }
}

class Semaphores {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Semaphores';

  public well = new SharedBoolean(true);
  public vat = new SharedBoolean(true);
  public empty = new SharedNumber(10);
  public full = new SharedNumber(0);
  public pail = new SharedNumber(3);

  public P_well(): boolean {
    SynStart(this.syn);
    if (this.well.getValue()) {
      this.well.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_vat(): boolean {
    SynStart(this.syn);
    if (this.vat.getValue()) {
      this.vat.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_empty(): boolean {
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

  public P_full(): boolean {
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

  public P_pail(): boolean {
    SynStart(this.syn);
    if (this.pail.getValue() > 0) {
      this.pail.setValue(this.pail.getValue() - 1);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public V_well(): void {
    SynStart(this.syn);
    this.well.setValue(true);
    SynEnd(this.syn);
  }

  public V_vat(): void {
    SynStart(this.syn);
    this.vat.setValue(true);
    SynEnd(this.syn);
  }

  public V_empty(): void {
    SynStart(this.syn);
    this.empty.setValue(this.empty.getValue() + 1);
    SynEnd(this.syn);
  }

  public V_full(): void {
    SynStart(this.syn);
    this.full.setValue(this.full.getValue() + 1);
    SynEnd(this.syn);
  }

  public V_pail(): void {
    SynStart(this.syn);
    this.pail.setValue(this.pail.getValue() + 1);
    SynEnd(this.syn);
  }
}

class Older implements Runnable {
  public semaphores: Semaphores;
  public rank = new SharedNumber();
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Older';

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  run(): void {
    while (true) {
      while (!this.semaphores.P_full()) {}
      while (!this.semaphores.P_pail()) {}
      while (!this.semaphores.P_vat()) {}
      console.log(
        `Old monk ${this.rank.getValue()} gets a bucket of water from the tank.`
      );
      this.semaphores.V_vat();
      this.semaphores.V_empty();
      console.log(`Old monk ${this.rank.getValue()} drinks water.`);
      this.semaphores.V_pail();
    }
  }
}

class Younger implements Runnable {
  public semaphores: Semaphores;
  public rank = new SharedNumber();
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Younger';

  constructor(semaphores: Semaphores, rank: number) {
    this.semaphores = semaphores;
    this.rank.setValue(rank);
  }

  run(): void {
    while (true) {
      while (!this.semaphores.P_empty()) {}
      while (!this.semaphores.P_pail()) {}
      while (!this.semaphores.P_well()) {}
      console.log(
        `Young monk ${this.rank.getValue()} gets a bucket of water from the well.`
      );
      this.semaphores.V_well();
      while (!this.semaphores.P_vat()) {}
      console.log(
        `Young monk ${this.rank.getValue()} pour the water to the tank.`
      );
      this.semaphores.V_vat();
      this.semaphores.V_full();
      this.semaphores.V_pail();
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}