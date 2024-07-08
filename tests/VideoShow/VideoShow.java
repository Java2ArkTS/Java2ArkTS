/*
 * Suppose a video hall has 1, 2, 3 different video films 
 * that can be selected by the audience. 
 * The screening rules of the video hall are as follows:
 * 1. A maximum of one video film can be shown at any given time. 
 * The current video film is played in an automatic loop 
 * until the last member of the audience voluntarily leaves.
 * 2. Viewers who choose the current video film playing can enter immediately, 
 * allowing multiple viewers who choose the same video to watch at the same time, 
 * and the number of viewers watching at the same time is unlimited.
 * 3. The audience waiting to watch other video films will line up in the order of arrival. 
 * When a new video film starts to be shown, 
 * all the audience waiting to watch that video film can enter the video hall 
 * in the order to watch it at the same time.
 * Use a process to represent an audience.
 */

public class VideoShow {
    public static void main(String[] args) {
        Semaphores semaphores = new Semaphores();
        Thread show1 = new Thread(new VideoShow1(semaphores));
        Thread show2 = new Thread(new VideoShow2(semaphores));
        Thread show3 = new Thread(new VideoShow3(semaphores));
        show1.start();
        show2.start();
        show3.start();
    }
}

class Semaphores {
    public boolean s = true;
    public boolean s0 = true;
    public boolean s1 = true;
    public boolean s2 = true;
    public int count0 = 0;
    public int count1 = 0;
    public int count2 = 0;

    public synchronized boolean ps() {
        if (s) {
            s = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean ps0() {
        if (s0) {
            s0 = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean ps1() {
        if (s1) {
            s1 = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized boolean ps2() {
        if (s2) {
            s2 = false;
            return true;
        } else {
            return false;
        }
    }

    public synchronized void vs() {
        s = true;
    }

    public synchronized void vs0() {
        s0 = true;
    }

    public synchronized void vs1() {
        s1 = true;
    }

    public synchronized void vs2() {
        s2 = true;
    }
}

class VideoShow1 implements Runnable {
    public Semaphores semaphores;

    public VideoShow1(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (!semaphores.ps0()) {
        }
        semaphores.count0++;
        if (semaphores.count0 == 1) {
            while (!semaphores.ps()) {
            }
        }
        semaphores.vs0();
        System.out.println("Video show 1 begins.");
        while (!semaphores.ps0()) {
        }
        semaphores.count0--;
        if (semaphores.count0 == 0) {
            System.out.println("Video show 1 ends.");
            semaphores.vs();
        }
        semaphores.vs0();
    }
}

class VideoShow2 implements Runnable {
    public Semaphores semaphores;

    public VideoShow2(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (!semaphores.ps1()) {
        }
        semaphores.count1++;
        if (semaphores.count1 == 1) {
            while (!semaphores.ps()) {
            }
        }
        semaphores.vs1();
        System.out.println("Video show 2 begins.");
        while (!semaphores.ps1()) {
        }
        semaphores.count1--;
        if (semaphores.count1 == 0) {
            System.out.println("Video show 2 ends.");
            semaphores.vs();
        }
        semaphores.vs1();
    }
}

class VideoShow3 implements Runnable {
    public Semaphores semaphores;

    public VideoShow3(Semaphores semaphores) {
        this.semaphores = semaphores;
    }

    public void run() {
        while (!semaphores.ps2()) {
        }
        semaphores.count2++;
        if (semaphores.count2 == 1) {
            while (!semaphores.ps()) {
            }
        }
        semaphores.vs2();
        System.out.println("Video show 3 begins.");
        while (!semaphores.ps2()) {
        }
        semaphores.count2--;
        if (semaphores.count2 == 0) {
            System.out.println("Video show 3 ends.");
            semaphores.vs();
        }
        semaphores.vs2();
    }
}