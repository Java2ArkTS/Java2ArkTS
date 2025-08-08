class SimpleFuture {
    private result: string | null = null;
    private isDone: boolean = false;

    constructor() {
        this.isDone = false;
    }

    setResult(result: string): void {
        this.result = result;
        this.isDone = true;
    }

    get(): string | null {
        while (!this.isDone) {
            // Busy wait
        }
        return this.result;
    }

    checkIsDone(): boolean {
        return this.isDone;
    }
}

const future = new SimpleFuture();
const asyncTask = new Promise<void>((resolve) => {
    for (let i = 0; i < 1000; i++);
    future.setResult("Task completed");
    resolve();
});

asyncTask.then(() => {
    console.log("Doing something else...");
    const result = future.get();
    console.log("Result: " + result);
});

if (isMainThread()) {
  // You can put the entry of your code here to test.
}