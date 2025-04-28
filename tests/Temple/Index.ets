import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Temple {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const younger1 = new Thread(new Younger(getValues(semaphores), 1));
    const younger2 = new Thread(new Younger(getValues(semaphores), 2));
    const older1 = new Thread(new Older(getValues(semaphores), 1));
    const older2 = new Thread(new Older(getValues(semaphores), 2));
    getValues(younger1.start());
    getValues(younger2.start());
    getValues(older1.start());
    getValues(older2.start());
  }
}

class Semaphores {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public well: any = getClass('boolean', true);

  public vat: any = getClass('boolean', true);

  public empty: any = getClass('number', 10);

  public full: any = getClass('number', 0);

  public pail: any = getClass('number', 3);

  public P_well(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.well)) {
      setValues(this.well, false);
      SynEnd(this['synArray']);
      return true;
    } else {
      SynEnd(this['synArray']);
      return false;
    }
  }
  // ... (other methods omitted for brevity)
}

class Older implements Runnable {
  public semaphores: any = getClass('Semaphores', new Semaphores());
  public rank: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores, rank: number) {
    setValues(this.semaphores, semaphores);
    setValues(this.rank, rank);
  }

  public run(): void {
    // ... (code omitted for brevity)
  }
}

class Younger implements Runnable {
  public semaphores: any = getClass('Semaphores', new Semaphores());
  public rank: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(semaphores: Semaphores, rank: number) {
    setValues(this.semaphores, semaphores);
    setValues(this.rank, rank);
  }

  public run(): void {
    // ... (code omitted for brevity)
  }
}