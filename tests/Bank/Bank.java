class BankAccount {
    private int balance;

    public BankAccount(int initialBalance) {
        this.balance = initialBalance;
    }

    public synchronized void deposit(int amount, String threadName) {
        balance += amount;
        System.out.println(threadName + " deposited " + amount + ". Current balance: " + balance);
    }

    public synchronized void withdraw(int amount, String threadName) {
        while (balance < amount) {
            System.out.println(threadName + " is waiting to withdraw " + amount + ". Current balance: " + balance);

        }
        balance -= amount;
        System.out.println(threadName + " withdrew " + amount + ". Current balance: " + balance);

    }

    public int getBalance() {
        return balance;
    }
}

class BankTransaction implements Runnable {
    private final BankAccount account;
    private final boolean deposit;
    private final int amount;
    private final String threadName;

    public BankTransaction(BankAccount account, boolean deposit, int amount, String threadName) {
        this.account = account;
        this.deposit = deposit;
        this.amount = amount;
        this.threadName = threadName;
    }

    @Override
    public void run() {
        if (deposit) {
            account.deposit(amount, threadName);
        } else {
            account.withdraw(amount, threadName);
        }
    }
}

public class Bank {
    public static void main(String[] args) {
        BankAccount account = new BankAccount(100); // Initial balance of 100
        Thread[] transactions = new Thread[6];

        transactions[0] = new Thread(new BankTransaction(account, false, 50, "Transaction 1")); // Withdraw 50
        transactions[1] = new Thread(new BankTransaction(account, true, 100, "Transaction 2")); // Deposit 100
        transactions[2] = new Thread(new BankTransaction(account, false, 150, "Transaction 3")); // Withdraw 150
        transactions[3] = new Thread(new BankTransaction(account, true, 50, "Transaction 4")); // Deposit 50
        transactions[4] = new Thread(new BankTransaction(account, false, 100, "Transaction 5")); // Withdraw 100
        transactions[5] = new Thread(new BankTransaction(account, true, 200, "Transaction 6")); // Deposit 200

        for (Thread transaction : transactions) {
            transaction.start();
        }
    }
}
