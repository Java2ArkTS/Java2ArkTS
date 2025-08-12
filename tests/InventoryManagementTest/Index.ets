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
  if (runnable.className === 'AddStockTask') {
    archetype = new AddStockTask(new Inventory(0), 0);
  } else if (runnable.className === 'RemoveStockTask') {
    archetype = new RemoveStockTask(new Inventory(0), 0);
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class Inventory {
  private stock = new SharedNumber();
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Inventory';

  constructor(initialStock: number) {
    this.stock.setValue(initialStock);
  }

  public addStock(amount: number): void {
    {
      SynStart(this.syn);
      this.stock.setValue(this.stock.getValue() + amount);
      console.log(
        ` added ${amount} units. Current stock: ${this.stock.getValue()}`
      );
      SynEnd(this.syn);
    }
  }

  public removeStock(amount: number): void {
    {
      SynStart(this.syn);
      if (amount <= this.stock.getValue()) {
        this.stock.setValue(this.stock.getValue() - amount);
        console.log(
          ` removed ${amount} units. Current stock: ${this.stock.getValue()}`
        );
      } else {
        console.log(
          ` tried to remove ${amount} units, but only ${this.stock.getValue()} units available.`
        );
      }
      SynEnd(this.syn);
    }
  }

  public getStock(): number {
    {
      SynStart(this.syn);
      const currentStock = this.stock.getValue();
      SynEnd(this.syn);
      return currentStock;
    }
  }
}

class AddStockTask implements Runnable {
  private inventory: Inventory;

  private amount = new SharedNumber();

  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'AddStockTask';

  constructor(inventory: Inventory, amount: number) {
    this.inventory = inventory;
    this.amount.setValue(amount);
  }

  run(): void {
    this.inventory.addStock(this.amount.getValue());
  }
}

class RemoveStockTask implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'RemoveStockTask';

  private inventory: Inventory;

  private amount = new SharedNumber();

  constructor(inventory: Inventory, amount: number) {
    this.inventory = inventory;
    this.amount.setValue(amount);
  }

  run(): void {
    this.inventory.removeStock(this.amount.getValue());
  }
}

class InventoryManagementTest {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'InventoryManagementTest';

  public static main(args: string[]): void {
    const inventory = new Inventory(100);
    const thread1 = new Thread(new AddStockTask(inventory, 30));
    const thread2 = new Thread(new RemoveStockTask(inventory, 50));
    const thread3 = new Thread(new AddStockTask(inventory, 20));
    const thread4 = new Thread(new RemoveStockTask(inventory, 70));
    thread1.start();
    thread2.start();
    thread3.start();
    thread4.start();
  }
}

if (isMainThread()) {
  InventoryManagementTest.main([]);
}