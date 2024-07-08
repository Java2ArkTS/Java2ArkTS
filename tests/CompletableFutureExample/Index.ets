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
        return " ???? ";
    }

    private task3(tea: string): string {
        console.log("T1: 1" + tea);
        console.log("T1: 2");
        return " ???:" + tea;
    }

    public static main(): void {
        let example = new CompletableFutureExample();
        let t1 = new Thread(() => {
            example.task1();
        });
        let tea = [null];
        let t2 = new Thread(() => {
            tea[0] = example.task2();
        });
        t1.start();
        t2.start();
        try {
            t1.join();
            t2.join();
        } catch (e) {
            console.error(e);
        }
        let result = example.task3(tea[0]);
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
        let result = this.task1();
        result = this.task2(result);
        result = this.task3(result);
    }
}

class ConvergeRelation {
    private static task1(): string {
        let t = this.getRandom(5, 10);
        for (let i = 0; i < 1000; i++);
        return String(t);
    }

    private static task2(): string {
        let t = this.getRandom(5, 10);
        for (let i = 0; i < 1000; i++);
        return String(t);
    }

    private static getRandom(i: number, j: number): number {
        return Math.floor(Math.random() * (j - i)) + i;
    }

    public static main(): void {
        let result1 = this.task1();
        let result2 = this.task2();
        let result = result1 != null ? result1 : result2;
    }
}

class ExceptionHandler {

    private static task(): number {
        try {
            return 7 / 0;
        } catch (e) {
            if (e instanceof ArithmeticException) {
                return 0;
            }
            throw e;
        }
    }

    private static task2(r: number): number {
        return r * 10;
    }

    public static main(): void {
        let result = this.task();
        result = this.task2(result);
    }
}

class Thread {
    private runnable: () => void;

    constructor(runnable: () => void) {
        this.runnable = runnable;
    }

    start(): void {
        setTimeout(this.runnable, 0);
    }

    join(): void {
        // TypeScript/JavaScript does not provide a direct join() equivalent
        // Use promise or other synchronizing techniques in real implementation
    }
}

// Simulate static main method calls
CompletableFutureExample.main();
SerialRelation.main();
ConvergeRelation.main();
ExceptionHandler.main();