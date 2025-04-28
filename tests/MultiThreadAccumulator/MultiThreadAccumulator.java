class Accumulator {
    private int sum;

    public synchronized void addToSum(int value) {
        sum += value;
        System.out.println(" added " + value + ". Current sum: " + sum);
    }

    public synchronized int getSum() {
        return sum;
    }
}

class AdderTask implements Runnable {
    private Accumulator accumulator;
    private int valueToAdd;

    public AdderTask(Accumulator accumulator, int valueToAdd) {
        this.accumulator = accumulator;
        this.valueToAdd = valueToAdd;
    }

    @Override
    public void run() {
        accumulator.addToSum(valueToAdd);
    }
}

public class MultiThreadAccumulator {
    public static void main(String[] args) {
        Accumulator accumulator = new Accumulator();
        Thread thread1 = new Thread(new AdderTask(accumulator, 5));
        Thread thread2 = new Thread(new AdderTask(accumulator, 10));

        thread1.start();
        thread2.start();
    }
}
