/*
 * There are three processes P, P1, and P2 that cooperate to process the data, 
 * and P reads the data from the input device into the buffer, 
 * which can store 1000 words. 
 * The function of P1 and P2 is the same, 
 * both take the data from the buffer and calculate it, and then print the result. 
 * Synchronize three processes.
 */

public class ReadCompute {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread p = new Thread(new P(semaphores));
        Thread p1 = new Thread(new P1(semaphores));
        Thread p2 = new Thread(new P2(semaphores));
        p.start();
        p1.start();
        p2.start();
    }
}

class Semaphores {
    public boolean mutex = true;
    public int full = 0;
    public int empty = 50;

    public synchronized boolean pMutex() {
        if (mutex) {
            mutex = false;
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

    public synchronized boolean pEmpty() {
        if (empty > 0) {
            empty--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void vMutex() {
        mutex = true;
    }

    public synchronized void vFull() {
        full++;
    }

    public synchronized void vEmpty() {
        empty++;
    }
}

class P implements Runnable {
    public Semaphores semaphores;

    public P(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.pEmpty()) {
            }
            while (!semaphores.pMutex()) {
            }
            System.out.println("P reads data from device into the buffer.");
            semaphores.vMutex();
            semaphores.vFull();
        }
    }
}

class P1 implements Runnable {
    public Semaphores semaphores;

    public P1(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.pFull()) {
            }
            System.out.println("P1 gets one data from the buffer.");
            while (!semaphores.pFull()) {
            }
            System.out.println("P1 gets one data from the buffer.");
            System.out.println("P1 computes the datas.");
            semaphores.vEmpty();
            System.out.println("P1 prints the result.");
            semaphores.vEmpty();
            System.out.println("P1 prints the result.");
        }
    }
}

class P2 implements Runnable {
    public Semaphores semaphores;

    public P2(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.pFull()) {
            }
            System.out.println("P2 gets one data from the buffer.");
            while (!semaphores.pFull()) {
            }
            System.out.println("P2 gets one data from the buffer.");
            System.out.println("P2 computes the datas.");
            semaphores.vEmpty();
            System.out.println("P2 prints the result.");
            semaphores.vEmpty();
            System.out.println("P2 prints the result.");
        }
    }
}