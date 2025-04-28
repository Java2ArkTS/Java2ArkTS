class WrongCounterDemo {

    private static readonly INC_COUNT = 100000000;

    private counter = 0;

    public static async main() {
        const demo = new WrongCounterDemo();
        console.log("Start task thread!");

        const thread1 = new ConcurrencyCheckTask(demo);
        const thread2 = new ConcurrencyCheckTask(demo);

        await Promise.all([thread1.start(), thread2.start()]);

        const actualCounter = demo.counter;
        const expectedCount = WrongCounterDemo.INC_COUNT * 2;

        if (actualCounter !== expectedCount) {
            console.error(`Fuck! Got wrong count!! actual ${actualCounter}, expected: ${expectedCount}.`);
        } else {
            console.log("Wow... Got right count!");
        }
    }

    public incrementCounter() {
        this.counter++;
    }
}

class ConcurrencyCheckTask {
    private demo: WrongCounterDemo;

    constructor(demo: WrongCounterDemo) {
        this.demo = demo;
    }

    public async start() {
        for (let i = 0; i < WrongCounterDemo.INC_COUNT; ++i) {
            this.demo.incrementCounter();
        }
    }
}

// Invoke the main method
WrongCounterDemo.main().catch(console.error);