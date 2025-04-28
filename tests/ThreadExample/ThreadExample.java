class Counter implements Runnable {
    private int count = 0;

    public synchronized void increment() {
        count++;
    }

    public synchronized int getCount() {
        return count;
    }

    @Override
    public void run() {
        for (int i = 0; i < 10000; i++) {
            increment();
        }
    }
}

public class ThreadExample {
    public static void main(String[] args) {
        Counter counter = new Counter();

        Thread thread1 = new Thread(counter);
        Thread thread2 = new Thread(counter);

        thread1.start();
        thread2.start();
    }
}