class Restaurant {
    private int availableSeats;

    public Restaurant(int seats) {
        this.availableSeats = seats;
    }

    public synchronized void takeSeat(String customerName) {
        if (availableSeats > 0) {
            availableSeats--;
            System.out.println(customerName + " took a seat. Available seats: " + availableSeats);
        } else {
            System.out.println("No available seats for " + customerName);
        }
    }

    public synchronized void placeOrder(String customerName, String order) {
        System.out.println(customerName + " placed order: " + order);
    }

    public synchronized void leaveSeat(String customerName) {
        availableSeats++;
        System.out.println(customerName + " left the seat. Available seats: " + availableSeats);
    }
}

class Customer implements Runnable {
    private Restaurant restaurant;
    private String name;
    private String order;

    public Customer(Restaurant restaurant, String name, String order) {
        this.restaurant = restaurant;
        this.name = name;
        this.order = order;
    }

    @Override
    public void run() {
        restaurant.takeSeat(name);
        restaurant.placeOrder(name, order);
        restaurant.leaveSeat(name);
    }
}

public class RestaurantTest {
    public static void main(String[] args) {
        Restaurant restaurant = new Restaurant(5);

        Thread customer1 = new Thread(new Customer(restaurant, "Alice", "Pizza"));
        Thread customer2 = new Thread(new Customer(restaurant, "Bob", "Burger"));
        Thread customer3 = new Thread(new Customer(restaurant, "Charlie", "Salad"));

        customer1.start();
        customer2.start();
        customer3.start();
    }
}
