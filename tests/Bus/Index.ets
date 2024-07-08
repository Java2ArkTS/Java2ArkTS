import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Bus {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    let semaphores = new Semaphores();
    let driver = new Thread(new Driver(semaphores));
    let conductor = new Thread(new Conductor(semaphores));
    getValues(driver.start());
    getValues(conductor.start());
  }
}

class Semaphores {
  public s1: any = getClass('boolean', false);
  public s2: any = getClass('boolean', false);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public ps1(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.s1)) {
        setValues(this.s1, false);
        SynEnd(this['synArray']);
        return true;
    } else {
        SynEnd(this['synArray']);
        return false;
    }
  }

  public ps2(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.s2)) {
        setValues(this.s2, false);
        SynEnd(this['synArray']);
        return true;
    } else {
        SynEnd(this['synArray']);
        return false;
    }
  }

  public vs1(): void {
    SynStart(this['synArray']);
    setValues(this.s1, true);
    SynEnd(this['synArray']);
  }

  public vs2(): void {
    SynStart(this['synArray']);
    setValues(this.s2, true);
    SynEnd(this['synArray']);
  }
}

class Driver implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  public semaphores: any = getClass('Semaphores', new Semaphores());

  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run(): void {
    while (true) {
        while (!getValues(this.semaphores.ps1())) {
        }
        console.log("Bus starts.");
        console.log("Driver is driving.");
        console.log("Bus stops.");
        getValues(this.semaphores.vs2());
    }
  }
}

class Conductor implements Runnable {
  public semaphores: Semaphores = getClass('Semaphores', new Semaphores());
  public synArray : any = getSyc();
  public sharedType: string = "object";

  public constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }

  public run(): void {
    while (true) {
        console.log("Conductor closes the door.");
        getValues(this.semaphores.vs1());
        console.log("Conductor sells tickets.");
        while (!getValues(this.semaphores.ps2())) {
        }
        console.log("Conductor opens the door.");
        console.log("Customers get on/off the bus.");
    }
  }
}