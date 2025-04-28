class CustomBlockingQueue {
    private int[] queue;
    private int size;
    private int capacity;
    private int front;
    private int rear;

    public CustomBlockingQueue(int capacity) {
        this.queue = new int[capacity];
        this.size = 0;
        this.capacity = capacity;
        this.front = 0;
        this.rear = -1;
    }

    public synchronized void put(int item) throws InterruptedException {
        while (size == capacity) {
            wait(); 
        }
        rear = (rear + 1) % capacity;
        queue[rear] = item;
        size++;
        System.out.println("producer: " + item);
        notifyAll();
    }

    public synchronized int take() throws InterruptedException {
        while (size == 0) {
            wait();
        }
        int item = queue[front];
        front = (front + 1) % capacity;
        size--;
        System.out.println("cpmstumer: " + item);
        notifyAll();
        return item;
    }
}

class Producer implements Runnable {
    private CustomBlockingQueue queue;

    public Producer(CustomBlockingQueue queue) {
        this.queue = queue;
    }

    @Override
    public void run() {
        for (int i = 0; i < 10; i++) {
            try {
                queue.put(i);

                for (int j = 0; j < 10; j++) {

                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return;
            }
        }
    }
}

class Consumer implements Runnable {
    private CustomBlockingQueue queue;

    public Consumer(CustomBlockingQueue queue) {
        this.queue = queue;
    }

    @Override
    public void run() {
        for (int i = 0; i < 10; i++) {
            try {
                int item = queue.take();

                for (int j = 0; j < 5; j++) {

                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return;
            }
        }
    }
}

public class ProducerConsumerExample {
    public static void main(String[] args) {
        CustomBlockingQueue queue = new CustomBlockingQueue(5);

        Producer producer = new Producer(queue);
        Consumer consumer = new Consumer(queue);

        Thread producerThread = new Thread(producer);
        Thread consumerThread = new Thread(consumer);

        producerThread.start();
        consumerThread.start();
    }
}
