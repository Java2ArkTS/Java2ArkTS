import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "DepositTask") {
    archetype = new DepositTask(new BankAccount(), 0);
  } else if (runnable.className == "WithdrawTask") {
    archetype = new WithdrawTask(new BankAccount(), 0);
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

  public deposit(amount: number): void {
    SynStart(this.syn);
    this.balance.setValue(this.balance.getValue() + amount);
    console.log(` deposited: ${amount}, balance: ${this.balance.getValue()}`);
    SynEnd(this.syn);
  }

  public withdraw(amount: number): void {
    SynStart(this.syn);
    if (amount <= this.balance.getValue()) {
      this.balance.setValue(this.balance.getValue() - amount);
      console.log(` withdrew: ${amount}, balance: ${this.balance.getValue()}`);
    } else {
      console.log(` tried to withdraw: ${amount}, but insufficient balance.`);
    }
    SynEnd(this.syn);
  }

  public getBalance(): number {
    SynStart(this.syn);
    const currentBalance = this.balance.getValue();
    SynEnd(this.syn);
    return currentBalance;
  }
}

class DepositTask implements Runnable {
  private account: BankAccount;
  private amount = new SharedNumber(amount);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "DepositTask";

  constructor(account: BankAccount, amount: number) {
    this.account = account;
    this.amount.setValue(amount);
  }

  run(): void {
    for (let i = 0; i < 5; i++) {
      this.account.deposit(this.amount.getValue());
    }
  }
}

class WithdrawTask implements Runnable {
  private account: BankAccount;
  private amount = new SharedNumber(amount);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "WithdrawTask";

  constructor(account: BankAccount, amount: number) {
    this.account = account;
    this.amount.setValue(amount);
  }

  run(): void {
    for (let i = 0; i < 5; i++) {
      this.account.withdraw(this.amount.getValue());
    }
  }
}

class ExampleClass {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "ExampleClass";
  // Other methods and properties of the class
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}