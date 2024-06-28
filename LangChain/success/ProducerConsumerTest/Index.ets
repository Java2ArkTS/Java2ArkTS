import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class SharedBuffer {
  private data: any = getClass('number', 0);
  private isEmpty: any = getClass('boolean', true);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public produce(newData: number): void {
    SynStart(1, this.synArray);
    setValues(this.data, newData);
    setValues(this.isEmpty, false);
    console.log("Produced: " + getValues(this.data));
    SynEnd(1, this.synArray);
  }

  public consume(): number {
    SynStart(2, this.synArray);
    if (!getValues(this.isEmpty)) {
      console.log("Consumed: " + getValues(this.data));
      setValues(this.isEmpty, true);
    }
    SynEnd(2, this.synArray);
    return getValues(this.data);
  }
}

class Producer implements Runnable {
  private buffer: SharedBuffer = getClass('SharedBuffer', new SharedBuffer());
  public synArray: any = getSyc();
  public sharedType: string = "object";

  constructor(buffer: SharedBuffer) {
    setValues(this.buffer, buffer);
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      getValues(this.buffer.produce(i));
    }
  }
}

class Consumer implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  private buffer: SharedBuffer = getClass('SharedBuffer', new SharedBuffer());

  constructor(buffer: SharedBuffer) {
    setValues(this.buffer, buffer);
  }

  run(): void {
    for (let i = 0; i < 10; i++) {
      getValues(this.buffer.consume());
    }
  }
}

class ProducerConsumerTest {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const buffer = new SharedBuffer();
    const producerThread = new Thread(new Producer(buffer));
    const consumerThread = new Thread(new Consumer(buffer));
    producerThread.start();
    consumerThread.start();
  }
}