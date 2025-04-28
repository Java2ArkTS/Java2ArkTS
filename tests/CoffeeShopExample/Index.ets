import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number) {
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class CoffeeShop {
  private availableSeats: any = getClass('number', 5);
  private customersServed: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public serveCustomer(): void {
    {
      SynStart(this['synArray']);
      if (getValues(this.availableSeats) > 0) {
        setValues(this.availableSeats, getValues(this.availableSeats) - 1);
        setValues(this.customersServed, getValues(this.customersServed) + 1);
        console.log(`Customer served. Seats available: ${getValues(this.availableSeats)}. Total customers served: ${getValues(this.customersServed)}`);
        for (let i = 0; i < 100000; i++);
        setValues(this.availableSeats, getValues(this.availableSeats) + 1);
      } else {
        console.log("No seats available. Customer has to wait.");
      }
      SynEnd(this['synArray']);
    }
  }
}

class Waiter implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  private coffeeShop: any = getClass('CoffeeShop', new CoffeeShop());

  constructor(coffeeShop: CoffeeShop) {
    setValues(this.coffeeShop, coffeeShop);
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      getValues(this.coffeeShop.serveCustomer());
    }
  }
}

class CoffeeShopExample {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const coffeeShop = new CoffeeShop();
    const waiter1 = new Thread(new Waiter(coffeeShop));
    const waiter2 = new Thread(new Waiter(coffeeShop));
    waiter1.start();
    waiter2.start();
  }
}