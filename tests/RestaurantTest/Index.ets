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
  if (runnable.className === 'Customer') {
    archetype = new Customer(new Restaurant(0), '', '');
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Restaurant {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Restaurant';

  private availableSeats = new SharedNumber();

  constructor(seats: number) {
    this.availableSeats.setValue(seats);
  }

  public takeSeat(customerName: string): void {
    SynStart(this.syn);
    if (this.availableSeats.getValue() > 0) {
      this.availableSeats.setValue(this.availableSeats.getValue() - 1);
      console.log(
        `${customerName} took a seat. Available seats: ${this.availableSeats.getValue()}`
      );
    } else {
      console.log(`No available seats for ${customerName}`);
    }
    SynEnd(this.syn);
  }

  public placeOrder(customerName: string, order: string): void {
    SynStart(this.syn);
    console.log(`${customerName} placed order: ${order}`);
    SynEnd(this.syn);
  }

  public leaveSeat(customerName: string): void {
    SynStart(this.syn);
    this.availableSeats.setValue(this.availableSeats.getValue() + 1);
    console.log(
      `${customerName} left the seat. Available seats: ${this.availableSeats.getValue()}`
    );
    SynEnd(this.syn);
  }
}

class Customer implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Customer';

  private restaurant: Restaurant;
  private name = new SharedString();
  private order = new SharedString();

  constructor(restaurant: Restaurant, name: string, order: string) {
    this.restaurant = restaurant;
    this.name.setValue(name);
    this.order.setValue(order);
  }

  run(): void {
    this.restaurant.takeSeat(this.name.getValue());
    this.restaurant.placeOrder(this.name.getValue(), this.order.getValue());
    this.restaurant.leaveSeat(this.name.getValue());
  }
}

class RestaurantTest {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'RestaurantTest';

  static main(args: string[]): void {
    const restaurant = new Restaurant(5);
    const customer1 = new Thread(new Customer(restaurant, 'Alice', 'Pizza'));
    const customer2 = new Thread(new Customer(restaurant, 'Bob', 'Burger'));
    const customer3 = new Thread(new Customer(restaurant, 'Charlie', 'Salad'));
    customer1.start();
    customer2.start();
    customer3.start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}