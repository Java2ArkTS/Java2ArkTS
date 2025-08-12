class CompletableFutureExample {
    private task1(): string | null {
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
        return " 锟斤拷锟斤拷 ";
    }

    private task3(tea: string | undefined): string {
        console.log("T1: 1" + tea);
        console.log("T1: 2");
        return " 锟较诧拷:" + tea;
    }

    public static main(): void {
        const example = new CompletableFutureExample();
        const tea: string[] = [""];
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
        let result = this.task1();
        result = this.task2(result);
        result = this.task3(result);
    }
}

class ConvergeRelation {
    private static task1(): string {
        const t = this.getRandom(5, 10);
        for (let i = 0; i < 1000; i++);
        return t.toString();
    }

    private static task2(): string {
        const t = this.getRandom(5, 10);
        for (let i = 0; i < 1000; i++);
        return t.toString();
    }

    private static getRandom(i: number, j: number): number {
        return Math.floor(Math.random() * (j - i)) + i;
    }

    public static main(): void {
        const result1 = this.task1();
        const result2 = this.task2();
        const result = result1 !== null ? result1 : result2;
    }
}

class ExceptionHandler {
    private static task(): number {
        try {
            return 7 / 0;
        } catch (e) {
            if (e instanceof Error) {
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

    public start(): void {
        setTimeout(this.runnable, 0);
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}