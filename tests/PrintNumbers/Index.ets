import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "PrintTask") {
        archetype = new PrintTask(new Printer(10)); // Assuming a default Printer instance
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class Printer {
    private currentNumber = new SharedNumber(1);
    private maxNumber: number;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Printer";

    constructor(maxNumber: number) {
        this.maxNumber = maxNumber;
    }

    public print(): void {
        SynStart(this.syn);
        while (this.currentNumber.getValue() <= this.maxNumber) {
            console.log(" printed: " + this.currentNumber.getValue());
            this.currentNumber.setValue(this.currentNumber.getValue() + 1);
        }
        SynEnd(this.syn);
    }
}

class PrintTask implements Runnable {
    private printer: Printer;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "PrintTask";

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

    public static main(args: string[]): void {
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