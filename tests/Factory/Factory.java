/*
 * A factory has two production workshops and an assembly workshop, 
 * the two production workshops respectively produce A and B two kinds of parts, 
 * the task of the assembly workshop is to assemble these two kinds of parts into products. 
 * After each part is produced in the two production workshops, 
 * they are respectively sent to the assembly shop shelves F1 and F2. 
 * F1 stores part A, F2 stores part B, and the capacity of F1 and F2 can store 10 parts. 
 * Assembly workers take one part A and one part B from the shelf at a time 
 * and assemble them into products.
 */

class Factory {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread workshopA = new Thread(new WorkshopA(semaphores));
        Thread worpshopB = new Thread(new WorkshopB(semaphores));
        Thread workshopAsm = new Thread(new WorkshopAsm(semaphores));
        workshopA.start();
        worpshopB.start();
        workshopAsm.start();
    }
}

class Semaphores {
    public int empty1 = 10;
    public int full1 = 0;
    public int empty2 = 10;
    public int full2 = 0;
    public boolean mutex1 = true;
    public boolean mutex2 = true;

    public synchronized boolean P_empty1() {
        if (empty1 > 0) {
            empty1--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_empty2() {
        if (empty2 > 0) {
            empty2--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_full1() {
        if (full1 > 0) {
            full1--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_full2() {
        if (full2 > 0) {
            full2--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_mutex1() {
        if (mutex1) {
            mutex1 = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean P_mutex2() {
        if (mutex2) {
            mutex2 = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void V_empty1() {
        empty1++;
    }

    public synchronized void V_empty2() {
        empty2++;
    }

    public synchronized void V_full1() {
        full1++;
    }

    public synchronized void V_full2() {
        full2++;
    }

    public synchronized void V_mutex1() {
        mutex1 = true;
    }

    public synchronized void V_mutex2() {
        mutex2 = true;
    }
}

class WorkshopA implements Runnable {
    public Semaphores semaphores;

    public WorkshopA(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            System.out.println("Workshop A produces a production A.");
            while (!semaphores.P_empty1()) {
            }
            while (!semaphores.P_mutex1()) {
            }
            System.out.println("Workshop A puts a production A onto the shelf F1.");
            semaphores.V_mutex1();
            semaphores.V_full1();
        }
    }
}

class WorkshopB implements Runnable {
    public Semaphores semaphores;

    public WorkshopB(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            System.out.println("Workshop B produces a production B.");
            while (!semaphores.P_empty2()) {
            }
            while (!semaphores.P_mutex2()) {
            }
            System.out.println("Workshop B puts a production B onto the shelf F2.");
            semaphores.V_mutex2();
            semaphores.V_full2();
        }
    }
}

class WorkshopAsm implements Runnable {
    public Semaphores semaphores;

    public WorkshopAsm(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.P_full1()) {
            }
            while (!semaphores.P_mutex1()) {
            }
            System.out.println("WorkshopAsm gets a production A from the shelf F1.");
            semaphores.V_mutex1();
            semaphores.V_empty1();
            while (!semaphores.P_full2()) {
            }
            while (!semaphores.P_mutex2()) {
            }
            System.out.println("WorkshopAsm gets a production B from the shelf F2.");
            semaphores.V_mutex2();
            semaphores.V_empty2();
            System.out.println("WorkshopAsm assemble production A and production B into the whole production.");
        }
    }
}