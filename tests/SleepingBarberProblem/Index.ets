import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "Customer") {
        archetype = new Customer(new BarberShop(3), 1);
    } else if (runnable.className == "Barber") {
        archetype = new Barber(new BarberShop(3));
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class BarberShop {
    private readonly chairs: number;
    private sleeping = new SharedBoolean(true);
    private cutting = new SharedBoolean(false);
    private waiting = new SharedNumber(0);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "BarberShop";

    constructor(chairs: number) {
        this.chairs = chairs;
        this.syn = {};
    }

    async customerArrived(customerId: number): Promise<void> {
        SynStart(this.syn);
        while (this.waiting.getValue() === this.chairs || this.cutting.getValue()) {
            console.log(`No free chairs or barber is busy, customer ${customerId} leaves.`);
            await wait(this.syn);
        }
        this.waiting.setValue(this.waiting.getValue() + 1);
        console.log(`Customer ${customerId} sits in the waiting room.`);
        if (this.sleeping.getValue()) {
            console.log("Barber wakes up.");
            this.sleeping.setValue(false);
        }
        this.waiting.setValue(this.waiting.getValue() - 1);
        console.log(`Customer ${customerId} is having a haircut.`);
        SynEnd(this.syn);
    }

    startCutting(): void {
        SynStart(this.syn);
        this.cutting.setValue(true);
        console.log("Barber starts cutting hair.");
        SynEnd(this.syn);
    }

    finishCutting(): void {
        SynStart(this.syn);
        this.cutting.setValue(false);
        console.log("Barber finishes cutting hair.");
        notify(this.syn);
        SynEnd(this.syn);
    }

    async sleep(): Promise<void> {
        SynStart(this.syn);
        console.log("Barber goes to sleep.");
        this.sleeping.setValue(true);
        while (this.waiting.getValue() === 0) {
            await wait(this.syn);
        }
        console.log("Barber wakes up.");
        this.sleeping.setValue(false);
        SynEnd(this.syn);
    }
}

class Customer implements Runnable {
    private barberShop: BarberShop;
    private customerId = new SharedNumber(customerId);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Customer";

    constructor(barberShop: BarberShop, customerId: number) {
        this.barberShop = barberShop;
        this.customerId.setValue(customerId);
    }

    run(): void {
        try {
            this.barberShop.customerArrived(this.customerId.getValue());
            this.barberShop.startCutting();
            Thread.sleep(2000);
            this.barberShop.finishCutting();
        } catch (e) {
            if (e instanceof InterruptedException) {
                console.error(e);
            }
        }
    }
}

class Barber implements Runnable {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Barber";
    private barberShop: BarberShop;

    constructor(barberShop: BarberShop) {
        this.barberShop = barberShop;
    }

    run(): void {
        try {
            while (true) {
                this.barberShop.sleep();
                this.barberShop.startCutting();
                Thread.sleep(2000);
                this.barberShop.finishCutting();
            }
        } catch (e) {
            if (e instanceof InterruptedException) {
                console.error(e);
            }
        }
    }
}

class SleepingBarberProblem {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "SleepingBarberProblem";

    static main(args: string[]): void {
        const barberShop = new BarberShop(3);
        const barberThread = new Thread(new Barber(barberShop), "Barber");
        barberThread.start();
        for (let i = 1; i <= 10; i++) {
            const customerThread = new Thread(new Customer(barberShop, i), "Customer " + i);
            customerThread.start();
        }
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}