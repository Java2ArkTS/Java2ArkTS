import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class AlternatePrintingExample {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const printer: NumberPrinter = new NumberPrinter();
    const oddThread: Thread = new Thread(new OddNumberTask(printer));
    getValues(oddThread.start());
    const evenThread: Thread = new Thread(new EvenNumberTask(printer));
    getValues(evenThread.start());
  }
}

class NumberPrinter {
  private number: any = getClass('number', 1);
  private readonly MAX: any = getClass('number', 10);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public printOdd(): void {
    while (getValues(this.number) <= getValues(this.MAX)) {
      SynStart(getValues(this['synArray']));
      while (getValues(this.number) % 2 === 0) {
        getValues(wait(getValues(this['synArray'])));
      }
      console.log(Thread.currentThread().getName() + " - " + getValues(this.number));
      setValues(this.number, getValues(this.number) + 1);
      getValues(notify(getValues(this['synArray'])));
      SynEnd(getValues(this['synArray']));
    }
  }

  public printEven(): void {
    while (getValues(this.number) <= getValues(this.MAX)) {
      SynStart(getValues(this['synArray']));
      while (getValues(this.number) % 2 !== 0) {
        getValues(wait(getValues(this['synArray'])));
      }
      console.log(Thread.currentThread().getName() + " - " + getValues(this.number));
      setValues(this.number, getValues(this.number) + 1);
      getValues(notify(getValues(this['synArray'])));
      SynEnd(getValues(this['synArray']));
    }
  }
}

class OddNumberTask implements Runnable {
  private printer: any;

  constructor(printer: NumberPrinter) {
    setValues(this.printer, printer);
  }

  run(): void {
    getValues(this.printer.printOdd());
  }
}

class EvenNumberTask implements Runnable {
  private printer: any;

  constructor(printer: NumberPrinter) {
    setValues(this.printer, printer);
  }

  run(): void {
    getValues(this.printer.printEven());
  }
}