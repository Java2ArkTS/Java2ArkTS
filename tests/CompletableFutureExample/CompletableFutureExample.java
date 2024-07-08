public class CompletableFutureExample {
    /**
     * 任务 1：洗水壶 -> 烧开水
     */
    private String task1() {
        System.out.println("T1: 1");
        for(int i = 0; i < 1000; i++);
        System.out.println("T1: 2");
        for(int i = 0; i < 1000; i++);
        return null;
    }

    /**
     * 任务 2：洗茶壶 -> 洗茶杯 -> 拿茶叶
     */
    private String task2() {
        System.out.println("T2: 1");
        for(int i = 0; i < 1000; i++);

        System.out.println("T2: 2");
        for(int i = 0; i < 1000; i++);

        System.out.println("T2: 3");
        for(int i = 0; i < 1000; i++);
        return " 龙井 ";
    }

    /**
     * 任务 3：任务 1 和任务 2 完成后执行：泡茶
     */
    private String task3(String tea) {
        System.out.println("T1: 1" + tea);
        System.out.println("T1: 2");
        return " 上茶:" + tea;
    }

    public static void main(String[] args) {
        CompletableFutureExample example = new CompletableFutureExample();

        Thread t1 = new Thread(() -> {
            example.task1();
        });

        final String[] tea = new String[1];
        Thread t2 = new Thread(() -> {
            tea[0] = example.task2();
        });

        t1.start();
        t2.start();

        String result = example.task3(tea[0]);
        //System.out.println(result);
    }

    /**
     * 描述串行关系
     */
    static class SerialRelation {
        private static String task1() {
            return "Hello World";
        }

        private static String task2(String s) {
            return s + " QQ";
        }

        private static String task3(String s) {
            return s.toUpperCase();
        }

        public static void main(String[] args) {
            String result = task1();
            result = task2(result);
            result = task3(result);
            //System.out.println(result);
        }
    }

    /**
     * 描述汇聚Or关系
     */
    static class ConvergeRelation {
        private static String task1() {
            int t = getRandom(5, 10);
            for(int i = 0; i < 1000; i++);
            return String.valueOf(t);
        }

        private static String task2() {
            int t = getRandom(5, 10);
            for(int i = 0; i < 1000; i++);
            return String.valueOf(t);
        }

        private static int getRandom(int i, int j) {
            return (int) (Math.random() * (j - i)) + i;
        }

        public static void main(String[] args) {
            String result1 = task1();
            String result2 = task2();
            String result = result1 != null ? result1 : result2;
            //System.out.println(result);
        }
    }

    /**
     * 处理异常
     */
    static class ExceptionHandler {
        private static int task() {
            try {
                return 7 / 0;
            } catch (ArithmeticException e) {
                return 0;
            }
        }

        private static int task2(int r) {
            return r * 10;
        }

        public static void main(String[] args) {
            int result = task();
            result = task2(result);
            //System.out.println(result);
        }
    }
}
