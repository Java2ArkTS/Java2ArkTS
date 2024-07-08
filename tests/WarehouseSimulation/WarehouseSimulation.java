class Warehouse {
    private final int capacity;
    private int currentLoad;

    public Warehouse(int capacity) {
        this.capacity = capacity;
        this.currentLoad = 0;
    }

    public synchronized void store(int amount, String workerName) {
        while (currentLoad + amount > capacity) {
            System.out.println(workerName + " is waiting to store " + amount + " units. Current load: " + currentLoad);

        }
        currentLoad += amount;
        System.out.println(workerName + " stored " + amount + " units. Current load: " + currentLoad);

    }

    public synchronized void retrieve(int amount, String workerName) {
        while (currentLoad < amount) {
            System.out.println(workerName + " is waiting to retrieve " + amount + " units. Current load: " + currentLoad);

        }
        currentLoad -= amount;
        System.out.println(workerName + " retrieved " + amount + " units. Current load: " + currentLoad);

    }

    public synchronized int getCurrentLoad() {
        return currentLoad;
    }
}

class Worker implements Runnable {
    private final String name;
    private final Warehouse warehouse;
    private final boolean isStorer; // true if storing, false if retrieving
    private final int amount;

    public Worker(String name, Warehouse warehouse, boolean isStorer, int amount) {
        this.name = name;
        this.warehouse = warehouse;
        this.isStorer = isStorer;
        this.amount = amount;
    }

    @Override
    public void run() {
        if (isStorer) {
            warehouse.store(amount, name);
        } else {
            warehouse.retrieve(amount, name);
        }
    }
}

public class WarehouseSimulation {
    public static void main(String[] args) {
        Warehouse warehouse = new Warehouse(100); // Warehouse capacity of 100 units

        // Start workers storing and retrieving items
        Thread[] workers = new Thread[10];
        for (int i = 0; i < workers.length; i++) {
            if (i % 2 == 0) {
                workers[i] = new Thread(new Worker("Worker " + i, warehouse, true, 30));
            } else {
                workers[i] = new Thread(new Worker("Worker " + i, warehouse, false, 20));
            }
            workers[i].start();
        }

        // Wait for all workers to finish


        System.out.println("Final load in warehouse: " + warehouse.getCurrentLoad() + " units.");
    }
}
