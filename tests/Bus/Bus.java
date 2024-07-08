/*
 * The activities of bus drivers and conductors are as follows:
 * Driver's activities: start the vehicle, run normally, stop at the station.
 * Conductor's activities: Close doors, sell tickets, open doors.
 * The car constantly arrives at the station, stops, and drives, 
 * realizing the synchronization of the driver and the conductor.
 */

public class Bus {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread driver = new Thread(new Driver(semaphores));
        Thread conductor = new Thread(new Conductor(semaphores));
        driver.start();
        conductor.start();
    }
}

class Semaphores {
    public boolean s1 = false;
    public boolean s2 = false;

    public synchronized boolean ps1() {
        if (s1) {
            s1 = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean ps2() {
        if (s2) {
            s2 = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void vs1() {
        s1 = true;
    }

    public synchronized void vs2() {
        s2 = true;
    }
}

class Driver implements Runnable {
    public Semaphores semaphores;

    public Driver(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.ps1()) {
            }
            System.out.println("Bus starts.");
            System.out.println("Driver is driving.");
            System.out.println("Bus stops.");
            semaphores.vs2();
        }
    }
}

class Conductor implements Runnable {
    public Semaphores semaphores;

    public Conductor(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            System.out.println("Conductor closes the door.");
            semaphores.vs1();
            System.out.println("Conductor sells tickets.");
            while (!semaphores.ps2()) {
            }
            System.out.println("Conductor opens the door.");
            System.out.println("Customers get on/off the bus.");
        }
    }
}