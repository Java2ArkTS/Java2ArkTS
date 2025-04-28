import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class BankAccount {

    private balance: any = getClass('number');
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(initialBalance: number) {
        setValues(this.balance, initialBalance);
    }

    public deposit(amount: number, threadName: string) {
        SynStart(this['synArray']);
        setValues(this.balance, getValues(this.balance) + amount);
        console.log(`${threadName} deposited ${amount}. Current balance: ${getValues(this.balance)}`);
        SynEnd(this['synArray']);
    }

    public withdraw(amount: number, threadName: string) {
        SynStart(this['synArray']);
        while (getValues(this.balance) < amount) {
            console.log(`${threadName} is waiting to withdraw ${amount}. Current balance: ${getValues(this.balance)}`);
        }
        setValues(this.balance, getValues(this.balance) - amount);
        console.log(`${threadName} withdrew ${amount}. Current balance: ${getValues(this.balance)}`);
        SynEnd(this['synArray']);
    }

    public getBalance(): number {
        return getValues(this.balance);
    }
}

class BankTransaction implements Runnable {
    
    private account: any = getClass('BankAccount', new BankAccount());
    
    private deposit: any = getClass('boolean', false);
    
    private amount: any = getClass('number', 0);
    
    private threadName: any = getClass('string', '');
    
    public synArray : any = getSyc();
    
    public sharedType: string = "object";
    
    constructor(account: BankAccount, deposit: boolean, amount: number, threadName: string) {
        setValues(this.account, account);
        setValues(this.deposit, deposit);
        setValues(this.amount, amount);
        setValues(this.threadName, threadName);
    }
    
    run(): void {
        if (getValues(this.deposit)) {
            getValues(this.account.deposit(getValues(this.amount), getValues(this.threadName)));
        } else {
            getValues(this.account.withdraw(getValues(this.amount), getValues(this.threadName)));
        }
    }
}

class Bank {

    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const account = new BankAccount(100);
        const transactions: Thread[] = new Array(6);
        transactions[0] = new Thread(new BankTransaction(getValues(account), false, 50, "Transaction 1"));
        transactions[1] = new Thread(new BankTransaction(getValues(account), true, 100, "Transaction 2"));
        transactions[2] = new Thread(new BankTransaction(getValues(account), false, 150, "Transaction 3"));
        transactions[3] = new Thread(new BankTransaction(getValues(account), true, 50, "Transaction 4"));
        transactions[4] = new Thread(new BankTransaction(getValues(account), false, 100, "Transaction 5"));
        transactions[5] = new Thread(new BankTransaction(getValues(account), true, 200, "Transaction 6"));
        for (const transaction of transactions) {
            getValues(transaction.start());
        }
    }
}