import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class BankAccount {
  private balance: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(balance: number) {
    setValues(this.balance, balance);
  }

  public deposit(amount: number): void {
    SynStart(this['synArray']);
    setValues(this.balance, getValues(this.balance) + amount);
    console.log(` deposited ${amount}, new balance: ${getValues(this.balance)}`);
    SynEnd(this['synArray']);
  }

  public withdraw(amount: number): void {
    SynStart(this['synArray']);
    if (amount <= getValues(this.balance)) {
      setValues(this.balance, getValues(this.balance) - amount);
      console.log(` withdrew ${amount}, new balance: ${getValues(this.balance)}`);
    } else {
      console.log(` attempted to withdraw ${amount}, but insufficient balance.`);
    }
    SynEnd(this['synArray']);
  }

  public getBalance(): number {
    return getValues(this.balance);
  }
}

class TransferTask implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  private fromAccount: any = getClass('BankAccount', new BankAccount(0));
  private toAccount: any = getClass('BankAccount', new BankAccount(0));
  private amount: any = getClass('number', 0);

  constructor(fromAccount: BankAccount, toAccount: BankAccount, amount: number) {
    setValues(this.fromAccount, fromAccount);
    setValues(this.toAccount, toAccount);
    setValues(this.amount, amount);
  }

  run(): void {
    SynStart(this['synArray']);
    SynStart(this['synArray']);
    if (getValues(this.fromAccount.getBalance()) >= getValues(this.amount)) {
      this.fromAccount.withdraw(getValues(this.amount));
      this.toAccount.deposit(getValues(this.amount));
      console.log(`transferred ${getValues(this.amount)} from Account ${this.fromAccount} to Account ${this.toAccount}`);
    } else {
      console.log(`failed to transfer ${getValues(this.amount)} due to insufficient balance.`);
    }
    SynEnd(this['synArray']);
    SynEnd(this['synArray']);
  }
}

class BankTransfer {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const account1 = new BankAccount(1000);
    const account2 = new BankAccount(1000);
    const thread1 = new Thread(new TransferTask(account1, account2, 300));
    const thread2 = new Thread(new TransferTask(account2, account1, 500));
    thread1.start();
    thread2.start();
  }
}