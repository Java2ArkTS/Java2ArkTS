class SimpleFuture {
    private result: string | null = null;
    private isDone: boolean = false;

    constructor() {
        this.isDone = false;
    }

    public setResult(result: string): void {
        this.result = result;
        this.isDone = true;
    }

    public get(): string {
        while (!this.isDone) {
            // Busy-waiting
        }
        return this.result!;
    }

    public isDoneMethod(): boolean {
        return this.isDone;
    }
}

const future = new SimpleFuture();
const asyncTask = new Promise<void>((resolve) => {
    setTimeout(() => {
        for (let i = 0; i < 1000; i++) {}
        future.setResult("Task completed");
        resolve();
    }, 0);
});

console.log("Doing something else...");
asyncTask.then(() => {
    const result = future.get();
    console.log("Result: " + result);
});

if (isMainThread()) {
  // You can put the entry of your code here to test.
}