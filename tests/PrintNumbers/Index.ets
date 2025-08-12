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
  if (runnable.className === "PrintTask") {
    archetype = new PrintTask(new Printer(10));
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Printer {
  private currentNumber = new SharedNumber(1);
  private maxNumber = new SharedNumber();
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Printer";

  constructor(maxNumber: number) {
    this.maxNumber.setValue(maxNumber);
  }

  public print(): void {
    {
      SynStart(this.syn);
      while (this.currentNumber.getValue() <= this.maxNumber.getValue()) {
        console.log(" printed: " + this.currentNumber.getValue());
        this.currentNumber.setValue(this.currentNumber.getValue() + 1);
      }
      SynEnd(this.syn);
    }
  }
}

class PrintTask implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "PrintTask";

  private printer: Printer;

  constructor(printer: Printer) {
    this.printer = printer;
  }

  run(): void {
    this.printer.print();
  }
}

class PrintNumbers {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "PrintNumbers";

  static main(args: string[]): void {
    const printer = new Printer(10);
    const thread1 = new Thread(new PrintTask(printer));
    const thread2 = new Thread(new PrintTask(printer));
    thread1.start();
    thread2.start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}