/*
 * The baker has a lot of bread, which is sold by n sales people. 
 * Each customer enters the store in order to take a number, 
 * and waits for the number to be called, 
 * and when a salesperson is free, the next number is called in order. 
 * Using two integer variables to record the current sign value and call value, 
 * design an algorithm to synchronize sales and customers.
 */

public class Bread {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread thread_consumer_1 = new Thread(new Consumer(semaphores, 1));
        Thread thread_consumer_2 = new Thread(new Consumer(semaphores, 2));
        Thread thread_seller_1 = new Thread(new Seller(semaphores, 1));
        Thread thread_seller_2 = new Thread(new Seller(semaphores, 2));
        thread_consumer_1.start();
        thread_consumer_2.start();
        thread_seller_1.start();
        thread_seller_2.start();
    }
}

class Semaphores {
    public int i = 0;
    public int j = 0;
    public boolean mutex_i = true;
    public boolean mutex_j = true;

    public synchronized boolean P_mutex_i() {
        if (mutex_i) {
            mutex_i = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_mutex_j() {
        if (mutex_j) {
            mutex_j = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void V_mutex_i() {
        mutex_i = true;
    }

    public synchronized void V_mutex_j() {
        mutex_j = true;
    }
}

class Consumer implements Runnable {
    public Semaphores semaphores;
    public int rank;

    public Consumer(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }

    public void run() {
        while (true) {
            System.out.println("Consumer " + rank + " enter the bakery.");
            while (!semaphores.P_mutex_i()) {
            }
            System.out.println("Consumer " + rank + " get the number " + semaphores.i + ".");
            semaphores.i++;
            semaphores.V_mutex_i();
            System.out.println("Consumer " + rank + " is waiting for buying bread.");
        }
    }
}

class Seller implements Runnable {
    public Semaphores semaphores;
    public int rank;

    public Seller(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }

    public void run() {
        while (true) {
            while (!semaphores.P_mutex_j()) {
            }
            if (semaphores.j < semaphores.i) {
                System.out.println("Seller " + rank + " calls number " + semaphores.j + ".");
                semaphores.j++;
                semaphores.V_mutex_j();
            } else {
                semaphores.V_mutex_j();
                System.out.println("Seller " + rank + " is free.");
            }
        }
    }
}
