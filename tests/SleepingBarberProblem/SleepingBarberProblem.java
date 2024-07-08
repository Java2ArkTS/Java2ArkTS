public class SleepingBarberProblem {

    public static void main(String[] args) {
        BarberShop barberShop = new BarberShop(3); // 设置理发椅的数量

        // 创建理发师线程
        Thread barberThread = new Thread(new Barber(barberShop), "Barber");
        barberThread.start();

        // 创建顾客线程
        for (int i = 1; i <= 10; i++) {
            Thread customerThread = new Thread(new Customer(barberShop, i), "Customer " + i);
            customerThread.start();
        }
    }

    // 理发店类
    static class BarberShop {
        private final int chairs; // 理发椅数量
        private boolean sleeping; // 是否理发师正在睡觉
        private boolean cutting; // 是否理发师正在理发
        private int waiting; // 等待的顾客数量

        BarberShop(int chairs) {
            this.chairs = chairs;
            this.sleeping = true;
            this.cutting = false;
            this.waiting = 0;
        }

        // 顾客到来
        synchronized void customerArrived(int customerId) throws InterruptedException {
            while (waiting == chairs || cutting) {
                System.out.println("No free chairs or barber is busy, customer " + customerId + " leaves.");
                wait(); // 等待空椅子和理发师空闲
            }
            waiting++;
            System.out.println("Customer " + customerId + " sits in the waiting room.");
            if (sleeping) {
                System.out.println("Barber wakes up.");
                sleeping = false;
            }
            waiting--;
            System.out.println("Customer " + customerId + " is having a haircut.");
        }

        // 理发师开始理发
        synchronized void startCutting() {
            cutting = true;
            System.out.println("Barber starts cutting hair.");
        }

        // 理发师结束理发
        synchronized void finishCutting() {
            cutting = false;
            System.out.println("Barber finishes cutting hair.");
            notifyAll(); // 唤醒等待的顾客和理发师
        }

        // 理发师睡觉
        synchronized void sleep() throws InterruptedException {
            System.out.println("Barber goes to sleep.");
            sleeping = true;
            while (waiting == 0) {
                wait(); // 等待顾客到来唤醒
            }
            System.out.println("Barber wakes up.");
            sleeping = false;
        }
    }

    // 顾客类
    static class Customer implements Runnable {
        private final BarberShop barberShop;
        private final int customerId;

        Customer(BarberShop barberShop, int customerId) {
            this.barberShop = barberShop;
            this.customerId = customerId;
        }

        @Override
        public void run() {
            try {
                barberShop.customerArrived(customerId); // 顾客到来
                barberShop.startCutting(); // 理发
                Thread.sleep(2000); // 模拟理发时间
                barberShop.finishCutting(); // 理发完成
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    // 理发师类
    static class Barber implements Runnable {
        private final BarberShop barberShop;

        Barber(BarberShop barberShop) {
            this.barberShop = barberShop;
        }

        @Override
        public void run() {
            try {
                while (true) {
                    barberShop.sleep(); // 理发师睡觉
                    barberShop.startCutting(); // 开始理发
                    Thread.sleep(2000); // 模拟理发时间
                    barberShop.finishCutting(); // 理发完成
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
