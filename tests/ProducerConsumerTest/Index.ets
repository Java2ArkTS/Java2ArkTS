import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == "Producer") {
    archetype = new Producer(new SharedBuffer());
  } else if (runnable.className == "Consumer") {
    archetype = new Consumer(new SharedBuffer());
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class SharedBuffer {
  private data: number;
  private isEmpty = new SharedBoolean(true);
  
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "SharedBuffer";
  
  public produce(newData: number): void {
    {
      SynStart(this.syn);
      this.data = newData;
      this.isEmpty.setValue(false);
      console.log("Produced: " + this.data);
      SynEnd(this.syn);
    }
  }
  
  public consume(): number {
    {
      SynStart(this.syn);
      if (!this.isEmpty.getValue()) {
        console.log("Consumed: " + this.data);
        this.isEmpty.setValue(true);
      }
      SynEnd(this.syn);
      return this.data;
    }
  }
}

class Producer implements Runnable {
  private buffer: SharedBuffer;
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Producer";
  
  constructor(buffer: SharedBuffer) {
    this.buffer = buffer;
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      this.buffer.produce(i);
    }
  }
}

class Consumer implements Runnable {
  private buffer: SharedBuffer;
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "Consumer";
  
  constructor(buffer: SharedBuffer) {
    this.buffer = buffer;
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      this.buffer.consume();
    }
  }
}

class ProducerConsumerTest {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = "ProducerConsumerTest";

  static main(args: string[]): void {
    const buffer = new SharedBuffer();
    const producerThread = new Thread(new Producer(buffer));
    const consumerThread = new Thread(new Consumer(buffer));
    producerThread.start();
    consumerThread.start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}