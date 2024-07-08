/*
 * There is a bridge as shown in the picture, 
 * and the direction of traffic flow is shown by the arrow. 
 * Suppose two cars are not allowed to intersect on the bridge, 
 * but multiple cars are allowed to travel in the same direction. 
 * Traffic management on the bridge.
 */

public class BridgeTraffic {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread n2s = new Thread(new N2S(semaphores));
        Thread s2n = new Thread(new S2N(semaphores));
        n2s.start();
        s2n.start();
    }
}

class Semaphores {
    public int countSN = 0;
    public int countNS = 0;
    public boolean mutexSN = true;
    public boolean mutexNS = true;
    public boolean bridge = true;

    public synchronized boolean PSN() {
        if (mutexSN) {
            mutexSN = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean PNS() {
        if (mutexNS) {
            mutexNS = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean Pb() {
        if (bridge) {
            bridge = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void VSN() {
        mutexSN = true;
    }

    public synchronized void VNS() {
        mutexNS = true;
    }

    public synchronized void Vb() {
        bridge = true;
    }
}

class S2N implements Runnable {
    public Semaphores semaphores;

    public S2N(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.PSN()) {
            }
            if (semaphores.countSN == 0) {
                while (!semaphores.Pb()) {
                }
            }
            semaphores.countSN++;
            semaphores.VSN();
            System.out.println("From S to N.");
            while (!semaphores.PSN()) {
            }
            semaphores.countSN--;
            if (semaphores.countSN == 0) {
                semaphores.Vb();
            }
            semaphores.VSN();
        }
    }
}

class N2S implements Runnable {
    public Semaphores semaphores;

    public N2S(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.PNS()) {
            }
            if (semaphores.countNS == 0) {
                while (!semaphores.Pb()) {
                }
            }
            semaphores.countNS++;
            semaphores.VNS();
            System.out.println("From N to S.");
            while (!semaphores.PNS()) {
            }
            semaphores.countNS--;
            if (semaphores.countNS == 0) {
                semaphores.Vb();
            }
            semaphores.VNS();
        }
    }
}