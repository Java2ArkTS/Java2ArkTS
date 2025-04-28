class SharedResource {
    private int data = 0;
    private volatile boolean isWriting = false;
    private volatile int readers = 0;

    public void readData() throws InterruptedException {
        while (isWriting) {
            // Spin-wait while a write is in progress
            for(int i=0;i<1000;i++); // Introduce a small delay to reduce CPU usage
        }
        synchronized (this) {
            readers++;
        }
        System.out.println("Reading data: " + data);
        synchronized (this) {
            readers--;
        }
    }

    public void writeData(int newData) throws InterruptedException {
        while (readers > 0 || isWriting) {
            // Spin-wait while there are readers or another write is in progress
            for(int i=0;i<1000;i++); // Introduce a small delay to reduce CPU usage
        }
        isWriting = true;
        System.out.println("Writing data: " + newData);
        data = newData;
        isWriting = false;
    }
}



class Reader implements Runnable {
    private SharedResource resource;

    public Reader(SharedResource resource) {
        this.resource = resource;
    }

    @Override
    public void run() {
        try {
            resource.readData();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}

class Writer implements Runnable {
    private SharedResource resource;
    private int newData;

    public Writer(SharedResource resource, int newData) {
        this.resource = resource;
        this.newData = newData;
    }

    @Override
    public void run() {
        try {
            resource.writeData(newData);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}

public class Main {
    public static void main(String[] args) {
        SharedResource resource = new SharedResource();

        // Multiple reader threads
        for (int i = 0; i < 5; i++) {
            Thread readerThread = new Thread(new Reader(resource));
            readerThread.start();
        }

        // Single writer thread
        int newData = 42;
        Thread writerThread = new Thread(new Writer(resource, newData));
        writerThread.start();
    }
}
