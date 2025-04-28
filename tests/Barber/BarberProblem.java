/*
 * The barber shop has a barber, a barber chair, 
 * and several chairs for customers waiting to have their hair cut. 
 * If there is no customer, the barber will sleep in the barber chair, 
 * when a customer arrives, the customer must wake the barber, 
 * if the barber is cutting the hair while the customer comes, 
 * if there is an empty chair to sit down and wait, otherwise he will leave. 
 * Implementation of the barber shop synchronization problem.
 */

public class BarberProblem {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread barber1 = new Thread(new Barber(semaphores, 1));
        Thread barber2 = new Thread(new Barber(semaphores, 2));
        Thread customer1 = new Thread(new Customer(semaphores, 1));
        Thread customer2 = new Thread(new Customer(semaphores, 2));
        Thread customer3 = new Thread(new Customer(semaphores, 3));
        barber1.start();
        barber2.start();
        customer1.start();
        customer2.start();
        customer3.start();
    }
}

class Semaphores {
    public int waiting = 0;
    public int charis = 3;
    public int customers = 0;
    public int barbers = 0;
    public boolean mutex = true;

    public synchronized boolean pCustomers() {
        if (customers > 0) {
            customers--;
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

    public synchronized boolean pBarbers() {
        if (barbers > 0) {
            barbers--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void vCustomers() {
        customers++;
    }

    public synchronized void vBarbers() {
        barbers++;
    }

    public synchronized void vMutex() {
        mutex = true;
    }
}

class Barber implements Runnable {
    public Semaphores semaphores;
    public int rank;

    public Barber(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }

    public void run() {
        while (true) {
            while (!semaphores.pCustomers()) {
            }
            while (!semaphores.pMutex()) {
            }
            semaphores.waiting--;
            System.out.println("Barber " + rank + " is cutting hair.");
            semaphores.vBarbers();
            semaphores.vMutex();
        }
    }
}

class Customer implements Runnable {
    public Semaphores semaphores;
    public int rank;

    public Customer(Semaphores semaphores, int rank) {
        this.semaphores = semaphores;
        this.rank = rank;
    }

    public void run() {
        while (!semaphores.pMutex()) {
        }
        if (semaphores.waiting < semaphores.charis) {
            semaphores.waiting++;
            System.out.println("Customer " + rank + " is waiting.");
            semaphores.vCustomers();
            semaphores.vMutex();
            while (!semaphores.pBarbers()) {
            }
        } else {
            System.out.println("Customer " + rank + " leaves.");
            semaphores.vMutex();
        }
    }
}