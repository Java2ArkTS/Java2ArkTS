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
    Thread
} from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
    let archetype: Runnable;
    if (runnable.className == "A") {
        archetype = new A(new Semaphores());
    } else if (runnable.className == "B") {
        archetype = new B(new Semaphores());
    } else {
        archetype = new Thread();
    }
    addFunc(runnable, archetype);
    runnable.run();
}

class LetterBox {

    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "LetterBox";

    public static main(args: string[]): void {
        const semaphores = new Semaphores();
        const a = new Thread(new A(semaphores));
        const b = new Thread(new B(semaphores));
        a.start();
        b.start();
    }
}

class Semaphores {

    public fullA = new SharedNumber(1);
    public emptyA = new SharedNumber(2);
    public fullB = new SharedNumber(2);
    public emptyB = new SharedNumber(3);
    public mutexA = new SharedBoolean(true);
    public mutexB = new SharedBoolean(true);
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "Semaphores";

    public pFullA(): boolean {
        SynStart(this.syn);
        if (this.fullA.getValue() > 0) {
            this.fullA.setValue(this.fullA.getValue() - 1);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    public pEmptyA(): boolean {
        SynStart(this.syn);
        if (this.emptyA.getValue() > 0) {
            this.emptyA.setValue(this.emptyA.getValue() - 1);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    public pFullB(): boolean {
        SynStart(this.syn);
        if (this.fullB.getValue() > 0) {
            this.fullB.setValue(this.fullB.getValue() - 1);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    public pEmptyB(): boolean {
        SynStart(this.syn);
        if (this.emptyB.getValue() > 0) {
            this.emptyB.setValue(this.emptyB.getValue() - 1);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    public pMutexA(): boolean {
        SynStart(this.syn);
        if (this.mutexA.getValue()) {
            this.mutexA.setValue(false);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    public pMutexB(): boolean {
        SynStart(this.syn);
        if (this.mutexB.getValue()) {
            this.mutexB.setValue(false);
            SynEnd(this.syn);
            return true;
        } else {
            SynEnd(this.syn);
            return false;
        }
    }

    public vFullA(): void {
        SynStart(this.syn);
        this.fullA.setValue(this.fullA.getValue() + 1);
        SynEnd(this.syn);
    }

    public vEmptyA(): void {
        SynStart(this.syn);
        this.emptyA.setValue(this.emptyA.getValue() + 1);
        SynEnd(this.syn);
    }

    public vFullB(): void {
        SynStart(this.syn);
        this.fullB.setValue(this.fullB.getValue() + 1);
        SynEnd(this.syn);
    }

    public vEmptyB(): void {
        SynStart(this.syn);
        this.emptyB.setValue(this.emptyB.getValue() + 1);
        SynEnd(this.syn);
    }

    public vMutexA(): void {
        SynStart(this.syn);
        this.mutexA.setValue(true);
        SynEnd(this.syn);
    }

    public vMutexB(): void {
        SynStart(this.syn);
        this.mutexB.setValue(true);
        SynEnd(this.syn);
    }
}

class A implements Runnable {

    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "A";

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    public run(): void {
        while (true) {
            while (!this.semaphores.pFullA()) {
            }
            while (!this.semaphores.pMutexA()) {
            }
            console.log("A gets a letter from email box A.");
            this.semaphores.vMutexA();
            this.semaphores.vEmptyA();
            console.log("A answers the question and raises a new question.");
            while (!this.semaphores.pEmptyB()) {
            }
            while (!this.semaphores.pMutexB()) {
            }
            console.log("A puts the new letter into email box B.");
            this.semaphores.vMutexB();
            this.semaphores.vFullB();
        }
    }
}

class B implements Runnable {

    public semaphores: Semaphores;
    public syn: Syc = new Syc();
    public static staticSyn: Syc = new Syc();
    public className: string = "B";

    constructor(semaphores: Semaphores) {
        this.semaphores = semaphores;
    }

    public run(): void {
        while (true) {
            while (!this.semaphores.pFullB()) {
            }
            while (!this.semaphores.pMutexB()) {
            }
            console.log("B gets a letter from email box B.");
            this.semaphores.vMutexB();
            this.semaphores.vEmptyB();
            console.log("B answers the question and raises a new question.");
            while (!this.semaphores.pEmptyA()) {
            }
            while (!this.semaphores.pMutexA()) {
            }
            console.log("B puts the new letter into email box A.");
            this.semaphores.vMutexA();
            this.semaphores.vFullA();
        }
    }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}