class ShoppingCart {
    private int itemCount = 0; // 购物车中的商品数量

    // 向购物车添加商品
    public synchronized void addItem() {
        itemCount++;
        System.out.println("Item added. Total items in cart: " + itemCount);
    }

    // 从购物车移除商品
    public synchronized void removeItem() {
        if (itemCount > 0) {
            itemCount--;
            System.out.println("Item removed. Total items in cart: " + itemCount);
        } else {
            System.out.println("No items to remove.");
        }
    }

    // 显示购物车状态
    public synchronized void displayCart() {
        System.out.println("Shopping Cart contains " + itemCount + " items.");
    }
}

class Shopper implements Runnable {
    private ShoppingCart cart;
    private int addOperations;
    private int removeOperations;

    public Shopper(ShoppingCart cart, int addOperations, int removeOperations) {
        this.cart = cart;
        this.addOperations = addOperations;
        this.removeOperations = removeOperations;
    }

    @Override
    public void run() {
        for (int i = 0; i < addOperations; i++) {
            cart.addItem();
        }
        for (int i = 0; i < removeOperations; i++) {
            cart.removeItem();
        }
    }
}

public class ShoppingCartSystem {
    public static void main(String[] args) {
        ShoppingCart cart = new ShoppingCart();

        // 创建多个购物者线程
        Thread shopper1 = new Thread(new Shopper(cart, 5, 3));
        Thread shopper2 = new Thread(new Shopper(cart, 3, 2));

        shopper1.start();
        shopper2.start();
    }
}