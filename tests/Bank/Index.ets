import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "BankTransaction") {
    archetype = new BankTransaction(new BankAccount(0), false, 0, "");
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class BankAccount {

  private balance = new SharedNumber(0);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "BankAccount";

  constructor(initialBalance: number) {
    this.balance.setValue(initialBalance);
  }

  public deposit(amount: number, threadName: string): void {
    {
      SynStart(this.syn);
      this.balance.setValue(this.balance.getValue() + amount);
      console.log(`${threadName} deposited ${amount}. Current balance: ${this.balance.getValue()}`);
      SynEnd(this.syn);
    }
  }

  public withdraw(amount: number, threadName: string): void {
    {
      SynStart(this.syn);
      while (this.balance.getValue() < amount) {
        console.log(`${threadName} is waiting to withdraw ${amount}. Current balance: ${this.balance.getValue()}`);
      }
      this.balance.setValue(this.balance.getValue() - amount);
      console.log(`${threadName} withdrew ${amount}. Current balance: ${this.balance.getValue()}`);
      SynEnd(this.syn);
    }
  }

  public getBalance(): number {
    return this.balance.getValue();
  }
}

class BankTransaction implements Runnable {

  private readonly account: BankAccount;

  private readonly deposit = new SharedBoolean(false);

  private readonly amount = new SharedNumber(0);

  private readonly threadName = new SharedString("");

  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "BankTransaction";

  constructor(account: BankAccount, deposit: boolean, amount: number, threadName: string) {
    this.account = account;
    this.deposit.setValue(deposit);
    this.amount.setValue(amount);
    this.threadName.setValue(threadName);
  }

  run(): void {
    if (this.deposit.getValue()) {
      this.account.deposit(this.amount.getValue(), this.threadName.getValue());
    } else {
      this.account.withdraw(this.amount.getValue(), this.threadName.getValue());
    }
  }
}

class Bank {

  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Bank";

  public static main(args: string[]): void {
    const account = new BankAccount(100);
    const transactions: Thread[] = new Array(6);
    transactions[0] = new Thread(new BankTransaction(account, false, 50, "Transaction 1"));
    transactions[1] = new Thread(new BankTransaction(account, true, 100, "Transaction 2"));
    transactions[2] = new Thread(new BankTransaction(account, false, 150, "Transaction 3"));
    transactions[3] = new Thread(new BankTransaction(account, true, 50, "Transaction 4"));
    transactions[4] = new Thread(new BankTransaction(account, false, 100, "Transaction 5"));
    transactions[5] = new Thread(new BankTransaction(account, true, 200, "Transaction 6"));
    for (const transaction of transactions) {
      transaction.start();
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}