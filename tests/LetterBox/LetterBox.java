/*
 * There are two people, A and B, debating through the mailbox, 
 * each taking the other's question from their own mailbox. 
 * Put the answers and new questions in an email in their inbox. 
 * Assume that A's mailbox stores a maximum of M emails, 
 * and B's mailbox stores a maximum of N emails. 
 * At the beginning, x emails are in the mailbox of A 
 * and y emails are in the mailbox of B. 
 * Each time the debater takes out a message, 
 * the number of messages is reduced by one. 
 * When the mailbox is not empty, the debater can get the mail from the mailbox, 
 * otherwise wait. 
 * When the mailbox is not satisfied, the debater can put a new mail into the mailbox, 
 * otherwise wait. 
 * Synchronize A and B.
 */

public class LetterBox {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread a = new Thread(new A(semaphores));
        Thread b = new Thread(new B(semaphores));
        a.start();
        b.start();
    }
}

class Semaphores {
    public int fullA = 1; // x
    public int emptyA = 2; // M - x = 3 - 1 = 2
    public int fullB = 2; // y
    public int emptyB = 3; // N - y = 5 - 2 = 3
    public boolean mutexA = true;
    public boolean mutexB = true;

    public synchronized boolean pFullA() {
        if (fullA > 0) {
            fullA--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean pEmptyA() {
        if (emptyA > 0) {
            emptyA--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean pFullB() {
        if (fullB > 0) {
            fullB--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean pEmptyB() {
        if (emptyB > 0) {
            emptyB--;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean pMutexA() {
        if (mutexA) {
            mutexA = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean pMutexB() {
        if (mutexB) {
            mutexB = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void vFullA() {
        fullA++;
    }

    public synchronized void vEmptyA() {
        emptyA++;
    }

    public synchronized void vFullB() {
        fullB++;
    }

    public synchronized void vEmptyB() {
        emptyB++;
    }

    public synchronized void vMutexA() {
        mutexA = true;
    }

    public synchronized void vMutexB() {
        mutexB = true;
    }
}

class A implements Runnable {
    public Semaphores semaphores;

    public A(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.pFullA()) {
            }
            while (!semaphores.pMutexA()) {
            }
            System.out.println("A gets a letter from email box A.");
            semaphores.vMutexA();
            semaphores.vEmptyA();
            System.out.println("A answers the question and raises a new question.");
            while (!semaphores.pEmptyB()) {
            }
            while (!semaphores.pMutexB()) {
            }
            System.out.println("A puts the new letter into email box B.");
            semaphores.vMutexB();
            semaphores.vFullB();
        }
    }
}

class B implements Runnable {
    public Semaphores semaphores;

    public B(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (true) {
            while (!semaphores.pFullB()) {
            }
            while (!semaphores.pMutexB()) {
            }
            System.out.println("B gets a letter from email box B.");
            semaphores.vMutexB();
            semaphores.vEmptyB();
            System.out.println("B answers the question and raises a new question.");
            while (!semaphores.pEmptyA()) {
            }
            while (!semaphores.pMutexA()) {
            }
            System.out.println("B puts the new letter into email box A.");
            semaphores.vMutexA();
            semaphores.vFullA();
        }
    }
}