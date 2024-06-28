import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class ShoppingCart {

  private itemCount: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public addItem(): void {
    {
      SynStart(1, this.synArray);
      setValues(this.itemCount, getValues(this.itemCount) + 1);
      console.log("Item added. Total items in cart: " + getValues(this.itemCount));
      SynEnd(1, this.synArray);
    }
  }

  public removeItem(): void {
    {
      SynStart(2, this.synArray);
      if (getValues(this.itemCount) > 0) {
        setValues(this.itemCount, getValues(this.itemCount) - 1);
        console.log("Item removed. Total items in cart: " + getValues(this.itemCount));
      } else {
        console.log("No items to remove.");
      }
      SynEnd(2, this.synArray);
    }
  }

  public displayCart(): void {
    {
      SynStart(3, this.synArray);
      console.log("Shopping Cart contains " + getValues(this.itemCount) + " items.");
      SynEnd(3, this.synArray);
    }
  }
}

class Shopper implements Runnable {

  private cart: any = getClass('ShoppingCart', new ShoppingCart());
  private addOperations: any = getClass('number', 0);
  private removeOperations: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(cart: ShoppingCart, addOperations: number, removeOperations: number) {
    setValues(this.cart, cart);
    setValues(this.addOperations, addOperations);
    setValues(this.removeOperations, removeOperations);
  }

  run(): void {
    for (let i = 0; i < getValues(this.addOperations); i++) {
      getValues(this.cart.addItem());
    }
    for (let i = 0; i < getValues(this.removeOperations); i++) {
      getValues(this.cart.removeItem());
    }
  }
}

class ShoppingCartSystem {

  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const cart = new ShoppingCart();
    const shopper1 = new Thread(new Shopper(getValues(cart), 5, 3));
    const shopper2 = new Thread(new Shopper(getValues(cart), 3, 2));
    getValues(shopper1.start());
    getValues(shopper2.start());
  }
}