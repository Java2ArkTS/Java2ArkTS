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
} from "./ThreadBridge";

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;

  if (runnable.className === "VideoShow1") {
    archetype = new VideoShow1((runnable as VideoShow1).semaphores);
  } else if (runnable.className === "VideoShow2") {
    archetype = new VideoShow2((runnable as VideoShow2).semaphores);
  } else if (runnable.className === "VideoShow3") {
    archetype = new VideoShow3((runnable as VideoShow3).semaphores);
  } else {
    archetype = new Thread();
  }

  addFunc(runnable, archetype);
  runnable.run();
}

class VideoShow {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "VideoShow";

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const show1 = new Thread(new VideoShow1(semaphores));
    const show2 = new Thread(new VideoShow2(semaphores));
    const show3 = new Thread(new VideoShow3(semaphores));
    show1.start();
    show2.start();
    show3.start();
  }
}

class Semaphores {
  public s = new SharedBoolean(true);
  public s0 = new SharedBoolean(true);
  public s1 = new SharedBoolean(true);
  public s2 = new SharedBoolean(true);
  public count0 = new SharedNumber(0);
  public count1 = new SharedNumber(0);
  public count2 = new SharedNumber(0);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Semaphores";

  public ps(): boolean {
    SynStart(this.syn);
    if (this.s.getValue()) {
      this.s.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public ps0(): boolean {
    SynStart(this.syn);
    if (this.s0.getValue()) {
      this.s0.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public ps1(): boolean {
    SynStart(this.syn);
    if (this.s1.getValue()) {
      this.s1.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public ps2(): boolean {
    SynStart(this.syn);
    if (this.s2.getValue()) {
      this.s2.setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public vs(): void {
    SynStart(this.syn);
    this.s.setValue(true);
    SynEnd(this.syn);
  }

  public vs0(): void {
    SynStart(this.syn);
    this.s0.setValue(true);
    SynEnd(this.syn);
  }

  public vs1(): void {
    SynStart(this.syn);
    this.s1.setValue(true);
    SynEnd(this.syn);
  }

  public vs2(): void {
    SynStart(this.syn);
    this.s2.setValue(true);
    SynEnd(this.syn);
  }
}

class VideoShow1 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "VideoShow1";
  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (!this.semaphores.ps0()) {}
    this.semaphores.count0.setValue(this.semaphores.count0.getValue() + 1);
    if (this.semaphores.count0.getValue() === 1) {
      while (!this.semaphores.ps()) {}
    }
    this.semaphores.vs0();
    console.log("Video show 1 begins.");
    while (!this.semaphores.ps0()) {}
    this.semaphores.count0.setValue(this.semaphores.count0.getValue() - 1);
    if (this.semaphores.count0.getValue() === 0) {
      console.log("Video show 1 ends.");
      this.semaphores.vs();
    }
    this.semaphores.vs0();
  }
}

class VideoShow2 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "VideoShow2";
  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  public run(): void {
    while (!this.semaphores.ps1()) {}
    this.semaphores.count1.setValue(this.semaphores.count1.getValue() + 1);
    if (this.semaphores.count1.getValue() === 1) {
      while (!this.semaphores.ps()) {}
    }
    this.semaphores.vs1();
    console.log("Video show 2 begins.");
    while (!this.semaphores.ps1()) {}
    this.semaphores.count1.setValue(this.semaphores.count1.getValue() - 1);
    if (this.semaphores.count1.getValue() === 0) {
      console.log("Video show 2 ends.");
      this.semaphores.vs();
    }
    this.semaphores.vs1();
  }
}

class VideoShow3 implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "VideoShow3";
  public semaphores: Semaphores;

  constructor(semaphores: Semaphores) {
    this.semaphores = semaphores;
  }

  run(): void {
    while (!this.semaphores.ps2()) {}
    this.semaphores.count2.setValue(this.semaphores.count2.getValue() + 1);
    if (this.semaphores.count2.getValue() === 1) {
      while (!this.semaphores.ps()) {}
    }
    this.semaphores.vs2();
    console.log("Video show 3 begins.");
    while (!this.semaphores.ps2()) {}
    this.semaphores.count2.setValue(this.semaphores.count2.getValue() - 1);
    if (this.semaphores.count2.getValue() === 0) {
      console.log("Video show 3 ends.");
      this.semaphores.vs();
    }
    this.semaphores.vs2();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}