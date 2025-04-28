class CustomReadWriteLock {
    private int readers = 0;
    private boolean writing = false;

    public synchronized void lockRead()  {
        while (writing) {

        }
        readers++;
    }

    public synchronized void unlockRead() {
        readers--;
        if (readers == 0) {

        }
    }

    public synchronized void lockWrite() {
        while (readers > 0 || writing) {

        }
        writing = true;
    }

    public synchronized void unlockWrite() {
        writing = false;

    }
}

class SharedData {
    private final CustomReadWriteLock lock = new CustomReadWriteLock();
    private int data = 0;

    public void readData(String readerName) {

            lock.lockRead();
            System.out.println(readerName + " is reading data: " + data);
           for(int j=0;j<1000;j++);
            lock.unlockRead();

    }

    public void writeData(String writerName, int newData) {
            lock.lockWrite();
            System.out.println(writerName + " is writing data: " + newData);
            data = newData;
          for(int j=0;j<1000;j++);


            lock.unlockWrite();
    }
}

class ReaderWorker implements Runnable {
    private final String name;
    private final SharedData sharedData;

    public ReaderWorker(String name, SharedData sharedData) {
        this.name = name;
        this.sharedData = sharedData;
    }

    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            sharedData.readData(name);
            try {
                Thread.sleep(200); // Simulate time between reads
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

class WriterWorker implements Runnable {
    private final String name;
    private final SharedData sharedData;

    public WriterWorker(String name, SharedData sharedData) {
        this.name = name;
        this.sharedData = sharedData;
    }

    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            sharedData.writeData(name, i);
            try {
                Thread.sleep(200); // Simulate time between writes
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

public class ReadWriteSimulation {
    public static void main(String[] args) {
        SharedData sharedData = new SharedData();

        Thread reader1 = new Thread(new ReaderWorker("Reader 1", sharedData));
        Thread reader2 = new Thread(new ReaderWorker("Reader 2", sharedData));
        Thread writer1 = new Thread(new WriterWorker("Writer 1", sharedData));
        Thread writer2 = new Thread(new WriterWorker("Writer 2", sharedData));

        reader1.start();
        reader2.start();
        writer1.start();
        writer2.start();
    }
}
