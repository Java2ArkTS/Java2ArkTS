import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class PQR {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const p = new Thread(new P(semaphores));
    const q = new Thread(new Q(semaphores));
    const r = new Thread(new R(semaphores));
    p.start();
    q.start();
    r.start();
  }
}

class Semaphores {
  public full: any = getClass('boolean', false);
  public empty: any = getClass('boolean', true);
  public mutex: any = getClass('boolean', true);
  public synArray : any = getSyc();
  public sharedType: string = "object";

  public pFull(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.full)) {
      setValues(this.full, false);
      SynEnd(this['synArray']);
      return true;
    }
    SynEnd(this['synArray']);
    return false;
  }

  // ... (other methods)

  public vMutex(): void {
    SynStart(this['synArray']);
    setValues(this.mutex, true);
    SynEnd(this['synArray']);
  }
}

class P implements Runnable {
  public semaphores: any = getClass('Semaphores');
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
      console.log("P produces one.");
      getValues(this.semaphores.vMutex());
      getValues(this.semaphores.vFull());
    }
  }
}

// ... (other classes)