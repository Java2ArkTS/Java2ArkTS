import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class ThreeThreads {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const p1 = new Thread(new P1(semaphores));
    const p2 = new Thread(new P2(semaphores));
    const p3 = new Thread(new P3(semaphores));
    getValues(p1.start());
    getValues(p2.start());
    getValues(p3.start());
  }
}

class Semaphores {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  public s1: any = getClass('number', 1);
  public s2: any = getClass('number', 0);
  public s3: any = getClass('number', 0);
  public sb: any = getClass('number', 0);
  public sy: any = getClass('number', 0);
  public sz: any = getClass('number', 0);

  public Ps1(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.s1) > 0) {
      setValues(this.s1, getValues(this.s1) - 1);
      SynEnd(this['synArray']);
      return true;
    } else {
      SynEnd(this['synArray']);
      return false;
    }
  }

  // ... (Ps2, Ps3, Psb, Psy, Psz, Vs1, Vs2, Vs3, Vsb, Vsy, Vsz methods)

}

class P1 implements Runnable {
  public semaphores: any = getClass('Semaphores', new Semaphores());
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  run(): void {
    while (!getValues(this.semaphores.Ps1())) {
    }
    console.log("P1 reads a from the input device.");
    getValues(this.semaphores.Vs2());
    while (!getValues(this.semaphores.Psb())) {
    }
    console.log("P1 computes x = a + b.");
    while (!getValues(this.semaphores.Psy())) {
    }
    while (!getValues(this.semaphores.Psz())) {
    }
    console.log("P1 prints the results of x, y and z.");
  }
}

class P2 implements Runnable {
  public semaphores: any = getClass('Semaphores');
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run(): void {
    while (!getValues(this.semaphores.Ps2())) {
    }
    console.log("P2 reads b from the input device.");
    getValues(this.semaphores.Vs3());
    getValues(this.semaphores.Vsb());
    console.log("P2 computes y = a * b.");
    getValues(this.semaphores.Vsy());
    getValues(this.semaphores.Vsy());
  }
}

class P3 implements Runnable {
  public semaphores: any = getClass('Semaphores', null);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run(): void {
    while (!getValues(this.semaphores.Ps3())) {
    }
    console.log(getValues("P3 reads c from the input device."));
    while (!getValues(this.semaphores.Psy())) {
    }
    console.log(getValues("P3 computes z = y + c - a."));
    getValues(this.semaphores.Vsz());
  }
}