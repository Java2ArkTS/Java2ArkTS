/*
 * A museum can accommodate up to 500 people at a time and has one entrance, 
 * which only allows one person to pass through at a time. 
 * Synchronization between visitors.
 */

public class Exit {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread visitor1 = new Thread(new Visitor(semaphores, 1));
        Thread visitor2 = new Thread(new Visitor(semaphores, 2));
        Thread visitor3 = new Thread(new Visitor(semaphores, 3));
        Thread visitor4 = new Thread(new Visitor(semaphores, 4));
        Thread visitor5 = new Thread(new Visitor(semaphores, 5));
        visitor1.start();
        visitor2.start();
        visitor3.start();
        visitor4.start();
        visitor5.start();
    }
}

class Semaphores {
    public int empty = 500;
    public boolean mutex = true;

    public synchronized boolean pEmpty() {
        if (empty > 0) {
            empty--;
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

    public synchronized void vEmpty() {
        empty++;
    }

    public synchronized void vMutex() {
        mutex = true;
    }
}

class Visitor implements Runnable {
    public Semaphores semaphores;
    public int rank;

    public Visitor(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }

    public void run() {
        while (!semaphores.pEmpty()) {
        }
        while (!semaphores.pMutex()) {
        }
        System.out.println("Visitor " + rank + " enters the museum.");
        semaphores.vMutex();
        System.out.println("Visitor " + rank + " visits the museum.");
        while (!semaphores.pMutex()) {
        }
        System.out.println("Visitor " + rank + " leaves the museum.");
        semaphores.vMutex();
        semaphores.vEmpty();
    }
}