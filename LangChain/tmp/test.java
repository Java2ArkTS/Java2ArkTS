public class AlternatePrintingExample {
    public static void main(String[] args) {
        EvenNumberTask task = new EvenNumberTask();
        Thread thread1 = new Thread(task);
        Thread thread2 = new Thread(task);
        thread1.start();
        thread2.start();
    }
}

class EvenNumberTask implements Runnable {
    public int printer = 0;

    public synchronized void run() {
        this.printer++;
        System.out.println("fuck " + printer);
    }
}