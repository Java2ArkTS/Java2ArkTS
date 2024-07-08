/*
 * There are multiple producer processes and multiple consumer processes in the system, 
 * sharing a ring buffer of 1000 products, which is initially empty. 
 * When the buffer is full, the producer process can put in one of its products, 
 * otherwise wait; 
 * When the buffer is not empty, the consumer process can remove a product from the buffer, 
 * otherwise wait.
 *  A consumer process is required to take 10 products from the buffer in a row 
 * before other consumer processes can take products. 
 * Implements synchronization between processes.
 */

public class CircleBuffer {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread producer1 = new Thread(new Producer(semaphores, 1));
        Thread producer2 = new Thread(new Producer(semaphores, 2));
        Thread consumer1 = new Thread(new Consumer(semaphores, 1));
        Thread consumer2 = new Thread(new Consumer(semaphores, 2));
        producer1.start();
        producer2.start();
        consumer1.start();
        consumer2.start();
    }
}

class Semaphores {
    public boolean mutex1 = true;
    public boolean mutex2 = true;
    public int empty = 1000;
    public int full = 0;

    public synchronized boolean pMutex1() {
        if (mutex1) {
            mutex1 = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean pMutex2() {
        if (mutex2) {
            mutex2 = false;
            return true;
        } else {
            return false;
        }
    }

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

    public synchronized void vMutex1() {
        mutex1 = true;
    }

    public synchronized void vMutex2() {
        mutex2 = true;
    }

    public synchronized void vEmpty() {
        empty++;
    }

    public synchronized void vFull() {
        full++;
    }
}

class Producer implements Runnable {
    public Semaphores semaphores;
    public int rank;

    public Producer(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }

    public void run() {
        while (true) {
            System.out.println("Producer " + rank + " produces a production.");
            while (!semaphores.pEmpty()) {
            }
            while (!semaphores.pMutex2()) {
            }
            System.out.println("Producer " + rank + " puts a production into the buffer.");
            semaphores.vMutex2();
            semaphores.vFull();
        }
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
            while (!semaphores.pMutex1()) {
            }
            for (int i = 1; i <= 10; i++) {
                while (!semaphores.pFull()) {
                }
                while (!semaphores.pMutex2()) {
                }
                System.out.println("Consumer " + rank + " gets the " + i + "st/nd/rd/th production from the buffer.");
                semaphores.vMutex2();
                semaphores.vEmpty();
                System.out.println("Consumer " + rank + " consumes the " + i + "st/nd/rd/th production.");
            }
            semaphores.vMutex1();
        }
    }
}