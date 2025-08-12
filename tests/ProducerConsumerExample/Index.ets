import {
  SynStart,
  SynEnd,
  wait,
  notify,
  SharedBoolean,
  SharedString,
  SharedNumber,
  Syc,
  isMainThread,
  addFunc,
  Runnable,
  Thread,
} from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className === 'Producer') {
    archetype = new Producer(new CustomBlockingQueue(5));
  } else if (runnable.className === 'Consumer') {
    archetype = new Consumer(new CustomBlockingQueue(5));
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

import { SynStart, SynEnd, wait, notify, Syc } from './ThreadBridge';
import { SharedNumber } from './SharedTypes';

class CustomBlockingQueue {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'CustomBlockingQueue';

  private queue: number[];
  private size = new SharedNumber(0);
  private capacity = new SharedNumber();
  private front = new SharedNumber(0);
  private rear = new SharedNumber(-1);
  private readonly synchronized_object: Syc = new Syc();

  constructor(capacity: number) {
    this.queue = new Array(capacity);
    this.capacity.setValue(capacity);
  }

  public async put(item: number): Promise<void> {
    SynStart(this.synchronized_object.syn);
    while (this.size.getValue() === this.capacity.getValue()) {
      await wait(this.synchronized_object.syn);
    }
    this.rear.setValue((this.rear.getValue() + 1) % this.capacity.getValue());
    this.queue[this.rear.getValue()] = item;
    console.log('producer: ' + item);
    this.size.setValue(this.size.getValue() + 1);
    notify(this.synchronized_object.syn);
    SynEnd(this.synchronized_object.syn);
  }

  public async take(): Promise<number> {
    SynStart(this.synchronized_object.syn);
    while (this.size.getValue() === 0) {
      await wait(this.synchronized_object.syn);
    }
    const item = this.queue[this.front.getValue()];
    this.front.setValue((this.front.getValue() + 1) % this.capacity.getValue());
    this.size.setValue(this.size.getValue() - 1);
    console.log('consumer: ' + item);
    notify(this.synchronized_object.syn);
    SynEnd(this.synchronized_object.syn);
    return item;
  }
}

class Producer implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Producer';

  private queue: CustomBlockingQueue;

  constructor(queue: CustomBlockingQueue) {
    this.queue = queue;
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      try {
        this.queue.put(i);
        for (let j = 0; j < 10; j++) {}
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
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Consumer';

  private queue: CustomBlockingQueue;

  constructor(queue: CustomBlockingQueue) {
    this.queue = queue;
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      try {
        const item = this.queue.take();
        for (let j = 0; j < 5; j++) {}
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
  public className: string = 'ProducerConsumerExample';

  static main(args: string[]): void {
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