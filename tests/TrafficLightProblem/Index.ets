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

  if (runnable.className === 'VehicleClass') {
    archetype = new VehicleClass(new Intersection(), 0);
  } else {
    archetype = new Thread();
  }

  addFunc(runnable, archetype);
  runnable.run();
}

class Intersection {
  private greenLight = new SharedBoolean(true);
  private waitingCount = new SharedNumber(0);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Intersection';

  changeLight(): void {
    this.greenLight.setValue(!this.greenLight.getValue());
    if (this.greenLight.getValue()) {
      console.log('Traffic light changes to green.');
    } else {
      console.log('Traffic light changes to red.');
    }
    {
      SynStart(this.syn);
      notify(this.syn);
      SynEnd(this.syn);
    }
  }

  isGreen(): boolean {
    return this.greenLight.getValue();
  }

  async waitToPass(): Promise<void> {
    {
      SynStart(this.syn);
      this.waitingCount.setValue(this.waitingCount.getValue() + 1);
      while (!this.isGreen()) {
        await wait(this.syn);
      }
      this.waitingCount.setValue(this.waitingCount.getValue() - 1);
      SynEnd(this.syn);
    }
  }

  getWaitingCount(): number {
    return this.waitingCount.getValue();
  }
}

class VehicleClass implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'VehicleClass';

  private intersection: Intersection;
  private vehicleId = new SharedNumber();

  constructor(intersection: Intersection, vehicleId: number) {
    this.intersection = intersection;
    this.vehicleId.setValue(vehicleId);
  }

  run(): void {
    while (!Thread.interrupted()) {
      try {
        Thread.sleep(1000);
        this.intersection.waitToPass();
        console.log(`Vehicle ${this.vehicleId.getValue()} passes the traffic light.`);
      } catch (e) {
        if (e instanceof InterruptedException) {
          Thread.currentThread().interrupt();
        }
      }
    }
  }
}

class TrafficLightProblem {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'TrafficLightProblem';

  static main(): void {
    const intersection = new Intersection();
    for (let i = 1; i <= 10; i++) {
      const vehicleThread = new Thread(new VehicleClass(intersection, i), `Vehicle ${i}`);
      vehicleThread.start();
    }
    for (let i = 0; i < 5; i++) {
      intersection.changeLight();
      try {
        Thread.sleep(3000);
      } catch (e) {
        console.error(e);
      }
    }
    for (const thread of Thread.getAllStackTraces().keys()) {
      if (thread.getName().startsWith('Vehicle')) {
        thread.interrupt();
      }
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}