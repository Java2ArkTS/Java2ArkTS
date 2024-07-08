public class Smokers {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread thread1 = new Thread(new P1(semaphores));
        Thread thread2 = new Thread(new P2(semaphores));
        Thread thread3 = new Thread(new P3(semaphores));
        Thread thread4 = new Thread(new P4(semaphores));
        thread1.start();
        thread2.start();
        thread3.start();
        thread4.start();
    }
}

class Semaphores {
    public int num = 0;
    public boolean offer1 = false;
    public boolean offer2 = false;
    public boolean offer3 = false;
    public boolean finish = false;

    public synchronized void V_offer1() {
        offer1 = true;
    }

    public synchronized void V_offer2() {
        offer2 = true;
    }

    public synchronized void V_offer3() {
        offer3 = true;
    }

    public synchronized void V_finish() {
        finish = true;
    }

    public synchronized boolean P_finish() {
        if (finish) {
            finish = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_offer1() {
        if (offer1) {
            offer1 = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_offer2() {
        if (offer2) {
            offer2 = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_offer3() {
        if (offer3) {
            offer3 = false;
            return true;
        } else {
            return false;
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
            semaphores.num++;
            semaphores.num %= 3;
            if (semaphores.num == 0) {
                semaphores.V_offer1();
            } else if (semaphores.num == 1) {
                semaphores.V_offer2();
            } else {
                semaphores.V_offer3();
            }
            System.out.println("P1 put things onto the table.");
            while (!semaphores.P_finish()) {
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
            while (!semaphores.P_offer3()) {
            }
            System.out.println("P2 is smoking.");
            semaphores.V_finish();
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
            while (!semaphores.P_offer2()) {
            }
            System.out.println("P3 is smoking.");
            semaphores.V_finish();
        }
    }
}

class P4 implements Runnable {
    public Semaphores semaphores;

    public P4(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.P_offer1()) {
            }
            System.out.println("P4 is smoking.");
            semaphores.V_finish();
        }
    }
}