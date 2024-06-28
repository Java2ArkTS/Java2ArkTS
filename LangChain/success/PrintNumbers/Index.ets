import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Printer {
  private currentNumber: any = getClass('number', 1);
  private maxNumber: any;

  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(maxNumber: number) {
    this.maxNumber = getClass('number', maxNumber);
  }

  public print(): void {
    SynStart(1, this.synArray);
    while (getValues(this.currentNumber) <= getValues(this.maxNumber)) {
      console.log(" printed: " + getValues(this.currentNumber));
      setValues(this.currentNumber, getValues(this.currentNumber) + 1);
    }
    SynEnd(1, this.synArray);
  }
}

class PrintTask implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  private printer: any;

  constructor(printer: Printer) {
    this.printer = getClass('Printer', printer);
  }

  run(): void {
    getValues(this.printer.print());
  }
}

export class PrintNumbers {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const printer = new Printer(10);
    const thread1 = new Thread(new PrintTask(printer));
    const thread2 = new Thread(new PrintTask(printer));
    thread1.start();
    thread2.start();
  }
}