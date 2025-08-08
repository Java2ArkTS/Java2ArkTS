class CompletableFutureExample {
    private task1(): string {
        console.log("T1: 1");
        for (let i = 0; i < 1000; i++);
        console.log("T1: 2");
        for (let i = 0; i < 1000; i++);
        return null;
    }

    private task2(): string {
        console.log("T2: 1");
        for (let i = 0; i < 1000; i++);
        console.log("T2: 2");
        for (let i = 0; i < 1000; i++);
        console.log("T2: 3");
        for (let i = 0; i < 1000; i++);
        return " 龙井 ";
    }

    private task3(tea: string): string {
        console.log("T1: 1" + tea);
        console.log("T1: 2");
        return " 上茶:" + tea;
    }

    public static main(): void {
        const example = new CompletableFutureExample();
        const tea: string[] = [null];
        const t1 = new Thread(() => {
            example.task1();
        });
        const t2 = new Thread(() => {
            tea[0] = example.task2();
        });
        t1.start();
        t2.start();
        const result = example.task3(tea[0]);
    }
}

class SerialRelation {
    private static task1(): string {
        return "Hello World";
    }

    private static task2(s: string): string {
        return s + " QQ";
    }

    private static task3(s: string): string {
        return s.toUpperCase();
    }

    public static main(): void {
        let result = SerialRelation.task1();
        result = SerialRelation.task2(result);
        result = SerialRelation.task3(result);
    }
}

class ConvergeRelation {
    private static task1(): string {
        const t = ConvergeRelation.getRandom(5, 10);
        for (let i = 0; i < 1000; i++);
        return String(t);
    }

    private static task2(): string {
        const t = ConvergeRelation.getRandom(5, 10);
        for (let i = 0; i < 1000; i++);
        return String(t);
    }

    private static getRandom(i: number, j: number): number {
        return Math.floor(Math.random() * (j - i)) + i;
    }

    public static main(): void {
        const result1 = ConvergeRelation.task1();
        const result2 = ConvergeRelation.task2();
        const result = result1 !== null ? result1 : result2;
    }
}

class ExceptionHandler {
    private static task(): number {
        try {
            return 7 / 0;
        } catch (e) {
            return 0;
        }
    }

    private static task2(r: number): number {
        return r * 10;
    }

    public static main(): void {
        let result = ExceptionHandler.task();
        result = ExceptionHandler.task2(result);
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}