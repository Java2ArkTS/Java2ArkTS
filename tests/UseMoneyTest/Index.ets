import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "BuyBook") {
        archetype = new BuyBook(new MoneyCounter(), "User", 0);
    } else if (runnable.className == "BuyFood") {
        archetype = new BuyFood(new MoneyCounter(), "User", 0);
    } else if (runnable.className == "BuyTicket") {
        archetype = new BuyTicket(new MoneyCounter(), "User", 0);
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class MoneyCounter {
    private moneyAvailable = new SharedNumber(2000);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "MoneyCounter";

    public useMoney(userName: string, numberOfMoney: number): void {
        SynStart(this.syn);
        if (numberOfMoney <= this.moneyAvailable.getValue()) {
            this.moneyAvailable.setValue(this.moneyAvailable.getValue() - numberOfMoney);
            console.log(`${userName} used ${numberOfMoney} money. Money left: ${this.moneyAvailable.getValue()}`);
        }
        SynEnd(this.syn);
    }

    public getMoneyAvailable(): number {
        SynStart(this.syn);
        const available = this.moneyAvailable.getValue();
        SynEnd(this.syn);
        return available;
    }
}

class BuyBook implements Runnable {
    private moneyCounter: MoneyCounter;
    private userName = new SharedString("");
    private price = new SharedNumber(0);
    
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "BuyBook";

    constructor(moneyCounter: MoneyCounter, userName: string, price: number) {
        this.moneyCounter = moneyCounter;
        this.userName.setValue(userName);
        this.price.setValue(price);
    }

    run(): void {
        while (true) {
            this.moneyCounter.useMoney(this.userName.getValue(), this.price.getValue());
        }
    }
}

class BuyFood implements Runnable {
    private moneyCounter: MoneyCounter;
    private userName = new SharedString("");
    private price = new SharedNumber(0);
    
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "BuyFood";

    constructor(moneyCounter: MoneyCounter, userName: string, price: number) {
        this.moneyCounter = moneyCounter;
        this.userName.setValue(userName);
        this.price.setValue(price);
    }

    run(): void {
        while (true) {
            this.moneyCounter.useMoney(this.userName.getValue(), this.price.getValue());
        }
    }
}

class BuyTicket implements Runnable {
    private moneyCounter: MoneyCounter;
    private userName = new SharedString("");
    private price = new SharedNumber(0);
    
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "BuyTicket";

    constructor(moneyCounter: MoneyCounter, userName: string, price: number) {
        this.moneyCounter = moneyCounter;
        this.userName.setValue(userName);
        this.price.setValue(price);
    }

    run(): void {
        while (true) {
            this.moneyCounter.useMoney(this.userName.getValue(), this.price.getValue());
        }
    }
}

class UseMoneyTest {
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "UseMoneyTest";

    public static main(args: string[]): void {
        const moneyCounter = new MoneyCounter();
        const thread1 = new Thread(new BuyBook(moneyCounter, "User1", 5));
        const thread2 = new Thread(new BuyFood(moneyCounter, "User2", 10));
        const thread3 = new Thread(new BuyTicket(moneyCounter, "User3", 20));
        thread1.start();
        thread2.start();
        thread3.start();
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}