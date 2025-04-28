// 观察者接口
interface Observer {
    void update(String message);
}

// 主题接口
interface Subject {
    void registerObserver(Observer observer);
    void removeObserver(Observer observer);
    void notifyObservers(String message);
}

// 具体主题类
class ConcreteSubject implements Subject {
    private final Object lock = new Object();
    private final Observer[] observers = new Observer[10]; // 最多支持10个观察者
    private int size = 0;

    @Override
    public void registerObserver(Observer observer) {
        synchronized (lock) {
            if (size < observers.length) {
                observers[size++] = observer;
            } else {
                System.out.println("Cannot register more observers.");
            }
        }
    }

    @Override
    public void removeObserver(Observer observer) {
        synchronized (lock) {
            for (int i = 0; i < size; i++) {
                if (observers[i] == observer) {
                    System.arraycopy(observers, i + 1, observers, i, size - i - 1);
                    observers[size - 1] = null;
                    size--;
                    break;
                }
            }
        }
    }

    @Override
    public void notifyObservers(String message) {
        Observer[] snapshot;
        synchronized (lock) {
            snapshot = observers.clone(); // 创建观察者数组的快照
        }
        for (Observer observer : snapshot) {
            if (observer != null) {
                new Thread(() -> observer.update(message)){}.start();
            }
        }
    }

    // 模拟状态变化，通知观察者
    public void stateChanged(String newState) {
        System.out.println("Subject state changed to: " + newState);
        notifyObservers(newState);
    }
}

// 具体观察者类
class ConcreteObserver implements Observer {
    private final String observerName;

    public ConcreteObserver(String name) {
        this.observerName = name;
    }

    @Override
    public void update(String message) {
        System.out.println(observerName + " received message: " + message);
    }
}

public class ObserverPatternExample {
    public static void main(String[] args) {
        ConcreteSubject subject = new ConcreteSubject();

        // 创建观察者
        ConcreteObserver observer1 = new ConcreteObserver("Observer 1");
        ConcreteObserver observer2 = new ConcreteObserver("Observer 2");

        // 注册观察者
        subject.registerObserver(observer1);
        subject.registerObserver(observer2);

        // 改变状态，通知观察者
        subject.stateChanged("New state!");

        // 可选：移除一个观察者
        subject.removeObserver(observer1);

        // 再次改变状态，通知观察者
        subject.stateChanged("Another new state!");
    }
}
