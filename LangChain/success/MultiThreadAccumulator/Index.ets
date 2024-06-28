import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Accumulator {

  private sum: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public addToSum(value: number): void {
    {
      SynStart(1, this.synArray);
      setValues(this.sum, getValues(this.sum) + value);
      console.log(" added " + value + ". Current sum: " + getValues(this.sum));
      SynEnd(1, this.synArray);
    }
  }

  public getSum(): number {
    {
      SynStart(2, this.synArray);
      const result = getValues(this.sum);
      SynEnd(2, this.synArray);
      return result;
    }
  }
}

class AdderTask implements Runnable {

  public synArray: any = getSyc();
  public sharedType: string = "object";
  private accumulator: any = getClass('Accumulator', new Accumulator());
  private valueToAdd: any = getClass('number', 0);

  constructor(accumulator: Accumulator, valueToAdd: number) {
    setValues(this.accumulator, accumulator);
    setValues(this.valueToAdd, valueToAdd);
  }

  run(): void {
    getValues(this.accumulator.addToSum(getValues(this.valueToAdd)));
  }
}

class MultiThreadAccumulator {

  public synArray : any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const accumulator = new Accumulator();
    const thread1 = new Thread(new AdderTask(accumulator, 5));
    const thread2 = new Thread(new AdderTask(accumulator, 10));
    thread1.start();
    thread2.start();
  }
}