class CoffeeShop {
    private int availableSeats = 5; // 咖啡店有5个座位
    private int customersServed = 0; // 已服务的顾客数

    // 同步方法，为顾客提供服务
    public synchronized void serveCustomer() {
        if (availableSeats > 0) {
            availableSeats--; // 减少可用座位数
            customersServed++; // 增加已服务的顾客数
            System.out.println("Customer served. Seats available: " + availableSeats + ". Total customers served: " + customersServed);
            for(int i=0;i<100000;i++);
            availableSeats++; // 服务完成后增加座位数
        } else {
            System.out.println("No seats available. Customer has to wait.");
        }
    }
}

class Waiter implements Runnable {
    private CoffeeShop coffeeShop;

    public Waiter(CoffeeShop coffeeShop) {
        this.coffeeShop = coffeeShop;
    }

    @Override
    public void run() {
        for (int i = 0; i < 10; i++) {
            coffeeShop.serveCustomer();
        }
    }
}

public class CoffeeShopExample {
    public static void main(String[] args) {
        CoffeeShop coffeeShop = new CoffeeShop();

        // 创建多个服务员线程
        Thread waiter1 = new Thread(new Waiter(coffeeShop));
        Thread waiter2 = new Thread(new Waiter(coffeeShop));

        waiter1.start();
        waiter2.start();
    }
}