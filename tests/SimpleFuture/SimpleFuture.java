public class SimpleFuture {
    private String result;
    private boolean isDone;

    public SimpleFuture() {
        this.isDone = false;
    }

    // 设置任务结果，并唤醒等待的线程
    public synchronized void setResult(String result) {
        this.result = result;
        this.isDone = true;
        notifyAll(); // 唤醒所有等待的线程
    }

    // 获取任务结果，如果任务未完成，则等待
    public synchronized String get() {
        while (!isDone) {

        }
        return result;
    }

    // 检查任务是否完成
    public synchronized boolean isDone() {
        return isDone;
    }

    public static void main(String[] args) {
        SimpleFuture future = new SimpleFuture();

        // 启动一个线程来模拟异步任务
        Thread asyncTask = new Thread(() -> {

                // 模拟异步任务需要一些时间来完成
                for(int i=0;i<1000;i++);

            future.setResult("Task completed"); // 设置结果
        });

        asyncTask.start();

        System.out.println("Doing something else...");

        // 获取异步任务结果
        String result = future.get();
        System.out.println("Result: " + result);
    }
}