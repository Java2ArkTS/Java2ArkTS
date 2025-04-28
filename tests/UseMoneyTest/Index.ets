import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class MoneyCounter {
  private moneyAvailable: any = getClass('number', 2000);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public useMoney(userName: string, numberOfMoney: number): void {
    SynStart(this['synArray']);
    if (numberOfMoney <= getValues(this.moneyAvailable)) {
      setValues(this.moneyAvailable, getValues(this.moneyAvailable) - numberOfMoney);
      console.log(`${userName} used ${numberOfMoney} money. Money left: ${getValues(this.moneyAvailable)}`);
    }
    SynEnd(this['synArray']);
  }

  public getMoneyAvailable(): number {
    SynStart(this['synArray']);
    const available = getValues(this.moneyAvailable);
    SynEnd(this['synArray']);
    return available;
  }
}

class BuyBook implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  private moneyCounter: any = getClass('MoneyCounter', new MoneyCounter());
  private userName: any = getClass('string', "User1");
  private price: any = getClass('number', 5);

  constructor(moneyCounter: MoneyCounter, userName: string, price: number) {
    setValues(this.moneyCounter, moneyCounter);
    setValues(this.userName, userName);
    setValues(this.price, price);
  }

  run(): void {
    while (true) {
      getValues(this.moneyCounter.useMoney(getValues(this.userName), getValues(this.price)));
    }
  }
}

class BuyFood implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  private moneyCounter: any = getClass('MoneyCounter', new MoneyCounter());
  private userName: any = getClass('string', "User2");
  private price: any = getClass('number', 10);

  constructor(moneyCounter: MoneyCounter, userName: string, price: number) {
    setValues(this.moneyCounter, moneyCounter);
    setValues(this.userName, userName);
    setValues(this.price, price);
  }

  run(): void {
    while (true) {
      getValues(this.moneyCounter.useMoney(getValues(this.userName), getValues(this.price)));
    }
  }
}

class BuyTicket implements Runnable {
  private moneyCounter: any = getClass('MoneyCounter', new MoneyCounter());
  private userName: any = getClass('string', "User3");
  private price: any = getClass('number', 20);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(moneyCounter: MoneyCounter, userName: string, price: number) {
    setValues(this.moneyCounter, moneyCounter);
    setValues(this.userName, userName);
    setValues(this.price, price);
  }

  run(): void {
    while (true) {
      getValues(this.moneyCounter.useMoney(getValues(this.userName), getValues(this.price)));
    }
  }
}

class UseMoneyTest {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const moneyCounter = new MoneyCounter();
    const thread1 = new Thread(new BuyBook(moneyCounter, "User1", 5));
    const thread2 = new Thread(new BuyFood(moneyCounter, "User2", 10));
    const thread3 = new Thread(new BuyTicket(moneyCounter, "User3", 20));
    getValues(thread1.start());
    getValues(thread2.start());
    getValues(thread3.start());
  }
}