class Bridge {
    private int capacity;
    private String[] vehicles;
    private int count;

    public Bridge(int capacity) {
        this.capacity = capacity;
        this.vehicles = new String[capacity];
        this.count = 0;
    }

    public synchronized void cross(String vehicleName) {
        while (count >= capacity) {
            System.out.println(vehicleName + " is waiting to cross the bridge.");

        }

        vehicles[count] = vehicleName;
        count++;

        System.out.println(vehicleName + " is crossing the bridge.");
        for(int i=0;i<1000;i++);

        count--;

        System.out.println(vehicleName + " has crossed the bridge.");

        // Shift vehicles in the array to maintain order (if needed)
        for (int i = 0; i < count; i++) {
            vehicles[i] = vehicles[i + 1];
        }
        vehicles[count] = null;


    }
}

class Vehicle implements Runnable {
    private String name;
    private Bridge bridge;

    public Vehicle(String name, Bridge bridge) {
        this.name = name;
        this.bridge = bridge;
    }

    @Override
    public void run() {
        bridge.cross(name);
    }
}

public class Car {
    public static void main(String[] args) {
        Bridge bridge = new Bridge(2); // Example capacity of 2 vehicles
        for (int i = 1; i <= 5; i++) {
            Thread vehicleThread = new Thread(new Vehicle("Vehicle " + i, bridge));
            vehicleThread.start();
        }
    }
}
