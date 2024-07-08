import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Intersection {
  private greenLight: any = getClass('boolean', true);
  private waitingCount: any = getClass('number', 0);

  public synArray: any = getSyc();
  public sharedType: string = "object";
  
  changeLight(): void {
    setValues(this.greenLight, !getValues(this.greenLight));
    if (getValues(this.greenLight)) {
      console.log("Traffic light changes to green.");
    } else {
      console.log("Traffic light changes to red.");
    }
    SynStart(this['synArray']);
    notify(this['synArray']);
    SynEnd(this['synArray']);
  }

  isGreen(): boolean {
    return getValues(this.greenLight);
  }

  async waitToPass(): Promise<void> {
    SynStart(this['synArray']);
    setValues(this.waitingCount, getValues(this.waitingCount) + 1);
    while (!this.isGreen()) {
      await wait(this['synArray']);
    }
    setValues(this.waitingCount, getValues(this.waitingCount) - 1);
    SynEnd(this['synArray']);
  }

  getWaitingCount(): number {
    return getValues(this.waitingCount);
  }
}

class VehicleClass implements Runnable {
  private intersection: any = getClass('Intersection', new Intersection());
  private vehicleId: any = getClass('number', 0);

  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(intersection: Intersection, vehicleId: number) {
    setValues(this.intersection, intersection);
    setValues(this.vehicleId, vehicleId);
  }

  run(): void {
    while (!getValues(Thread.interrupted())) {
      try {
        getValues(Thread.sleep(1000));
        getValues(this.intersection.waitToPass());
        console.log("Vehicle " + getValues(this.vehicleId) + " passes the traffic light.");
      } catch (e) {
        if (e instanceof InterruptedException) {
          getValues(Thread.currentThread().interrupt());
        }
      }
    }
  }
}

class TrafficLightProblem {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main() {
    const intersection = new Intersection();
    for (let i = 1; i <= 10; i++) {
      const vehicleRunnable = new VehicleClass(intersection, i);
      const vehicleThread = new Thread(vehicleRunnable, "Vehicle " + i);
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
    Thread.getAllStackTraces().keys().forEach(thread => {
      if (thread.getName().startsWith("Vehicle")) {
        thread.interrupt();
      }
    });
  }
}

class Intersection {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  private greenLight: AtomicBoolean = new AtomicBoolean(true);
  private waitingCount: AtomicInteger = new AtomicInteger(0);

  changeLight() {
    getValues(this.greenLight).set(!getValues(this.greenLight).get());
    if (getValues(this.greenLight).get()) {
      console.log("Traffic light changes to green.");
    } else {
      console.log("Traffic light changes to red.");
    }
    synchronized(this, () => {
      notifyAll();
    });
  }

  isGreen(): boolean {
    return getValues(this.greenLight).get();
  }

  async waitToPass() {
    getValues(this.waitingCount).incrementAndGet();
    while (!getValues(this.isGreen())) {
      await wait(this);
    }
    getValues(this.waitingCount).decrementAndGet();
  }

  getWaitingCount(): number {
    return getValues(this.waitingCount).get();
  }
}

class VehicleClass implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  private intersection: Intersection;
  private vehicleId: number;

  constructor(intersection: Intersection, vehicleId: number) {
    setValues(this.intersection, intersection);
    setValues(this.vehicleId, vehicleId);
  }

  async run() {
    while (!Thread.interrupted()) {
      try {
        await Thread.sleep(1000);
        await getValues(this.intersection).waitToPass();
        console.log(`Vehicle ${getValues(this.vehicleId)} passes the traffic light.`);
      } catch (e) {
        Thread.currentThread().interrupt();
      }
    }
  }
}