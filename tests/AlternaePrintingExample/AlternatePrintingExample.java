public class AlternatePrintingExample {

    public static void main(String[] args) {
        NumberPrinter printer = new NumberPrinter();

        // 创建并启动第一个线程，打印奇数
        Thread oddThread = new Thread(new OddNumberTask(printer));
        oddThread.start();

        // 创建并启动第二个线程，打印偶数
        Thread evenThread = new Thread(new EvenNumberTask(printer));
        evenThread.start();
    }
}

class NumberPrinter {
    private int number = 1;
    private final int maxNumber = 10;
    private boolean isOddTurn = true; // 控制奇偶数交替打印的标志

    // 打印奇数
    public synchronized void printOdd() {
        while (number <= maxNumber) {
            if (isOddTurn && number % 2 != 0) {
                System.out.println(Thread.currentThread().getName() + " - Odd: " + number);
                number++;
                isOddTurn = false; // 切换到偶数的轮次

            }
        }
    }

    // 打印偶数
    public synchronized void printEven() {
        while (number <= maxNumber) {
            if (!isOddTurn && number % 2 == 0) {
                System.out.println(Thread.currentThread().getName() + " - Even: " + number);
                number++;
                isOddTurn = true; // 切换到奇数的轮次

            }
        }
    }
}

class OddNumberTask implements Runnable {
    private final NumberPrinter printer;

    public OddNumberTask(NumberPrinter printer) {
        this.printer = printer;
    }

    @Override
    public void run() {
        printer.printOdd();
    }
}

class EvenNumberTask implements Runnable {
    private final NumberPrinter printer;

    public EvenNumberTask(NumberPrinter printer) {
        this.printer = printer;
    }

    @Override
    public void run() {
        printer.printEven();
    }
}
