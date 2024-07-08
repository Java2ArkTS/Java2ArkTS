import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Bike {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  static main(args: string[]): void {
    const semaphores = new Semaphores();
    const worker1 = new Thread(new Worker1(semaphores));
    const worker2 = new Thread(new Worker2(semaphores));
    const worker3 = new Thread(new Worker3(semaphores));
    worker1.start();
    worker2.start();
    worker3.start();
  }
}

class Semaphores {
  public empty: any = getClass('number', 5);
  public wheel: any = getClass('number', 0);
  public frame: any = getClass('number', 0);
  public s1: any = getClass('number', 3);
  public s2: any = getClass('number', 4);
  private synArray: any = getClass('object', {}); 
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public ps1(): boolean {
    SynStart(this.synArray);
    if (getValues(this.s1) > 0) {
      setValues(this.s1, getValues(this.s1) - 1);
      SynEnd(this.synArray);
      return true;
    }
    SynEnd(this.synArray);
    return false;
  }
  // ... (other methods)
}

class Worker1 implements Runnable {
  semaphores: any = getClass('Semaphores', new Semaphores());
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  run(): void {
    while (true) {
      console.log("Worker1 produces a frame.");
      while (!getValues(this.semaphores.ps1())) {
      }
      while (!getValues(this.semaphores.pEmpty())) {
      }
      console.log("Worker1 puts a frame into the box.");
      getValues(this.semaphores.vFrame());
    }
  }
}

class Worker2 implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  public semaphores: any = getClass('Semaphores', new Semaphores());

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run() {
    while (true) {
      console.log("Worker2 produces a wheel.");
      while (!getValues(this.semaphores.ps2())) {}
      while (!getValues(this.semaphores.pEmpty())) {}
      console.log("Worker2 puts a wheel into the box.");
      getValues(this.semaphores.vWheel());
    }
  }
}

class Worker3 implements Runnable {
  public semaphores: any = getClass('Semaphores', new Semaphores());
  public synArray : any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run(): void {
    while (true) {
      while (!getValues(this.semaphores.pFrame())) {}
      console.log("Worker3 gets a frame from the box.");
      getValues(this.semaphores.vEmpty());
      getValues(this.semaphores.vs1());
      while (!getValues(this.semaphores.pWheel())) {}
      while (!getValues(this.semaphores.pWheel())) {}
      console.log("Worker3 gets two wheels from the box.");
      getValues(this.semaphores.vEmpty());
      getValues(this.semaphores.vEmpty());
      getValues(this.semaphores.vs2());
      getValues(this.semaphores.vs2());
      console.log("Worker3 assembles a frame and two wheels to produce a bike.");
    }
  }
}

Bike.main();

class Worker1 implements Runnable {
  semaphores: any = getClass('Semaphores', this.semaphores);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  run(): void {
    while (true) {
      console.log("Worker1 produces a frame.");
      while (!getValues(this.semaphores.ps1())) {
      }
      while (!getValues(this.semaphores.pEmpty())) {
      }
      console.log("Worker1 puts a frame into the box.");
      getValues(this.semaphores.vFrame());
    }
  }
}

class Worker2 implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  public semaphores: any = getClass('Semaphores', new Semaphores());

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run() {
    while (true) {
      console.log("Worker2 produces a wheel.");
      while (!getValues(this.semaphores.ps2())) {}
      while (!getValues(this.semaphores.pEmpty())) {}
      console.log("Worker2 puts a wheel into the box.");
      getValues(this.semaphores.vWheel());
    }
  }
}

class Worker3 implements Runnable {
  public semaphores: Semaphores = getClass('Semaphores', semaphores);
  public synArray : any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run(): void {
    while (true) {
      while (!getValues(this.semaphores.pFrame())) {}
      console.log("Worker3 gets a frame from the box.");
      getValues(this.semaphores.vEmpty());
      getValues(this.semaphores.vs1());
      while (!getValues(this.semaphores.pWheel())) {}
      while (!getValues(this.semaphores.pWheel())) {}
      console.log("Worker3 gets two wheels from the box.");
      getValues(this.semaphores.vEmpty());
      getValues(this.semaphores.vEmpty());
      getValues(this.semaphores.vs2());
      getValues(this.semaphores.vs2());
      console.log("Worker3 assembles a frame and two wheels to produce a bike.");
    }
  }
}