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
    archetype = new P1(new Semaphores());
  } else if (runnable.className === 'P2') {
    archetype = new P2(new Semaphores());
  } else if (runnable.className === 'P3') {
    archetype = new P3(new Semaphores());
  } else if (runnable.className === 'P4') {
    archetype = new P4(new Semaphores());
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Smokers {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Smokers';

  static main(args: string[]): void {
    const semaphores = new Semaphores();
    const thread1 = new Thread(new P1(semaphores));
    const thread2 = new Thread(new P2(semaphores));
    const thread3 = new Thread(new P3(semaphores));
    const thread4 = new Thread(new P4(semaphores));
    thread1.start();
    thread2.start();
    thread3.start();
    thread4.start();
  }
}

class Semaphores {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Semaphores';

  public num = new SharedNumber(0);
  public offer1 = new SharedBoolean(false);
  public offer2 = new SharedBoolean(false);
  public offer3 = new SharedBoolean(false);
  public finish = new SharedBoolean(false);

  public V_offer1(): void {
    SynStart(this.syn);
    this.offer1.setValue(true);
    SynEnd(this.syn);
  }

  public V_offer2(): void {
    SynStart(this.syn);
    this.offer2.setValue(true);
    SynEnd(this.syn);
  }

  public V_offer3(): void {
    SynStart(this.syn);
    this.offer3.setValue(true);
    SynEnd(this.syn);
  }

  public V_finish(): void {
    SynStart(this.syn);
    this.finish.setValue(true);
    SynEnd(this.syn);
  }

  public P_finish(): boolean {
    SynStart(this.syn);
    if (this.finish.getValue()) {
      this.finish.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_offer1(): boolean {
    SynStart(this.syn);
    if (this.offer1.getValue()) {
      this.offer1.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_offer2(): boolean {
    SynStart(this.syn);
    if (this.offer2.getValue()) {
      this.offer2.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public P_offer3(): boolean {
    SynStart(this.syn);
    if (this.offer3.getValue()) {
      this.offer3.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
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
    while (true) {
      const currentNum = this.semaphores.num.getValue();
      const updatedNum = (currentNum + 1) % 3;
      this.semaphores.num.setValue(updatedNum);
      if (updatedNum === 0) {
        this.semaphores.V_offer1();
      } else if (updatedNum === 1) {
        this.semaphores.V_offer2();
      } else {
        this.semaphores.V_offer3();
      }
      console.log('P1 put things onto the table.');
      while (!this.semaphores.P_finish()) {}
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

  public run(): void {
    while (true) {
      while (!this.semaphores.P_offer3()) {}
      console.log('P2 is smoking.');
      this.semaphores.V_finish();
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
      while (!this.semaphores.P_offer2()) {}
      console.log('P3 is smoking.');
      this.semaphores.V_finish();
    }
  }
}

class P4 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'P4';

  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      while (!this.semaphores.P_offer1()) {}
      console.log('P4 is smoking.');
      this.semaphores.V_finish();
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}