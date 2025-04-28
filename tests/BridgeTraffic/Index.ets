import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number) {
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class BridgeTraffic {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const n2s = new Thread(new N2S(getValues(semaphores)));
    const s2n = new Thread(new S2N(getValues(semaphores)));
    getValues(n2s.start());
    getValues(s2n.start());
  }
}

class Semaphores {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  public countSN: any = getClass('number', 0);
  public countNS: any = getClass('number', 0);
  public mutexSN: any = getClass('boolean', true);
  public mutexNS: any = getClass('boolean', true);
  public bridge: any = getClass('boolean', true);
  public PSN(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.mutexSN)) {
      setValues(this.mutexSN, false);
      SynEnd(this['synArray']);
      return true;
    } else {
      SynEnd(this['synArray']);
      return false;
    }
  }
  public PNS(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.mutexNS)) {
      setValues(this.mutexNS, false);
      SynEnd(this['synArray']);
      return true;
    } else {
      SynEnd(this['synArray']);
      return false;
    }
  }
  public Pb(): boolean {
    SynStart(this['synArray']);
    if (getValues(this.bridge)) {
      setValues(this.bridge, false);
      SynEnd(this['synArray']);
      return true;
    } else {
      SynEnd(this['synArray']);
      return false;
    }
  }
  public VSN(): void {
    SynStart(this['synArray']);
    setValues(this.mutexSN, true);
    SynEnd(this['synArray']);
  }
  public VNS(): void {
    SynStart(this['synArray']);
    setValues(this.mutexNS, true);
    SynEnd(this['synArray']);
  }
  public Vb(): void {
    SynStart(this['synArray']);
    setValues(this.bridge, true);
    SynEnd(this['synArray']);
  }
}

class S2N implements Runnable {
  public semaphores: any = getClass('Semaphores');
  public synArray: any = getSyc();
  public sharedType: string = "object";
  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }
  public run() {
    while (true) {
      while (!getValues(this.semaphores.PSN())) {
      }
      if (getValues(this.semaphores.countSN) === 0) {
        while (!getValues(this.semaphores.Pb())) {
        }
      }
      setValues(this.semaphores.countSN, getValues(this.semaphores.countSN) + 1);
      getValues(this.semaphores.VSN());
      console.log("From S to N.");
      while (!getValues(this.semaphores.PSN())) {
      }
      setValues(this.semaphores.countSN, getValues(this.semaphores.countSN) - 1);
      if (getValues(this.semaphores.countSN) === 0) {
        getValues(this.semaphores.Vb());
      }
      getValues(this.semaphores.VSN());
    }
  }
}

class N2S implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  public semaphores: any = getClass('Semaphores', new Semaphores());
  constructor(semaphores: Semaphores) {
    setValues(this.semaphores, semaphores);
  }
  public run(): void {
    while (true) {
      while (!getValues(this.semaphores.PNS())) {
      }
      if (getValues(this.semaphores.countNS) === 0) {
        while (!getValues(this.semaphores.Pb())) {
        }
      }
      setValues(this.semaphores.countNS, getValues(this.semaphores.countNS) + 1);
      getValues(this.semaphores.VNS());
      console.log("From N to S.");
      while (!getValues(this.semaphores.PNS())) {
      }
      setValues(this.semaphores.countNS, getValues(this.semaphores.countNS) - 1);
      if (getValues(this.semaphores.countNS) === 0) {
        getValues(this.semaphores.Vb());
      }
      getValues(this.semaphores.VNS());
    }
  }
}