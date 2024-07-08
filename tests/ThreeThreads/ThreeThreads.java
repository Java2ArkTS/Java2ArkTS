/*
 * There are three cooperative processes P1, P2, P3, 
 * they all need to input their respective data a, b, c through the same device, 
 * the input device must be used mutually exclusive, 
 * and the first data must be read by the P1 process, 
 * the second data must be read by the P2 process, 
 * the third data must be read by the P3 process. 
 * Each of the three processes then performs the following calculations on the input data:
 * P1: x = a + b;
 * P2: y = a * b;
 * P3: z = y + c - a;
 * Finally, the P1 process prints out the values of x, y, and z 
 * through the connected printer. 
 * Synchronize the three processes.
 */

public class ThreeThreads {
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
    public int s1 = 1;
    public int s2 = 0;
    public int s3 = 0;
    public int sb = 0;
    public int sy = 0;
    public int sz = 0;
    public synchronized boolean Ps1() {
        if (s1 > 0) {
            s1--;
            return true;
        } else {
            return false;
        }
    }
    public synchronized boolean Ps2() {
        if (s2 > 0) {
            s2--;
            return true;
        } else {
            return false;
        }
    }
    public synchronized boolean Ps3() {
        if (s3 > 0) {
            s3--;
            return true;
        } else {
            return false;
        }
    }
    public synchronized boolean Psb() {
        if (sb > 0) {
            sb--;
            return true;
        } else {
            return false;
        }
    }
    public synchronized boolean Psy() {
        if (sy > 0) {
            sy--;
            return true;
        } else {
            return false;
        }
    }
    public synchronized boolean Psz() {
        if (sz > 0) {
            sz--;
            return true;
        } else {
            return false;
        }
    }
    public synchronized void Vs1() {
        s1++;
    }
    public synchronized void Vs2() {
        s2++;
    }
    public synchronized void Vs3() {
        s3++;
    }
    public synchronized void Vsb() {
        sb++;
    }
    public synchronized void Vsy() {
        sy++;
    }
    public synchronized void Vsz() {
        sz++;
    }
}

class P1 implements Runnable {
    public Semaphores semaphores;
    public P1(Semaphores semaphores) {
        this.semaphores = semaphores;
    }
    public void run() {
        while (!semaphores.Ps1()) {}
        System.out.println("P1 reads a from the input device.");
        semaphores.Vs2();
        while (!semaphores.Psb()) {}
        System.out.println("P1 computes x = a + b.");
        while (!semaphores.Psy()) {}
        while (!semaphores.Psz()) {}
        System.out.println("P1 prints the results of x, y and z.");
    }
}

class P2 implements Runnable {
    public Semaphores semaphores;
    public P2(Semaphores semaphores) {
        this.semaphores = semaphores;
    }
    public void run() {
        while (!semaphores.Ps2()) {}
        System.out.println("P2 reads b from the input device.");
        semaphores.Vs3();
        semaphores.Vsb();
        System.out.println("P2 computes y = a * b.");
        semaphores.Vsy();
        semaphores.Vsy();
    }
}

class P3 implements Runnable {
    public Semaphores semaphores;
    public P3(Semaphores semaphores) {
        this.semaphores = semaphores;
    }
    public void run() {
        while (!semaphores.Ps3()) {}
        System.out.println("P3 reads c from the input device.");
        while (!semaphores.Psy()) {}
        System.out.println("P3 computes z = y + c - a.");
        semaphores.Vsz();
    }
}