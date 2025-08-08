class WrongCounterDemo {
  private static readonly INC_COUNT = 100000000;
  private counter = 0;

  public static async main() {
    const demo = new WrongCounterDemo();
    console.log("Start task thread!");
    const thread1 = new Promise<void>((resolve) => {
      const task = demo.getConcurrencyCheckTask();
      task().then(resolve);
    });
    const thread2 = new Promise<void>((resolve) => {
      const task = demo.getConcurrencyCheckTask();
      task().then(resolve);
    });
    await Promise.all([thread1, thread2]);
    const actualCounter = demo.counter;
    const expectedCount = WrongCounterDemo.INC_COUNT * 2;
    if (actualCounter !== expectedCount) {
      console.error(`Error! Got wrong count!! actual ${actualCounter}, expected: ${expectedCount}.`);
    } else {
      console.log("Wow... Got right count!");
    }
  }

  getConcurrencyCheckTask() {
    return async () => {
      for (let i = 0; i < WrongCounterDemo.INC_COUNT; ++i) {
        ++this.counter;
      }
    };
  }
}

WrongCounterDemo.main();

if (isMainThread()) {
  // You can put the entry of your code here to test.
}