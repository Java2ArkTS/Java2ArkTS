import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "Producer") {
    archetype = new Producer(new CustomBlockingQueue(5));
  } else if (runnable.className == "Consumer") {
    archetype = new Consumer(new CustomBlockingQueue(5));
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class CustomBlockingQueue {
  private queue: number[];
  private size = new SharedNumber(0);
  private capacity = new SharedNumber(0);
  private front = new SharedNumber(0);
  private rear = new SharedNumber(-1);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "CustomBlockingQueue";

  constructor(capacity: number) {
    this.queue = new Array(capacity);
    this.size.setValue(0);
    this.capacity.setValue(capacity);
    this.front.setValue(0);
    this.rear.setValue(-1);
  }

  async put(item: number): Promise<void> {
    SynStart(this.syn);
    while (this.size.getValue() === this.capacity.getValue()) {
      await wait(this.syn);
    }
    this.rear.setValue((this.rear.getValue() + 1) % this.capacity.getValue());
    this.queue[this.rear.getValue()] = item;
    this.size.setValue(this.size.getValue() + 1);
    console.log("producer: " + item);
    notify(this.syn);
    SynEnd(this.syn);
  }

  async take(): Promise<number> {
    SynStart(this.syn);
    while (this.size.getValue() === 0) {
      await wait(this.syn);
    }
    const item = this.queue[this.front.getValue()];
    this.front.setValue((this.front.getValue() + 1) % this.capacity.getValue());
    this.size.setValue(this.size.getValue() - 1);
    console.log("cpmstumer: " + item);
    notify(this.syn);
    SynEnd(this.syn);
    return item;
  }
}

class Producer implements Runnable {
  private queue: CustomBlockingQueue;
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Producer";

  constructor(queue: CustomBlockingQueue) {
    this.queue = queue;
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      try {
        this.queue.put(i);
        for (let j = 0; j < 10; j++) {
        }
      } catch (e) {
        if (e instanceof InterruptedException) {
          Thread.currentThread().interrupt();
          return;
        }
      }
    }
  }
}

class Consumer implements Runnable {
  private queue: CustomBlockingQueue;
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Consumer";

  constructor(queue: CustomBlockingQueue) {
    this.queue = queue;
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      try {
        const item = this.queue.take();
        for (let j = 0; j < 5; j++) {
        }
      } catch (e) {
        if (e instanceof InterruptedException) {
          Thread.currentThread().interrupt();
          return;
        }
      }
    }
  }
}

class ProducerConsumerExample {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "ProducerConsumerExample";

  public static main(args: string[]): void {
    const queue = new CustomBlockingQueue(5);
    const producer = new Producer(queue);
    const consumer = new Consumer(queue);
    const producerThread = new Thread(producer);
    const consumerThread = new Thread(consumer);
    producerThread.start();
    consumerThread.start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}