class Inventory {
    private int stock;

    public Inventory(int initialStock) {
        this.stock = initialStock;
    }

    public synchronized void addStock(int amount) {
        stock += amount;
        System.out.println(" added " + amount + " units. Current stock: " + stock);
    }

    public synchronized void removeStock(int amount) {
        if (amount <= stock) {
            stock -= amount;
            System.out.println(" removed " + amount + " units. Current stock: " + stock);
        } else {
            System.out.println(" tried to remove " + amount + " units, but only " + stock + " units available.");
        }
    }

    public synchronized int getStock() {
        return stock;
    }
}

class AddStockTask implements Runnable {
    private Inventory inventory;
    private int amount;

    public AddStockTask(Inventory inventory, int amount) {
        this.inventory = inventory;
        this.amount = amount;
    }

    @Override
    public void run() {
        inventory.addStock(amount);
    }
}

class RemoveStockTask implements Runnable {
    private Inventory inventory;
    private int amount;

    public RemoveStockTask(Inventory inventory, int amount) {
        this.inventory = inventory;
        this.amount = amount;
    }

    @Override
    public void run() {
        inventory.removeStock(amount);
    }
}

public class InventoryManagementTest {
    public static void main(String[] args) {
        Inventory inventory = new Inventory(100);

        Thread thread1 = new Thread(new AddStockTask(inventory, 30));
        Thread thread2 = new Thread(new RemoveStockTask(inventory, 50));
        Thread thread3 = new Thread(new AddStockTask(inventory, 20));
        Thread thread4 = new Thread(new RemoveStockTask(inventory, 70));

        thread1.start();
        thread2.start();
        thread3.start();
        thread4.start();
    }
}
