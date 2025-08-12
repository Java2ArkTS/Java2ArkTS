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
  if (runnable.className === 'S2N') {
    archetype = new S2N((runnable as S2N).semaphores);
  } else if (runnable.className === 'N2S') {
    archetype = new N2S((runnable as N2S).semaphores);
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class BridgeTraffic {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'BridgeTraffic';

  static main(args: string[]): void {
    const semaphores = new Semaphores();
    const n2s = new Thread(new N2S(semaphores));
    const s2n = new Thread(new S2N(semaphores));
    n2s.start();
    s2n.start();
  }
}

class Semaphores {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Semaphores';

  public countSN = new SharedNumber(0);
  public countNS = new SharedNumber(0);
  public mutexSN = new SharedBoolean(true);
  public mutexNS = new SharedBoolean(true);
  public bridge = new SharedBoolean(true);

  public PSN(): boolean {
    SynStart(this.syn);
    if (this.mutexSN.getValue()) {
      this.mutexSN.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public PNS(): boolean {
    SynStart(this.syn);
    if (this.mutexNS.getValue()) {
      this.mutexNS.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public Pb(): boolean {
    SynStart(this.syn);
    if (this.bridge.getValue()) {
      this.bridge.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public VSN(): void {
    SynStart(this.syn);
    this.mutexSN.setValue(true);
    SynEnd(this.syn);
  }

  public VNS(): void {
    SynStart(this.syn);
    this.mutexNS.setValue(true);
    SynEnd(this.syn);
  }

  public Vb(): void {
    SynStart(this.syn);
    this.bridge.setValue(true);
    SynEnd(this.syn);
  }
}

class S2N implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'S2N';

  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      while (!this.semaphores.PSN()) {}
      if (this.semaphores.countSN.getValue() === 0) {
        while (!this.semaphores.Pb()) {}
      }
      this.semaphores.countSN.setValue(this.semaphores.countSN.getValue() + 1);
      this.semaphores.VSN();
      console.log('From S to N.');
      while (!this.semaphores.PSN()) {}
      this.semaphores.countSN.setValue(this.semaphores.countSN.getValue() - 1);
      if (this.semaphores.countSN.getValue() === 0) {
        this.semaphores.Vb();
      }
      this.semaphores.VSN();
    }
  }
}

class N2S implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'N2S';

  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (true) {
      while (!this.semaphores.PNS()) {}
      if (this.semaphores.countNS.getValue() === 0) {
        while (!this.semaphores.Pb()) {}
      }
      this.semaphores.countNS.setValue(this.semaphores.countNS.getValue() + 1);
      this.semaphores.VNS();
      console.log('From N to S.');
      while (!this.semaphores.PNS()) {}
      this.semaphores.countNS.setValue(this.semaphores.countNS.getValue() - 1);
      if (this.semaphores.countNS.getValue() === 0) {
        this.semaphores.Vb();
      }
      this.semaphores.VNS();
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}