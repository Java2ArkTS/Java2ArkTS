public class ReadWrite {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread thread0 = new Thread(new Reader(semaphores, 0));
        Thread thread1 = new Thread(new Reader(semaphores, 1));
        Thread thread2 = new Thread(new Reader(semaphores, 2));
        Thread thread3 = new Thread(new Writer(semaphores, 3));
        Thread thread4 = new Thread(new Writer(semaphores, 4));
        thread0.start();
        thread1.start();
        thread2.start();
        thread3.start();
        thread4.start();        
    }
}

class Semaphores {
    public int count;
    public boolean rw;
    public boolean w;
    public boolean mutex;
    public Semaphores() {
        this.count = 0;
        this.rw = true;
        this.w = true;
        this.mutex = true;
    }
    public synchronized boolean Pw() {
        if (w) {
            w = false;
            return true;
        } else {
            return false;
        }
    }
    public synchronized boolean Pmutex() {
        if (mutex) {
            mutex = false;
            return true;
        } else {
            return false;
        }
    }
    public synchronized boolean Prw() {
        if (rw) {
            rw = false;
            return true;
        } else {
            return false;
        }
    }
    public synchronized void Vmutex() {
        mutex = true;
    }
    public synchronized void Vw() {
        w = true;
    }
    public synchronized void Vrw() {
        rw = true;
    }
}

class Reader implements Runnable {
    public Semaphores semaphores;
    public int rank;
    public Reader(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }
    public void run() {
        while (true) {
            while (!semaphores.Pw()) {}
            while (!semaphores.Pmutex()) {}
            if (semaphores.count == 0) {
                while (!semaphores.Prw()) {}
            }
            semaphores.count++;
            semaphores.Vmutex();
            semaphores.Vw();
            System.out.println("Thread " + rank + " is reading.");
            while (!semaphores.Pmutex()) {}
            semaphores.count--;
            if (semaphores.count == 0) {
                semaphores.Vrw();
            }
            semaphores.Vmutex();
        }
    }
}

class Writer implements Runnable {
    public Semaphores semaphores;
    public int rank;
    public Writer(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }
    public void run() {
        while (true) {
            while (!semaphores.Pw()) {}
            while (!semaphores.Prw()) {}
            System.out.println("Thread " + rank + " is writing.");
            semaphores.Vrw();
            semaphores.Vw();
        }
    }
}