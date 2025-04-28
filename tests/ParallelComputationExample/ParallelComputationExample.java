public class ParallelComputationExample {

    public static void main(String[] args) {
        int[] array = new int[100];
        for (int i = 0; i < array.length; i++) {
            array[i] = i + 1;
        }

        int numThreads = 4;
        int chunkSize = array.length / numThreads;
        Thread[] threads = new Thread[numThreads];
        ST[] tasks = new ST[numThreads];

        // 创建并启动多个线程
        for (int i = 0; i < numThreads; i++) {
            int start = i * chunkSize;
            int end = (i == numThreads - 1) ? array.length : start + chunkSize;
            tasks[i] = new ST(array, start, end);
            threads[i] = new Thread(tasks[i]);
            threads[i].start();
        }

        // 等待所有线程完成
        int totalSum = 0;
        for (int i = 0; i < numThreads; i++) {
            try {
                threads[i].join();
                totalSum += tasks[i].getSum();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        System.out.println("Total sum of squares: " + totalSum);
    }
}

class ST implements Runnable {
    private final int[] array;
    private final int start;
    private final int end;
    private int sum;

    public ST(int[] array, int start, int end) {
        this.array = array;
        this.start = start;
        this.end = end;
        this.sum = 0;
    }

    @Override
    public void run() {
        for (int i = start; i < end; i++) {
            sum += array[i] * array[i];
        }
    }

    public int getSum() {
        return sum;
    }
}
