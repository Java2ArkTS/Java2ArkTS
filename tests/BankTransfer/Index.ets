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

  if (runnable.className === 'TransferTask') {
    archetype = new TransferTask(new BankAccount(0), new BankAccount(0), 0);
  } else {
    archetype = new Thread();
  }

  addFunc(runnable, archetype);
  runnable.run();
}

class BankAccount {
  private balance = new SharedNumber();
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'BankAccount';

  constructor(balance: number) {
    this.balance.setValue(balance);
  }

  public deposit(amount: number): void {
    SynStart(this.syn);
    this.balance.setValue(this.balance.getValue() + amount);
    console.log(` deposited ${amount}, new balance: ${this.balance.getValue()}`);
    SynEnd(this.syn);
  }

  public withdraw(amount: number): void {
    SynStart(this.syn);
    if (amount <= this.balance.getValue()) {
      this.balance.setValue(this.balance.getValue() - amount);
      console.log(` withdrew ${amount}, new balance: ${this.balance.getValue()}`);
    } else {
      console.log(` attempted to withdraw ${amount}, but insufficient balance.`);
    }
    SynEnd(this.syn);
  }

  public getBalance(): number {
    return this.balance.getValue();
  }
}

class TransferTask implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'TransferTask';

  private fromAccount: BankAccount = new BankAccount(0);
  private toAccount: BankAccount;
  private amount = new SharedNumber();

  constructor(fromAccount: BankAccount, toAccount: BankAccount, amount: number) {
    this.fromAccount = fromAccount;
    this.toAccount = toAccount;
    this.amount.setValue(amount);
  }

  run(): void {
    SynStart(this.syn);
    SynStart(this.fromAccount.syn);
    SynStart(this.toAccount.syn);
    if (this.fromAccount.getBalance() >= this.amount.getValue()) {
      this.fromAccount.withdraw(this.amount.getValue());
      this.toAccount.deposit(this.amount.getValue());
      console.log(
        ` transferred ${this.amount.getValue()} from Account ${this.fromAccount} to Account ${this.toAccount}`
      );
    } else {
      console.log(
        ` failed to transfer ${this.amount.getValue()} due to insufficient balance.`
      );
    }
    SynEnd(this.toAccount.syn);
    SynEnd(this.fromAccount.syn);
    SynEnd(this.syn);
  }
}

class BankTransfer {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'BankTransfer';

  public static main(args: string[]): void {
    const account1 = new BankAccount(1000);
    const account2 = new BankAccount(1000);
    const thread1 = new Thread(new TransferTask(account1, account2, 300));
    const thread2 = new Thread(new TransferTask(account2, account1, 500));
    thread1.start();
    thread2.start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}