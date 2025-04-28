/*
 * Let P, Q, R share a buffer, 
 * P and Q form a pair of producer-consumer models, 
 * R is both producer and consumer, 
 * can write if the buffer is empty, 
 * can read if the buffer is not empty. 
 * Implement synchronization.
 */

public class PQR {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread p = new Thread(new P(semaphores));
        Thread q = new Thread(new Q(semaphores));
        Thread r = new Thread(new R(semaphores));
        p.start();
        q.start();
        r.start();
    }
}

class Semaphores {
    public boolean full = false;
    public boolean empty = true;
    public boolean mutex = true;

    public synchronized boolean pFull() {
        if (full) {
            full = false;
            return true;
        }
        return false;
    }

    public synchronized boolean pEmpty() {
        if (empty) {
            empty = false;
            return true;
        }
        return false;
    }

    public synchronized boolean pMutex() {
        if (mutex) {
            mutex = false;
            return true;
        }
        return false;
    }

    public synchronized void vFull() {
        full = true;
    }

    public synchronized void vEmpty() {
        empty = true;
    }

    public synchronized void vMutex() {
        mutex = true;
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
            System.out.println("P produces one.");
            semaphores.vMutex();
            semaphores.vFull();
        }
    }
}

class Q implements Runnable {
    public Semaphores semaphores;

    public Q(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.pFull()) {
            }
            while (!semaphores.pMutex()) {
            }
            System.out.println("Q consumes one.");
            semaphores.vMutex();
            semaphores.vEmpty();
        }
    }
}

class R implements Runnable {
    public Semaphores semaphores;

    public R(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            if (semaphores.empty) {
                while (!semaphores.pEmpty()) {
                }
                while (!semaphores.pMutex()) {
                }
                System.out.println("R produces one.");
                semaphores.vMutex();
                semaphores.vFull();
            }
            if (semaphores.full) {
                while (!semaphores.pFull()) {
                }
                while (!semaphores.pMutex()) {
                }
                System.out.println("R consumes one.");
                semaphores.vMutex();
                semaphores.vEmpty();
            }
        }
    }
}