class BankAccount {
    private int balance = 0;

    public synchronized void deposit(int amount) {
        balance += amount;
        System.out.println(" deposited: " + amount + ", balance: " + balance);
    }

    public synchronized void withdraw(int amount) {
        if (amount <= balance) {
            balance -= amount;
            System.out.println(" withdrew: " + amount + ", balance: " + balance);
        } else {
            System.out.println(" tried to withdraw: " + amount + ", but insufficient balance.");
        }
    }

    public synchronized int getBalance() {
        return balance;
    }
}

class DepositTask implements Runnable {
    private BankAccount account;
    private int amount;

    public DepositTask(BankAccount account, int amount) {
        this.account = account;
        this.amount = amount;
    }

    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            account.deposit(amount);
        }
    }
}

class WithdrawTask implements Runnable {
    private BankAccount account;
    private int amount;

    public WithdrawTask(BankAccount account, int amount) {
        this.account = account;
        this.amount = amount;
    }

    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            account.withdraw(amount);
        }
    }
}

public class BankAccountTest {
    public static void main(String[] args) {
        BankAccount account = new BankAccount();
        Thread depositThread = new Thread(new DepositTask(account, 100));
        Thread withdrawThread = new Thread(new WithdrawTask(account, 50));

        depositThread.start();
        withdrawThread.start();
    }
}
