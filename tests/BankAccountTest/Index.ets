import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class BankAccount {

  private balance: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public deposit(amount: number): void {
    SynStart(this['synArray']);
    setValues(this.balance, getValues(this.balance) + amount);
    console.log(" deposited: " + amount + ", balance: " + getValues(this.balance));
    SynEnd(this['synArray']);
  }

  public withdraw(amount: number): void {
    SynStart(this['synArray']);
    if (amount <= getValues(this.balance)) {
      setValues(this.balance, getValues(this.balance) - amount);
      console.log(" withdrew: " + amount + ", balance: " + getValues(this.balance));
    } else {
      console.log(" tried to withdraw: " + amount + ", but insufficient balance.");
    }
    SynEnd(this['synArray']);
  }

  public getBalance(): number {
    SynStart(this['synArray']);
    const currentBalance = getValues(this.balance);
    SynEnd(this['synArray']);
    return currentBalance;
  }
}

class DepositTask implements Runnable {

  private account: any = getClass('BankAccount', new BankAccount());
  private amount: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(account: BankAccount, amount: number) {
    setValues(this.account, account);
    setValues(this.amount, amount);
  }

  run(): void {
    for (let i = 0; i < 5; i++) {
      getValues(this.account.deposit(this.amount));
    }
  }
}

class WithdrawTask implements Runnable {

  private account: any = getClass('BankAccount', new BankAccount());
  private amount: any = getClass('number', 0);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(account: BankAccount, amount: number) {
    setValues(this.account, account);
    setValues(this.amount, amount);
  }

  run(): void {
    for (let i = 0; i < 5; i++) {
      getValues(this.account.withdraw(this.amount));
    }
  }
}

class BankAccountTest {

  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const account = new BankAccount();
    const depositTask = new DepositTask(account, 100);
    const withdrawTask = new WithdrawTask(account, 50);
    const depositThread = new Thread(depositTask);
    const withdrawThread = new Thread(withdrawTask);
    depositThread.start();
    withdrawThread.start();
  }
}