import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

public class TrafficLightProblem {

    public static void main(String[] args) {
        Intersection intersection = new Intersection();

        // 创建多个车辆线程
        for (int i = 1; i <= 10; i++) {
            Thread vehicleThread = new Thread(new VehicleClass(intersection, i), "Vehicle " + i);
            vehicleThread.start();
        }

        // 模拟交通灯变化
        for (int i = 0; i < 5; i++) {
            intersection.changeLight(); // 改变交通灯
            try {
                Thread.sleep(3000); // 模拟灯变化的时间间隔
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        // 中断所有车辆线程
        for (Thread thread : Thread.getAllStackTraces().keySet()) {
            if (thread.getName().startsWith("Vehicle")) {
                thread.interrupt();
            }
        }
    }

    // 交通路口类
    static class Intersection {
        private AtomicBoolean greenLight = new AtomicBoolean(true); // 初始为绿灯
        private AtomicInteger waitingCount = new AtomicInteger(0); // 等待通行的车辆数量

        // 改变交通灯状态
        void changeLight() {
            greenLight.set(!greenLight.get());
            if (greenLight.get()) {
                System.out.println("Traffic light changes to green.");
            } else {
                System.out.println("Traffic light changes to red.");
            }
            synchronized (this) {
                notifyAll(); // 唤醒所有等待的车辆
            }
        }

        // 判断交通灯是否为绿灯
        boolean isGreen() {
            return greenLight.get();
        }

        // 车辆等待通行
        synchronized void waitToPass() throws InterruptedException {
            waitingCount.incrementAndGet();
            while (!isGreen()) {
                wait(); // 等待绿灯
            }
            waitingCount.decrementAndGet();
        }

        // 获取等待通行的车辆数量
        int getWaitingCount() {
            return waitingCount.get();
        }
    }

    // 车辆类
    static class VehicleClass implements Runnable {
        private Intersection intersection;
        private int vehicleId;

        VehicleClass(Intersection intersection, int vehicleId) {
            this.intersection = intersection;
            this.vehicleId = vehicleId;
        }

        @Override
        public void run() {
            while (!Thread.interrupted()) {
                try {
                    Thread.sleep(1000); // 模拟车辆行驶时间

                    intersection.waitToPass(); // 车辆等待通行

                    System.out.println("Vehicle " + vehicleId + " passes the traffic light.");
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt(); // 重新设置中断标志
                }
            }
        }
    }
}
