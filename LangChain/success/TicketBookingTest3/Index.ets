import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class TicketCounter {

    private ticketsAvailable: any = getClass('number', 20);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    public bookTicket(passengerName: string, numberOfTickets: number): void {
        SynStart(1, this.synArray);
        if (getValues(numberOfTickets) <= getValues(this.ticketsAvailable)) {
            setValues(this.ticketsAvailable, getValues(this.ticketsAvailable) - getValues(numberOfTickets));
            console.log(`${getValues(passengerName)} booked ${getValues(numberOfTickets)} ticket(s). Tickets left: ${getValues(this.ticketsAvailable)}`);
        } else {
            console.log(`Not enough tickets for ${getValues(passengerName)} to book ${getValues(numberOfTickets)} ticket(s). Tickets left: ${getValues(this.ticketsAvailable)}`);
        }
        SynEnd(1, this.synArray);
    }

    public getTicketsAvailable(): number {
        SynStart(2, this.synArray);
        const availableTickets = getValues(this.ticketsAvailable);
        SynEnd(2, this.synArray);
        return availableTickets;
    }
}

class TicketBookingTask implements Runnable {

    private ticketCounter: any = getClass('TicketCounter', new TicketCounter());
    private passengerName: any = getClass('string', "DefaultPassenger");
    private numberOfTickets: any = getClass('number', 1);
    public synArray: any = getSyc();
    public sharedType: string = "object";

    constructor(ticketCounter: TicketCounter, passengerName: string, numberOfTickets: number) {
        setValues(this.ticketCounter, ticketCounter);
        setValues(this.passengerName, passengerName);
        setValues(this.numberOfTickets, numberOfTickets);
    }

    run(): void {
        while (true) {
            getValues(this.ticketCounter.bookTicket(getValues(this.passengerName), getValues(this.numberOfTickets)));
        }
    }
}

class TicketBookingTest3 {

    public synArray: any = getSyc();
    public sharedType: string = "object";

    public static main(args: string[]): void {
        const ticketCounter = new TicketCounter();
        const thread1 = new Thread(new TicketBookingTask(ticketCounter, "Passenger1", 5));
        const thread2 = new Thread(new TicketBookingTask(ticketCounter, "Passenger2", 7));
        const thread3 = new Thread(new TicketBookingTask(ticketCounter, "Passenger3", 4));
        const thread4 = new Thread(new TicketBookingTask(ticketCounter, "Passenger4", 6));
        getValues(thread1.start());
        getValues(thread2.start());
        getValues(thread3.start());
        getValues(thread4.start());
    }
}
