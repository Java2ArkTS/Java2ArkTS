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
  if (runnable.className === 'BankTransaction') {
    archetype = new BankTransaction(
      new BankAccount(0), // Placeholder account
      false, // Placeholder deposit flag
      0, // Placeholder amount
      '' // Placeholder thread name
    );
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class BankAccount {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'BankAccount';

  private balance = new SharedNumber();

  constructor(initialBalance: number) {
    this.balance.setValue(initialBalance);
  }

  deposit(amount: number, threadName: string): void {
    {
      SynStart(this.syn);
      this.balance.setValue(this.balance.getValue() + amount);
      console.log(
        `${threadName} deposited ${amount}. Current balance: ${this.balance.getValue()}`
      );
      SynEnd(this.syn);
    }
  }

  withdraw(amount: number, threadName: string): void {
    {
      SynStart(this.syn);
      while (this.balance.getValue() < amount) {
        console.log(
          `${threadName} is waiting to withdraw ${amount}. Current balance: ${this.balance.getValue()}`
        );
        wait(this.syn);
      }
      this.balance.setValue(this.balance.getValue() - amount);
      console.log(
        `${threadName} withdrew ${amount}. Current balance: ${this.balance.getValue()}`
      );
      SynEnd(this.syn);
    }
  }

  getBalance(): number {
    return this.balance.getValue();
  }
}

class BankTransaction implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'BankTransaction';

  private readonly account: BankAccount;

  private readonly deposit = new SharedBoolean();

  private readonly amount = new SharedNumber();

  private readonly threadName = new SharedString();

  constructor(
    account: BankAccount,
    deposit: boolean,
    amount: number,
    threadName: string
  ) {
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
  public className: string = 'Bank';

  static main(args: string[]): void {
    const account = new BankAccount(100);
    const transactions: Thread[] = new Array(6);
    transactions[0] = new Thread(
      new BankTransaction(account, false, 50, 'Transaction 1')
    );
    transactions[1] = new Thread(
      new BankTransaction(account, true, 100, 'Transaction 2')
    );
    transactions[2] = new Thread(
      new BankTransaction(account, false, 150, 'Transaction 3')
    );
    transactions[3] = new Thread(
      new BankTransaction(account, true, 50, 'Transaction 4')
    );
    transactions[4] = new Thread(
      new BankTransaction(account, false, 100, 'Transaction 5')
    );
    transactions[5] = new Thread(
      new BankTransaction(account, true, 200, 'Transaction 6')
    );
    for (const transaction of transactions) {
      transaction.start();
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}