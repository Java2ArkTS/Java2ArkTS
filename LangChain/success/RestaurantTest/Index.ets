import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Restaurant {

    private availableSeats: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(seats: number) {
        setValues(this.availableSeats, seats);
    }

    public takeSeat(customerName: string): void {
        {
            SynStart(1, this.synArray);
            if (getValues(this.availableSeats) > 0) {
                setValues(this.availableSeats, getValues(this.availableSeats) - 1);
                console.log(`${customerName} took a seat. Available seats: ${getValues(this.availableSeats)}`);
            } else {
                console.log(`No available seats for ${customerName}`);
            }
            SynEnd(1, this.synArray);
        }
    }

    public placeOrder(customerName: string, order: string): void {
        {
            SynStart(2, this.synArray);
            console.log(`${customerName} placed order: ${order}`);
            SynEnd(2, this.synArray);
        }
    }

    public leaveSeat(customerName: string): void {
        {
            SynStart(3, this.synArray);
            setValues(this.availableSeats, getValues(this.availableSeats) + 1);
            console.log(`${customerName} left the seat. Available seats: ${getValues(this.availableSeats)}`);
            SynEnd(3, this.synArray);
        }
    }
}

class Customer implements Runnable {

    private restaurant: any = getClass('Restaurant', new Restaurant(5));
    private name: any = getClass('string', "DefaultName");
    private order: any = getClass('string', "DefaultOrder");
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(restaurant: Restaurant, name: string, order: string) {
        setValues(this.restaurant, restaurant);
        setValues(this.name, name);
        setValues(this.order, order);
    }

    run(): void {
        getValues(this.restaurant.takeSeat(getValues(this.name)));
        getValues(this.restaurant.placeOrder(getValues(this.name), getValues(this.order)));
        getValues(this.restaurant.leaveSeat(getValues(this.name)));
    }
}

class RestaurantTest {

    public synArray : any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const restaurant = new Restaurant(5);
        const customer1 = new Thread(new Customer(restaurant, "Alice", "Pizza"));
        const customer2 = new Thread(new Customer(restaurant, "Bob", "Burger"));
        const customer3 = new Thread(new Customer(restaurant, "Charlie", "Salad"));
        getValues(customer1.start());
        getValues(customer2.start());
        getValues(customer3.start());
    }
}