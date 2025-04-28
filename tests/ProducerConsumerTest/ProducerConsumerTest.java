class SharedBuffer {
    private int data;
    private boolean isEmpty = true;

    public synchronized void produce(int newData) {
        data = newData;
        isEmpty = false;
        System.out.println("Produced: " + data);
    }

    public synchronized int consume() {
        if(!isEmpty){
            System.out.println("Consumed: " + data);
            isEmpty = true;
        }
        return data;
    }
}

class Producer implements Runnable {
    private SharedBuffer buffer;

    public Producer(SharedBuffer buffer) {
        this.buffer = buffer;
    }

    @Override
    public void run() {
        for (int i = 0; i < 10; i++) {
            buffer.produce(i);
        }
    }
}

class Consumer implements Runnable {
    private SharedBuffer buffer;

    public Consumer(SharedBuffer buffer) {
        this.buffer = buffer;
    }

    @Override
    public void run() {
        for (int i = 0; i < 10; i++) {
            buffer.consume();
        }
    }
}

public class ProducerConsumerTest {
    public static void main(String[] args) {
        SharedBuffer buffer = new SharedBuffer();
        Thread producerThread = new Thread(new Producer(buffer));
        Thread consumerThread = new Thread(new Consumer(buffer));

        producerThread.start();
        consumerThread.start();
    }
}