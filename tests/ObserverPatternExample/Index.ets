interface Observer {
    update(message: string): void;
}

interface Subject {
    registerObserver(observer: Observer): void;
    removeObserver(observer: Observer): void;
    notifyObservers(message: string): void;
}

class ConcreteSubject implements Subject {
    private readonly lock = new Object();
    private readonly observers: Observer[] = new Array(10);
    private size = 0;

    registerObserver(observer: Observer): void {
        synchronized(this.lock, () => {
            this.synchronizeMethod1();
        });
    }

    removeObserver(observer: Observer): void {
        synchronized(this.lock, () => {
            this.synchronizeMethod2();
        });
    }

    notifyObservers(message: string): void {
        let snapshot: Observer[];
        synchronized(this.lock, () => {
            this.synchronizeMethod3();
            snapshot = [...this.observers];
        });
        for (const observer of snapshot) {
            if (observer != null) {
                new Thread(() => observer.update(message)).start();
            }
        }
    }

    stateChanged(newState: string): void {
        console.log(`Subject state changed to: ${newState}`);
        this.notifyObservers(newState);
    }

    private synchronizeMethod1(): void {
        // Implementation of synchronized method 1
    }

    private synchronizeMethod2(): void {
        // Implementation of synchronized method 2
    }

    private synchronizeMethod3(): void {
        // Implementation of synchronized method 3
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
        const observer1 = new ConcreteObserver('Observer 1');
        const observer2 = new ConcreteObserver('Observer 2');
        subject.registerObserver(observer1);
        subject.registerObserver(observer2);
        subject.stateChanged('New state!');
        subject.removeObserver(observer1);
        subject.stateChanged('Another new state!');
    }
}

ObserverPatternExample.main();