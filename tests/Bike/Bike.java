/*
 * There is a box in the bicycle production line, 
 * which has five positions, each of which can store a frame or a wheel. 
 * There are three workers, 
 * the workers who produce the wheels, 
 * the workers who produce the frames, 
 * and the workers who assemble the bicycles. 
 * Enables three workers to cooperate without deadlock.
 */

public class Bike {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread worker1 = new Thread(new Worker1(semaphores));
        Thread worker2 = new Thread(new Worker2(semaphores));
        Thread worker3 = new Thread(new Worker3(semaphores));
        worker1.start();
        worker2.start();
        worker3.start();
    }
}

class Semaphores {
    public int empty = 5;
    public int wheel = 0;
    public int frame = 0;
    public int s1 = 3;
    public int s2 = 4;

    public synchronized boolean ps1() {
        if (s1 > 0) {
            s1--;
            return true;
        }
        return false;
    }

    public synchronized boolean ps2() {
        if (s2 > 0) {
            s2--;
            return true;
        }
        return false;
    }

    public synchronized boolean pEmpty() {
        if (empty > 0) {
            empty--;
            return true;
        }
        return false;
    }

    public synchronized boolean pWheel() {
        if (wheel > 0) {
            wheel--;
            return true;
        }
        return false;
    }

    public synchronized boolean pFrame() {
        if (frame > 0) {
            frame--;
            return true;
        }
        return false;
    }

    public synchronized void vs1() {
        s1++;
    }

    public synchronized void vs2() {
        s2++;
    }

    public synchronized void vEmpty() {
        empty++;
    }

    public synchronized void vWheel() {
        wheel++;
    }

    public synchronized void vFrame() {
        frame++;
    }
}

class Worker1 implements Runnable {
    public Semaphores semaphores;

    public Worker1(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            System.out.println("Worker1 produces a frame.");
            while (!semaphores.ps1()) {
            }
            while (!semaphores.pEmpty()) {
            }
            System.out.println("Worker1 puts a frame into the box.");
            semaphores.vFrame();
        }
    }
}

class Worker2 implements Runnable {
    public Semaphores semaphores;

    public Worker2(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            System.out.println("Worker2 produces a wheel.");
            while (!semaphores.ps2()) {
            }
            while (!semaphores.pEmpty()) {
            }
            System.out.println("Worker2 puts a wheel into the box.");
            semaphores.vWheel();
        }
    }
}

class Worker3 implements Runnable {
    public Semaphores semaphores;

    public Worker3(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.pFrame()) {
            }
            System.out.println("Worker3 gets a frame from the box.");
            semaphores.vEmpty();
            semaphores.vs1();
            while (!semaphores.pWheel()) {
            }
            while (!semaphores.pWheel()) {
            }
            System.out.println("Worker3 gets two wheels from the box.");
            semaphores.vEmpty();
            semaphores.vEmpty();
            semaphores.vs2();
            semaphores.vs2();
            System.out.println("Worker3 assembles a frame and two wheels to produce a bike.");
        }
    }
}