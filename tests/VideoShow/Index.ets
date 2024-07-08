import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class VideoShow {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const semaphores = new Semaphores();
    const show1 = new Thread(new VideoShow1(semaphores));
    const show2 = new Thread(new VideoShow2(semaphores));
    const show3 = new Thread(new VideoShow3(semaphores));
    getValues(show1.start());
    getValues(show2.start());
    getValues(show3.start());
  }
}

class Semaphores {
  public s: any = getClass('boolean', true);
  public s0: any = getClass('boolean', true);
  public s1: any = getClass('boolean', true);
  public s2: any = getClass('boolean', true);
  public count0: any = getClass('number', 0);
  public count1: any = getClass('number', 0);
  public count2: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public ps(): boolean {
    SynStart(getValues(this['synArray']));
    if (getValues(this.s)) {
      setValues(this.s, false);
      SynEnd(getValues(this['synArray']));
      return true;
    } else {
      SynEnd(getValues(this['synArray']));
      return false;
    }
  }

  // ... (other methods remain unchanged)

}

class VideoShow1 implements Runnable {
  // ... (unchanged)

}

class VideoShow2 implements Runnable {
  // ... (unchanged)

}

class VideoShow3 implements Runnable {
  // ... (unchanged)

}