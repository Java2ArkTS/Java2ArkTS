public class QueuingMachine {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread server = new Thread(new Server(semaphores));
        Thread customer1 = new Thread(new Customer(semaphores, 1));
        Thread customer2 = new Thread(new Customer(semaphores, 2));
        Thread customer3 = new Thread(new Customer(semaphores, 3));
        Thread customer4 = new Thread(new Customer(semaphores, 4));
        server.start();
        customer1.start();
        customer2.start();
        customer3.start();
        customer4.start();
    }
}

class Semaphores {
    public int empty = 10;
    public boolean mutex = true;
    public int full = 0;
    public boolean service = false;

    public synchronized boolean pEmpty() {
        if (empty > 0) {
            empty--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean pFull() {
        if (full > 0) {
            full--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean pMutex() {
        if (mutex) {
            mutex = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean pService() {
        if (service) {
            service = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void vEmpty() {
        empty++;
    }

    public synchronized void vFull() {
        full++;
    }

    public synchronized void vMutex() {
        mutex = true;
    }

    public synchronized void vService() {
        service = true;
    }
}

class Customer implements Runnable {
    public Semaphores semaphores;
    public int rank;

    public Customer(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }

    public void run() {
        while (!semaphores.pEmpty()) {
        }
        while (!semaphores.pMutex()) {
        }
        System.out.println("Customer " + rank + " takes a number.");
        semaphores.vMutex();
        semaphores.vFull();
        while (!semaphores.pService()) {
        }
        System.out.println("Customer " + rank + " gets service.");
    }
}

class Server implements Runnable {
    public Semaphores semaphores;

    public Server(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.pFull()) {
            }
            semaphores.vEmpty();
            semaphores.vService();
            System.out.println("Server serves.");
        }
    }
}