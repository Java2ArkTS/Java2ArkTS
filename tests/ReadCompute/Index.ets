import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class ReadCompute {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const p = new Thread(new P(getValues(semaphores)));
    const p1 = new Thread(new P1(getValues(semaphores)));
    const p2 = new Thread(new P2(getValues(semaphores)));
    getValues(p.start());
    getValues(p1.start());
    getValues(p2.start());
  }
}

class Semaphores {
  public synArray : any = getSyc();
  public sharedType: string = "object";
  public mutex: any = getClass('boolean', true);
  public full: any = getClass('number', 0);
  public empty: any = getClass('number', 50);

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

  public pFull(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.full) > 0) {
      setValues(this.full, getValues(this.full) - 1);
      SynEnd(this['synArray']);
      return true;
    } else {
      SynEnd(this['synArray']);
      return false;
    }
  }

  public pEmpty(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.empty) > 0) {
      setValues(this.empty, getValues(this.empty) - 1);
      SynEnd(this['synArray']);
      return true;
    } else {
      SynEnd(this['synArray']);
      return false;
    }
  }

  public vMutex(): void {
    SynStart(this['synArray']);
    setValues(this.mutex, true);
    SynEnd(this['synArray']);
  }

  public vFull(): void {
    SynStart(this['synArray']);
    setValues(this.full, getValues(this.full) + 1);
    SynEnd(this['synArray']);
  }

  public vEmpty(): void {
    SynStart(this['synArray']);
    setValues(this.empty, getValues(this.empty) + 1);
    SynEnd(this['synArray']);
  }
}

class P implements Runnable {
  public semaphores: any = getClass('Semaphores', new Semaphores());
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run(): void {
    while (true) {
      while (!getValues(this.semaphores.pEmpty())) {
      }
      while (!getValues(this.semaphores.pMutex())) {
      }
      console.log("P reads data from device into the buffer.");
      getValues(this.semaphores.vMutex());
      getValues(this.semaphores.vFull());
    }
  }
}

class P1 implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  public semaphores: any = getClass('Semaphores');

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run(): void {
    while (true) {
      while (!getValues(this.semaphores.pFull())) {
      }
      console.log("P1 gets one data from the buffer.");
      while (!getValues(this.semaphores.pFull())) {
      }
      console.log("P1 gets one data from the buffer.");
      console.log("P1 computes the datas.");
      getValues(this.semaphores.vEmpty());
      console.log("P1 prints the result.");
      getValues(this.semaphores.vEmpty());
      console.log("P1 prints the result.");
    }
  }
}

class P2 implements Runnable {
  public semaphores: any = getClass('Semaphores', null);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run(): void {
    while (true) {
      while (!getValues(this.semaphores.pFull())) {
      }
      console.log("P2 gets one data from the buffer.");
      while (!getValues(this.semaphores.pFull())) {
      }
      console.log("P2 gets one data from the buffer.");
      console.log("P2 computes the datas.");
      getValues(this.semaphores.vEmpty());
      console.log("P2 prints the result.");
      getValues(this.semaphores.vEmpty());
      console.log("P2 prints the result.");
    }
  }
}