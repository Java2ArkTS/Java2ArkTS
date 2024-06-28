import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class Inventory {

  public synArray: any = getSyc();
  public sharedType: string = "object";
  private stock: any = getClass('number', 0);

  constructor(initialStock: number) {
    setValues(this.stock, initialStock);
  }

  public addStock(amount: number): void {
    {
      SynStart(1, this.synArray);
      setValues(this.stock, getValues(this.stock) + amount);
      console.log(` added ${amount} units. Current stock: ${getValues(this.stock)}`);
      SynEnd(1, this.synArray);
    }
  }

  public removeStock(amount: number): void {
    {
      SynStart(2, this.synArray);
      if (amount <= getValues(this.stock)) {
        setValues(this.stock, getValues(this.stock) - amount);
        console.log(` removed ${amount} units. Current stock: ${getValues(this.stock)}`);
      } else {
        console.log(` tried to remove ${amount} units, but only ${getValues(this.stock)} units available.`);
      }
      SynEnd(2, this.synArray);
    }
  }

  public getStock(): number {
    {
      SynStart(3, this.synArray);
      const currentStock = getValues(this.stock);
      SynEnd(3, this.synArray);
      return currentStock;
    }
  }
}

class AddStockTask implements Runnable {

  public synArray: any = getSyc();
  public sharedType: string = "object";
  private inventory: any = getClass('Inventory', new Inventory(100));
  private amount: any = getClass('number', 0);

  constructor(inventory: Inventory, amount: number) {
    setValues(this.inventory, inventory);
    setValues(this.amount, amount);
  }

  run(): void {
    getValues(this.inventory.addStock(getValues(this.amount)));
  }
}

class RemoveStockTask implements Runnable {

  public synArray: any = getSyc();
  public sharedType: string = "object";
  private inventory: any = getClass('Inventory', new Inventory(100));
  private amount: any = getClass('number', 0);

  constructor(inventory: Inventory, amount: number) {
    setValues(this.inventory, inventory);
    setValues(this.amount, amount);
  }

  run(): void {
    getValues(this.inventory.removeStock(getValues(this.amount)));
  }
}

class InventoryManagementTest {

  public synArray : any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const inventory = new Inventory(100);
    const thread1 = new Thread(new AddStockTask(inventory, 30));
    const thread2 = new Thread(new RemoveStockTask(inventory, 50));
    const thread3 = new Thread(new AddStockTask(inventory, 20));
    const thread4 = new Thread(new RemoveStockTask(inventory, 70));
    getValues(thread1.start());
    getValues(thread2.start());
    getValues(thread3.start());
    getValues(thread4.start());
  }
}