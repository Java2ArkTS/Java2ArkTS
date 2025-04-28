public class InconsistentReadDemo {
    int count = 1;

    public static void main(String[] args) {
        InconsistentReadDemo demo = new InconsistentReadDemo();

        Thread thread = new Thread(new ConcurrencyCheckTask(demo));
        thread.start();

        while (true) {
            demo.count++;
        }
    }
}

class ConcurrencyCheckTask implements Runnable {
    private InconsistentReadDemo demo;

    public ConcurrencyCheckTask(InconsistentReadDemo demo) {
        this.demo = demo;
    }

    public void run() {
        int c = 0;
        for (int i = 0; ; i++) {
            // 2 consecutive reads in the same thread
            int c1 = demo.count;
            int c2 = demo.count;
            if (c1 != c2) {
                c++;
                // On my dev machine,
                // a batch of inconsistent reads can be observed when the process starts
                System.err.printf("Inconsistent read observed!! Check time=%s, Occurrence=%s (%s%%), 1=%s, 2=%s%n",
                        i + 1, c, (float) c / (i + 1) * 100, c1, c2);
            }
        }
    }
}