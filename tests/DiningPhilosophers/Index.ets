import {
  SynStart,
  SynEnd,
  SharedBoolean,
  SharedNumber,
  Syc,
  addFunc,
  Runnable,
  Thread,
  isMainThread,
} from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className === 'DiningPhilosophers') {
    archetype = new DiningPhilosophers();
  } else if (runnable.className === 'Pi') {
    archetype = new Pi(new Mutexes(), 0); // Default Mutexes and index for instantiation
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

export class DiningPhilosophers implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'DiningPhilosophers';

  public run(): void {
    DiningPhilosophers.main([]);
  }

  public static main(args: string[]): void {
    const mutexes = new Mutexes();
    const thread0 = new Thread(new Pi(mutexes, 0));
    const thread1 = new Thread(new Pi(mutexes, 1));
    const thread2 = new Thread(new Pi(mutexes, 2));
    const thread3 = new Thread(new Pi(mutexes, 3));
    const thread4 = new Thread(new Pi(mutexes, 4));
    thread0.start();
    thread1.start();
    thread2.start();
    thread3.start();
    thread4.start();
  }
}

class Mutexes {
  public chopsticks = [
    new SharedBoolean(true),
    new SharedBoolean(true),
    new SharedBoolean(true),
    new SharedBoolean(true),
    new SharedBoolean(true),
  ];
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Mutexes';

  public getLeftChopstick(i: number): boolean {
    SynStart(this.syn);
    if (this.chopsticks[i].getValue()) {
      this.chopsticks[i].setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public getRightChopstick(i: number): boolean {
    SynStart(this.syn);
    if (this.chopsticks[(i + 1) % 5].getValue()) {
      this.chopsticks[(i + 1) % 5].setValue(false);
      SynEnd(this.syn);
      return true;
    } else {
      SynEnd(this.syn);
      return false;
    }
  }

  public returnChopsticks(i: number): void {
    SynStart(this.syn);
    this.chopsticks[i].setValue(true);
    this.chopsticks[(i + 1) % 5].setValue(true);
    SynEnd(this.syn);
  }
}

class Pi implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'Pi';

  public mutexes: Mutexes;

  public i = new SharedNumber();

  constructor(mutexes: Mutexes, i: number) {
    this.mutexes = mutexes;
    this.i.setValue(i);
  }

  public run(): void {
    while (true) {
      this.mutexes.getLeftChopstick(this.i.getValue());
      this.mutexes.getRightChopstick(this.i.getValue());
      console.log('P' + this.i.getValue() + ' is eating.');
      this.mutexes.returnChopsticks(this.i.getValue());
      console.log('P' + this.i.getValue() + ' is thinking.');
    }
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}