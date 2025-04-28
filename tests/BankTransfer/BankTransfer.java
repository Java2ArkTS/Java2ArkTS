class BankAccount {
    private int balance;

    public BankAccount(int balance) {
        this.balance = balance;
    }

    public synchronized void deposit(int amount) {
        balance += amount;
        System.out.println(" deposited " + amount + ", new balance: " + balance);
    }

    public synchronized void withdraw(int amount) {
        if (amount <= balance) {
            balance -= amount;
            System.out.println(" withdrew " + amount + ", new balance: " + balance);
        } else {
            System.out.println(" attempted to withdraw " + amount + ", but insufficient balance.");
        }
    }

    public int getBalance() {
        return balance;
    }
}

class TransferTask implements Runnable {
    private BankAccount fromAccount = new BankAccount(0);
    private BankAccount toAccount;
    private int amount;

    public TransferTask(BankAccount fromAccount, BankAccount toAccount, int amount) {
        this.fromAccount = fromAccount;
        this.toAccount = toAccount;
        this.amount = amount;
    }

    @Override
    public void run() {
        synchronized (fromAccount) {
            synchronized (toAccount) {
                if (fromAccount.getBalance() >= amount) {
                    fromAccount.withdraw(amount);
                    toAccount.deposit(amount);
                    System.out.println(" transferred " + amount + " from Account " + fromAccount + " to Account " + toAccount);
                } else {
                    System.out.println(" failed to transfer " + amount + " due to insufficient balance.");
                }
            }
        }
    }
}

public class BankTransfer {
    public static void main(String[] args) {
        BankAccount account1 = new BankAccount(1000);
        BankAccount account2 = new BankAccount(1000);

        Thread thread1 = new Thread(new TransferTask(account1, account2, 300));
        Thread thread2 = new Thread(new TransferTask(account2, account1, 500));

        thread1.start();
        thread2.start();
    }
}