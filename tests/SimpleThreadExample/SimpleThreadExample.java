public class SimpleThreadExample {
    private static int counter = 0;

    public static void main(String[] args) {
        Thread thread1 = new Thread(new CounterIncrementer());
        Thread thread2 = new Thread(new CounterIncrementer());

        thread1.start();
        thread2.start();


        System.out.println("Final counter value: " + counter);
    }

    static class CounterIncrementer implements Runnable {
        @Override
        public void run() {
            for (int i = 0; i < 1000; i++) {
                incrementCounter();
            }
        }

        private synchronized void incrementCounter() {
            counter++;
        }
    }
}
