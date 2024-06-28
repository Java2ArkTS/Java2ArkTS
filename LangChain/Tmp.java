class MoneyCounter {
    private int moneyAvailable = 2000;

    public synchronized void useMoney(String userName, int numberOfMoney) {
        if (numberOfMoney <= moneyAvailable) {
            moneyAvailable -= numberOfMoney;
            System.out.println(userName + " used " + numberOfMoney + " money. Money left: " + moneyAvailable);
        }
    }

    public synchronized int getMoneyAvailable() {
        return moneyAvailable;
    }
}

class BuyBook implements Runnable {
    private MoneyCounter moneyCounter;
    private String userName;
    private int price;

    public BuyBook(MoneyCounter moneyCounter, String userName, int price) {
        this.moneyCounter = moneyCounter;
        this.userName = userName;
        this.price = price;
    }

    @Override
    public void run() {
        while(true) {
            moneyCounter.useMoney(userName, price);
        }
    }
}

class BuyFood implements Runnable {
    private MoneyCounter moneyCounter;
    private String userName;
    private int price;

    public BuyFood(MoneyCounter moneyCounter, String userName, int price) {
        this.moneyCounter = moneyCounter;
        this.userName = userName;
        this.price = price;
    }

    @Override
    public void run() {
        while(true) {
            moneyCounter.useMoney(userName, price);
        }
    }
}

class BuyTicket implements Runnable {
    private MoneyCounter moneyCounter;
    private String userName;
    private int price;

    public BuyTicket(MoneyCounter moneyCounter, String userName, int price) {
        this.moneyCounter = moneyCounter;
        this.userName = userName;
        this.price = price;
    }

    @Override
    public void run() {
        while(true) {
            moneyCounter.useMoney(userName, price);
        }
    }
}

public class UseMoneyTest {
    public static void main(String[] args) {
        MoneyCounter moneyCounter = new MoneyCounter();

        Thread thread1 = new Thread(new BuyBook(moneyCounter, "User1", 5));
        Thread thread2 = new Thread(new BuyFood(moneyCounter, "User2", 10));
        Thread thread3 = new Thread(new BuyTicket(moneyCounter, "User3", 20));

        thread1.start();
        thread2.start();
        thread3.start();
    }
}