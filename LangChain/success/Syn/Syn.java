class TestThread implements Runnable {
    private int tickets = 10000;
    public void run() {
        while (true) {
            sale();
        }
    }
    public synchronized void sale() {
        if (tickets > 0) {
            if (tickets % 100 == 0)
                System.out.println("is sailing ticket" + tickets);
            tickets = tickets-1;
        }
    }
    public int sum(int a, int b) {
        return a + b;
    }
}

public class Syn {
    public static void main(String[] args) {
        TestThread tt = new TestThread();
        new Thread(tt).start();
        new Thread(tt).start();
        new Thread(tt).start();
        new Thread(tt).start();
    }
}