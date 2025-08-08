import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "Waiter") {
        archetype = new Waiter(new CoffeeShop());
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class CoffeeShop {

    private availableSeats = new SharedNumber(5);

    private customersServed = new SharedNumber(0);

    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "CoffeeShop";

    public serveCustomer(): void {
        {
            SynStart(this.syn);
            if (this.availableSeats.getValue() > 0) {
                this.availableSeats.setValue(this.availableSeats.getValue() - 1);
                this.customersServed.setValue(this.customersServed.getValue() + 1);
                console.log(`Customer served. Seats available: ${this.availableSeats.getValue()}. Total customers served: ${this.customersServed.getValue()}`);
                for (let i = 0; i < 100000; i++);
                this.availableSeats.setValue(this.availableSeats.getValue() + 1);
            } else {
                console.log("No seats available. Customer has to wait.");
            }
            SynEnd(this.syn);
        }
    }
}

class Waiter implements Runnable {

    private coffeeShop: CoffeeShop;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Waiter";

    constructor(coffeeShop: CoffeeShop) {
        this.coffeeShop = coffeeShop;
    }

    run(): void {
        for (let i = 0; i < 10; i++) {
            this.coffeeShop.serveCustomer();
        }
    }
}

class CoffeeShopExample {

    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "CoffeeShopExample";

    public static main(args: string[]): void {
        const coffeeShop = new CoffeeShop();
        const waiter1 = new Thread(new Waiter(coffeeShop));
        const waiter2 = new Thread(new Waiter(coffeeShop));
        waiter1.start();
        waiter2.start();
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}