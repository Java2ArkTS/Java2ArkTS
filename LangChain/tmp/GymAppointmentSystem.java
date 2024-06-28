class Gym {
    private int availableSpots = 10; // 健身中心初始有10个可用位置

    // 预约位置
    public synchronized void bookSpot(){
        while (availableSpots <= 0) {
            ;
        }
        availableSpots--; // 预约一个位置
        System.out.println(" has booked a spot. Spots available: " + availableSpots);
    }

    // 取消预约
    public synchronized void cancelSpot() {
        if (availableSpots < 10) {
            availableSpots++; // 取消预约，增加一个位置
            System.out.println(" has cancelled a spot. Spots available: " + availableSpots);
        }
    }
}

class GymMember implements Runnable {
    private Gym gym;
    private boolean book;

    public GymMember(Gym gym, boolean book) {
        this.gym = gym;
        this.book = book;
    }

    @Override
    public void run() {
        if (book) {
            gym.bookSpot();
            for(int i=0;i<1000000;i++); // 模拟健身时间
            gym.cancelSpot();
        }
    }
}

public class GymAppointmentSystem {
    public static void main(String[] args) {
        Gym gym = new Gym();

        // 创建多个会员线程
        Thread member1 = new Thread(new GymMember(gym, true));
        Thread member2 = new Thread(new GymMember(gym, true));
        Thread member3 = new Thread(new GymMember(gym, false)); // 这个会员只取消预约

        member1.start();
        member2.start();
        member3.start();
    }
}