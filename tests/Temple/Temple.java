/*
 * A temple has a number of young monks and old monks, 
 * there is a water tank, 
 * by the young monk to carry water into the tank for the old monk to drink. 
 * The water tank can hold 10 barrels of water, 
 * and the water is taken from the same well. 
 * The well is narrow and can only hold one bucket at a time. 
 * The total number of buckets is 3. 
 * Only one bucket of water is taken each time, 
 * and cannot be carried out at the same time. 
 * The algorithm description of water intake and water intake from cylinder is given.
 */

public class Temple {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread younger1 = new Thread(new Younger(semaphores, 1));
        Thread younger2 = new Thread(new Younger(semaphores, 2));
        Thread older1 = new Thread(new Older(semaphores, 1));
        Thread older2 = new Thread(new Older(semaphores, 2));
        younger1.start();
        younger2.start();
        older1.start();
        older2.start();
    }
}

class Semaphores {
    public boolean well = true;
    public boolean vat = true;
    public int empty = 10;
    public int full = 0;
    public int pail = 3;

    public synchronized boolean P_well() {
        if (well) {
            well = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_vat() {
        if (vat) {
            vat = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_empty() {
        if (empty > 0) {
            empty--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_full() {
        if (full > 0) {
            full--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_pail() {
        if (pail > 0) {
            pail--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void V_well() {
        well = true;
    }

    public synchronized void V_vat() {
        vat = true;
    }

    public synchronized void V_empty() {
        empty++;
    }

    public synchronized void V_full() {
        full++;
    }

    public synchronized void V_pail() {
        pail++;
    }
}

class Older implements Runnable {
    public Semaphores semaphores;
    public int rank;

    public Older(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }

    public void run() {
        while (true) {
            while (!semaphores.P_full()) {
            }
            while (!semaphores.P_pail()) {
            }
            while (!semaphores.P_vat()) {
            }
            System.out.println("Old monk " + rank + " gets a bucket of water from the tank.");
            semaphores.V_vat();
            semaphores.V_empty();
            System.out.println("Old monk " + rank + " drinks water.");
            semaphores.V_pail();
        }
    }
}

class Younger implements Runnable {
    public Semaphores semaphores;
    public int rank;

    public Younger(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }

    public void run() {
        while (true) {
            while (!semaphores.P_empty()) {
            }
            while (!semaphores.P_pail()) {
            }
            while (!semaphores.P_well()) {
            }
            System.out.println("Young monk " + rank + " gets a bucket of water from the well.");
            semaphores.V_well();
            while (!semaphores.P_vat()) {
            }
            System.out.println("Younge monk " + rank + " pour the water to the tank.");
            semaphores.V_vat();
            semaphores.V_full();
            semaphores.V_pail();
        }
    }
}