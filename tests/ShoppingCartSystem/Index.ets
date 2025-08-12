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
  if (runnable.className === 'Shopper') {
    archetype = new Shopper(new ShoppingCart(), 0, 0);
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class ShoppingCart {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ShoppingCart';

  private itemCount = new SharedNumber(0);

  public addItem(): void {
    SynStart(this.syn);
    this.itemCount.setValue(this.itemCount.getValue() + 1);
    console.log('Item added. Total items in cart: ' + this.itemCount.getValue());
    SynEnd(this.syn);
  }

  public removeItem(): void {
    SynStart(this.syn);
    if (this.itemCount.getValue() > 0) {
      this.itemCount.setValue(this.itemCount.getValue() - 1);
      console.log('Item removed. Total items in cart: ' + this.itemCount.getValue());
    } else {
      console.log('No items to remove.');
    }
    SynEnd(this.syn);
  }

  public displayCart(): void {
    SynStart(this.syn);
    console.log('Shopping Cart contains ' + this.itemCount.getValue() + ' items.');
    SynEnd(this.syn);
  }
}

class Shopper implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Shopper';

  private cart: ShoppingCart;
  private addOperations = new SharedNumber();
  private removeOperations = new SharedNumber();

  constructor(cart: ShoppingCart, addOperations: number, removeOperations: number) {
    this.cart = cart;
    this.addOperations.setValue(addOperations);
    this.removeOperations.setValue(removeOperations);
  }

  run(): void {
    for (let i = 0; i < this.addOperations.getValue(); i++) {
      this.cart.addItem();
    }
    for (let i = 0; i < this.removeOperations.getValue(); i++) {
      this.cart.removeItem();
    }
  }
}

class ShoppingCartSystem {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'ShoppingCartSystem';

  static main(args: string[]): void {
    const cart = new ShoppingCart();
    const shopper1 = new Thread(new Shopper(cart, 5, 3));
    const shopper2 = new Thread(new Shopper(cart, 3, 2));
    shopper1.start();
    shopper2.start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}