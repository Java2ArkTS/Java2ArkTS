public class DiningPhilosophers {
    public static void main(String[] args) {
        Mutexes mutexes = new Mutexes();
        Thread thread0 = new Thread(new Pi(mutexes, 0));
        Thread thread1 = new Thread(new Pi(mutexes, 1));
        Thread thread2 = new Thread(new Pi(mutexes, 2));
        Thread thread3 = new Thread(new Pi(mutexes, 3));
        Thread thread4 = new Thread(new Pi(mutexes, 4));
        thread0.start();
        thread1.start();
        thread2.start();
        thread3.start();
        thread4.start();
    }
}

class Mutexes {
    public boolean[] chopsticks = { true, true, true, true, true };

    public synchronized boolean getLeftChopstick(int i) {
        if (chopsticks[i]) {
            chopsticks[i] = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean getRightChopstick(int i) {
        if (chopsticks[(i + 1) % 5]) {
            chopsticks[(i + 1) % 5] = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void returnChopsticks(int i) {
        chopsticks[i] = true;
        chopsticks[(i + 1) % 5] = true;
    }
}

class Pi implements Runnable {
    public Mutexes mutexes;
    public int i;

    public Pi(Mutexes mutexes, int i) {
        this.mutexes = mutexes;
        this.i = i;
    }

    public void run() {
        while (true) {
            this.mutexes.getLeftChopstick(i);
            this.mutexes.getRightChopstick(i);
            System.out.println("P" + i + " is eating.");
            this.mutexes.returnChopsticks(i);
            System.out.println("P" + i + " is thinking.");
        }
    }
}