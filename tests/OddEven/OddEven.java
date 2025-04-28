/*
 * The three processes P1, P2, and P3 are mutually exclusive using a buffer 
 * containing N units. 
 * P1 generates a positive integer each time 
 * and sends it to an empty unit in the buffer. 
 * P2 selects an odd number from the buffer each time 
 * and counts the number of odd numbers. 
 * P3 retrieves an even number from the buffer at a time 
 * and counts the number of even numbers. 
 * Synchronize three processes.
 */

public class OddEven {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread p1 = new Thread(new P1(semaphores));
        Thread p2 = new Thread(new P2(semaphores));
        Thread p3 = new Thread(new P3(semaphores));
        p1.start();
        p2.start();
        p3.start();
    }
}

class Semaphores {
    public boolean mutex = true;
    public int odd = 0;
    public int even = 0;
    public int empty = 5;
    public synchronized boolean pMutex() {
        if (mutex) {
            mutex = false;
            return true;
        } else {
            return false;
        }
    }
    public synchronized boolean pOdd() {
        if (odd > 0) {
            odd--;
            return true;
        } else {
            return false;
        }
    }
    public synchronized boolean pEven() {
        if (even > 0) {
            even--;
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
    public synchronized void vOdd() {
        odd++;
    }
    public synchronized void vEven() {
        even++;
    }
    public synchronized void vEmpty() {
        empty++;
    }
}

class P1 implements Runnable {
    public Semaphores semaphores;
    public int x = 0;
    public P1(Semaphores semaphores) {
        this.semaphores = semaphores;
    }
    public void run() {
        while (true) {
            while (!semaphores.pEmpty()) {}
            while (!semaphores.pMutex()) {}
            System.out.println("P1 puts a number.");
            semaphores.vMutex();
            if (x++ % 2 == 0) {
                semaphores.vEven();
            } else {
                semaphores.vOdd();
            }
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
            while (!semaphores.pOdd()) {}
            while (!semaphores.pMutex()) {}
            System.out.println("P2 gets an odd number.");
            semaphores.vMutex();
            semaphores.vEmpty();
            System.out.println("P2 counts an odd number.");
        }
    }
}

class P3 implements Runnable {
    public Semaphores semaphores;
    public P3(Semaphores semaphores) {
        this.semaphores = semaphores;
    }
    public void run() {
        while (true) {
            while (!semaphores.pEven()) {}
            while (!semaphores.pMutex()) {}
            System.out.println("P3 gets an even number.");
            semaphores.vMutex();
            semaphores.vEmpty();
            System.out.println("P3 counts an even number.");
        }
    }
}