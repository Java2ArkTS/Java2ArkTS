class Tickets{
    private int num = 100;
    public int getNum(){
        return this.num;
    }
    public void sale(){
        this.num--;
    }
}

class TestThread implements Runnable {
    private Tickets tickets = new Tickets();
    private int count = 0;
    public void run() {
        while (true) {
            sale();
        }
    }
    public synchronized void sale() {
        if (tickets.getNum() > 0) {
            System.out.println("is sailing ticket" + tickets.getNum());
            count = count + 1;
            tickets.sale();
        }
    }
}

public class Shared {
    public static void main(String[] args) {
        TestThread tt = new TestThread();
        new Thread(tt).start();
        new Thread(tt).start();
        new Thread(tt).start();
        new Thread(tt).start();
    }
}