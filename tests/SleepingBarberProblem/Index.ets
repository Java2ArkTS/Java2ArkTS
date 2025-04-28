import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class BarberShop {

    public synArray: any = getSyc();
    public sharedType: string = "object";
    private readonly chairs: any = getClass('number');
    private sleeping: any = getClass('boolean', true);
    private cutting: any = getClass('boolean', false);
    private waiting: any = getClass('number', 0);

    constructor(chairs: number) {
        setValues(this.chairs, getValues(chairs));
        setValues(this.sleeping, true);
        setValues(this.cutting, false);
        setValues(this.waiting, 0);
    }

    async customerArrived(customerId: number) {
        SynStart(getValues(this['synArray']));
        while (getValues(this.waiting) === getValues(this.chairs) || getValues(this.cutting)) {
            console.log("No free chairs or barber is busy, customer " + customerId + " leaves.");
            await wait(getValues(this['synArray']));
        }
        setValues(this.waiting, getValues(this.waiting) + 1);
        console.log("Customer " + customerId + " sits in the waiting room.");
        if (getValues(this.sleeping)) {
            console.log("Barber wakes up.");
            setValues(this.sleeping, false);
        }
        setValues(this.waiting, getValues(this.waiting) - 1);
        console.log("Customer " + customerId + " is having a haircut.");
        SynEnd(getValues(this['synArray']));
    }

    startCutting() {
        SynStart(getValues(this['synArray']));
        setValues(this.cutting, true);
        console.log("Barber starts cutting hair.");
        SynEnd(getValues(this['synArray']));
    }

    finishCutting() {
        SynStart(getValues(this['synArray']));
        setValues(this.cutting, false);
        console.log("Barber finishes cutting hair.");
        notify(getValues(this['synArray']));
        SynEnd(getValues(this['synArray']));
    }

    async sleep() {
        SynStart(getValues(this['synArray']));
        console.log("Barber goes to sleep.");
        setValues(this.sleeping, true);
        while (getValues(this.waiting) === 0) {
            await wait(getValues(this['synArray']));
        }
        console.log("Barber wakes up.");
        setValues(this.sleeping, false);
        SynEnd(getValues(this['synArray']));
    }
}

class Customer implements Runnable {

    private readonly barberShop: any = getClass('BarberShop', new BarberShop(3));
    private readonly customerId: any = getClass('number', 0);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(barberShop: BarberShop, customerId: number) {
        setValues(this.barberShop, barberShop);
        setValues(this.customerId, customerId);
    }

    run(): void {
        try {
            getValues(this.barberShop.customerArrived(getValues(this.customerId)));
            getValues(this.barberShop.startCutting());
            getValues(Thread.sleep(2000));
            getValues(this.barberShop.finishCutting());
        } catch (e) {
            if (e instanceof InterruptedException) {
                getValues(e.printStackTrace());
            }
        }
    }
}

class Barber implements Runnable {

    private barberShop: any = getClass('BarberShop', new BarberShop());
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(barberShop: BarberShop) {
        setValues(this.barberShop, barberShop);
    }

    run() {
        try {
            while (true) {
                getValues(this.barberShop.sleep());
                getValues(this.barberShop.startCutting());
                setTimeout(() => {
                    getValues(this.barberShop.finishCutting());
                }, 2000);
            }
        } catch (e) {
            console.error(e);
        }
    }
}

class SleepingBarberProblem {

    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(): void {
        const barberShop = new BarberShop(3);
        const barberThread = new Thread(new Barber(barberShop), 'Barber');
        barberThread.start();

        for (let i = 1; i <= 10; i++) {
            const customerThread = new Thread(new Customer(barberShop, i), 'Customer ' + i);
            customerThread.start();
        }
    }
}