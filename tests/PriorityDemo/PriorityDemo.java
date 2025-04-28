public class PriorityDemo {
    public static int count = 0;

    public static void main(String args[]) {
        Thread high = new HightPriority();
        Thread low = new LowPriority();
        high.setPriority(Thread.MAX_PRIORITY);
        low.setPriority(Thread.MIN_PRIORITY);
        low.start();
        high.start();
    }
}

class HightPriority extends Thread {
    public void run() {
        while (true) {
            synchronized (PriorityDemo.class) {
                PriorityDemo.count++;
                if (PriorityDemo.count > 1000000) {
                    System.out.println("HightPriority is complete!");
                    break;
                }
            }
        }
    }
}

class LowPriority extends Thread {
    public void run() {
        while (true) {
            synchronized (PriorityDemo.class) {
                PriorityDemo.count++;
                if (PriorityDemo.count > 1000000) {
                    System.out.println("LowPriority is complete!");
                    break;
                }
            }
        }
    }
}