class Samples:
    def __init__(self):
        self.base = """
        public class TicketBookingTest.java {

    public static void main(String[] args) {
        TestThread tt = new TestThread();
        new Thread(tt).start();
        new Thread(tt).start();
        new Thread(tt).start();
        new Thread(tt).start();
    }
}

//可并发的类
class TestThread implements Runnable {

    private int tickets = 10000;

    public void run() {
        while (true) {
            sale();
        }
    }

    //Synchronized method
    public synchronized void sale() {
        if (tickets > 0) {
            if (tickets % 100 == 0)
                System.out.println(Thread.currentThread().getName() + "is sailing ticket" + tickets);
            tickets--;
        }
    }

    public int sum(int a, int b) {
        return a + b;
    }
}
        """

        self.bingFa = """
        public class TicketBookingTest.java {

    public static void main(String[] args) {
        TestThread tt = new TestThread();
        new Thread(tt).start();
        new Thread(tt).start();
        new Thread(tt).start();
        new Thread(tt).start();
    }
}

//可并发的类
class TestThread implements Runnable {

    private int tickets = 10000;

    public void run() {
        while (true) {
            sale();
        }
    }

    //Synchronized method
    public synchronized void sale() {
        if (tickets > 0) {
            if (tickets % 100 == 0)
                System.out.println(Thread.currentThread().getName() + "is sailing ticket" + tickets);
            tickets--;
        }
    }

    public int sum(int a, int b) {
        return a + b;
    }
}
        """

        self.inClass = """
        class Test {

    private int a = 1;
    
    public class Inner {

        private int b = 2;

        public int sum() {
            return a + b;
        }
    }
}

class Run {

    public void run() {
        Test test = new Test();
        Test.Inner inner = test.new Inner();
        int b = inner.sum();
    }
}
        """

        self.mix = """
        class ThreadTest {

    private int a;

    private int b;

    public ThreadTest(int a, int b) {
        this.a = a;
        this.b = b;
    }

    public int sum() {
        return a + b;
    }
}

//可并发的类
class Test extends Thread {

    private int tickets = 100;

    public void run() {
        while (tickets > 0) {
            tickets--;
        }
    }
}

//可并发的类
class Other implements Runnable {

    private int ok = 100;

    @Override
    public void run() {
        while (ok > 0) {
            ok--;
        }
    }
}
        """

        self.normal = """
        class Test extends Father implements Test_interface {
        
    private ArrayList<Integer> a = new ArrayList<>();

    public Test(int b, int c) {
        a.add(b);
        a.add(c);
        a.add(super.getD());
    }

    public ArrayList<Integer> getA() {
        return a;
    }

    public void addA(int b) {
        a.add(b);
    }

    @Override
    public void hello() {
        System.out.println("hello");
    }
}

interface Test_interface {

    public void hello();
}

class Father {

    private int d = 2;

    public int getD() {
        return d;
    }
}
        """

        self.shared = """
        //可并发的类
        public class Hello implements Runnable {

    private int a = 1;

    private final String b = "ok";

    @Override
    public void run() {
        System.out.println(b + a);
        a++;
    }
}

class Use {

    public static void main(String[] args) {
        Hello hello = new Hello();
        new Thread(hello).start();
        new Thread(hello).start();
    }
}
        """

        self.tong = """
        class ThreadTest {

    private int a;

    private int b;

    public ThreadTest(int a, int b) {
        this.a = a;
        this.b = b;
    }

    public int sum() {
        return a + b;
    }
}

//可并发的类
class Test extends Thread {

    private int tickets = 100;

    public void run() {
        //Synchronized block
        synchronized (new ThreadTest(1, 2)) {
            while (tickets > 0) {
                tickets--;
            }
        }
    }
}

//可并发的类
class Other implements Runnable {

    private int ok = 100;

    @Override
    public void run() {
        while (ok > 0) {
            ok--;
        }
    }
}
        """

