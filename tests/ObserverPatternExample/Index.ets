import { isMainThread, SynStart, SynEnd, Syc } from "@kit.ArkTS";

interface Observer {
    update(message: string): void;
}

interface Subject {
    registerObserver(observer: Observer): void;
    removeObserver(observer: Observer): void;
    notifyObservers(message: string): void;
}

class ConcreteSubject implements Subject {
    private readonly lock = new Syc();
    private readonly observers: Observer[] = [];
    private size = 0;

    registerObserver(observer: Observer): void {
        SynStart(this.lock);
        this.synchronizeMethod1(observer);
        SynEnd(this.lock);
    }

    removeObserver(observer: Observer): void {
        SynStart(this.lock);
        this.synchronizeMethod2(observer);
        SynEnd(this.lock);
    }

    notifyObservers(message: string): void {
        let snapshot: Observer[];
        SynStart(this.lock);
        snapshot = [...this.observers];
        SynEnd(this.lock);
        for (const observer of snapshot) {
            if (observer) {
                setTimeout(() => observer.update(message), 0);
            }
        }
    }

    stateChanged(newState: string): void {
        console.log(`Subject state changed to: ${newState}`);
        this.notifyObservers(newState);
    }

    private synchronizeMethod1(observer: Observer): void {
        this.observers.push(observer);
        this.size++;
    }

    private synchronizeMethod2(observer: Observer): void {
        const index = this.observers.indexOf(observer);
        if (index !== -1) {
            this.observers.splice(index, 1);
            this.size--;
        }
    }
}

class ConcreteObserver implements Observer {
    private readonly observerName: string;

    constructor(name: string) {
        this.observerName = name;
    }

    update(message: string): void {
        console.log(`${this.observerName} received message: ${message}`);
    }
}

class ObserverPatternExample {
    static main(): void {
        const subject = new ConcreteSubject();
        const observer1 = new ConcreteObserver("Observer 1");
        const observer2 = new ConcreteObserver("Observer 2");
        subject.registerObserver(observer1);
        subject.registerObserver(observer2);
        subject.stateChanged("New state!");
        subject.removeObserver(observer1);
        subject.stateChanged("Another new state!");
    }
}

ObserverPatternExample.main();

if (isMainThread()) {
    // You can put the entry of your code here to test.
}