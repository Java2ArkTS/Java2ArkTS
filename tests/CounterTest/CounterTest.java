class Counter {
    private int count = 0;

    public synchronized void increment() {
        count++;
        System.out.println(" incremented count to " + count);
    }

    public synchronized void decrement() {
        count--;
        System.out.println(" decremented count to " + count);
    }

    public synchronized int getCount() {
        return count;
    }
}

class IncrementTask implements Runnable {
    private Counter counter;

    public IncrementTask(Counter counter) {
        this.counter = counter;
    }

    @Override
    public void run() {
        for (int i = 0; i < 10; i++) {
            counter.increment();
        }
    }
}

class DecrementTask implements Runnable {
    private Counter counter;

    public DecrementTask(Counter counter) {
        this.counter = counter;
    }

    @Override
    public void run() {
        for (int i = 0; i < 10; i++) {
            counter.decrement();
        }
    }
}

public class CounterTest {
    public static void main(String[] args) {
        Counter counter = new Counter();

        Thread incrementThread = new Thread(new IncrementTask(counter));
        Thread decrementThread = new Thread(new DecrementTask(counter));

        incrementThread.start();
        decrementThread.start();

        System.out.println("Final count: " + counter.getCount());
    }
}