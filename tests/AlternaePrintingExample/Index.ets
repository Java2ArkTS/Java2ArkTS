import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "OddNumberTask") {
    archetype = new OddNumberTask(new NumberPrinter());
  } else if (runnable.className == "EvenNumberTask") {
    archetype = new EvenNumberTask(new NumberPrinter());
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class AlternatePrintingExample {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "AlternatePrintingExample";

  static main(args: string[]): void {
    const printer = new NumberPrinter();
    const oddThread = new Thread(new OddNumberTask(printer));
    oddThread.start();
    const evenThread = new Thread(new EvenNumberTask(printer));
    evenThread.start();
  }
}

class NumberPrinter {
  private number = new SharedNumber(1);
  private readonly maxNumber: number = 10;
  private isOddTurn = new SharedBoolean(true);
  
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "NumberPrinter";

  public printOdd(): void {
    SynStart(this.syn);
    while (this.number.getValue() <= this.maxNumber) {
      if (this.isOddTurn.getValue() && this.number.getValue() % 2 !== 0) {
        console.log(Thread.currentThread().getName() + " - Odd: " + this.number.getValue());
        this.number.setValue(this.number.getValue() + 1);
        this.isOddTurn.setValue(false);
      }
    }
    SynEnd(this.syn);
  }

  public printEven(): void {
    SynStart(this.syn);
    while (this.number.getValue() <= this.maxNumber) {
      if (!this.isOddTurn.getValue() && this.number.getValue() % 2 === 0) {
        console.log(Thread.currentThread().getName() + " - Even: " + this.number.getValue());
        this.number.setValue(this.number.getValue() + 1);
        this.isOddTurn.setValue(true);
      }
    }
    SynEnd(this.syn);
  }
}

class OddNumberTask implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "OddNumberTask";
  private readonly printer: NumberPrinter;

  constructor(printer: NumberPrinter) {
    this.printer = printer;
  }

  run(): void {
    this.printer.printOdd();
  }
}

class EvenNumberTask implements Runnable {
  private readonly printer: NumberPrinter;
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "EvenNumberTask";

  constructor(printer: NumberPrinter) {
    this.printer = printer;
  }

  run(): void {
    this.printer.printEven();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}