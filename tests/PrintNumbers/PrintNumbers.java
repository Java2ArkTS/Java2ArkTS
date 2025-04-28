class Printer {
    private int currentNumber = 1;
    private int maxNumber;

    public Printer(int maxNumber) {
        this.maxNumber = maxNumber;
    }

    public synchronized void print() {
        while (currentNumber <= maxNumber) {
            System.out.println(" printed: " + currentNumber);
            currentNumber++;
        }
    }
}

class PrintTask implements Runnable {
    private Printer printer;

    public PrintTask(Printer printer) {
        this.printer = printer;
    }

    @Override
    public void run() {
        printer.print();
    }
}

public class PrintNumbers {
    public static void main(String[] args) {
        Printer printer = new Printer(10);
        Thread thread1 = new Thread(new PrintTask(printer));
        Thread thread2 = new Thread(new PrintTask(printer));

        thread1.start();
        thread2.start();
    }
}
