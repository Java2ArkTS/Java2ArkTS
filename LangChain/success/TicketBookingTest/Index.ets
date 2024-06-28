import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

class TicketCounter {
  private ticketsAvailable: any = getClass('number', 10);
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public bookTicket(): void {
    {
      SynStart(1, this.synArray);
      if (getValues(this.ticketsAvailable) > 0) {
        setValues(this.ticketsAvailable, getValues(this.ticketsAvailable) - 1);
        console.log(" booked a ticket. Tickets left: " + getValues(this.ticketsAvailable));
      } else {
        console.log("No tickets available for ");
      }
      SynEnd(1, this.synArray);
    }
  }
}

class TicketBookingTask implements Runnable {
  public synArray: any = getSyc();
  public sharedType: string = "object";
  private ticketCounter: any = getClass('TicketCounter', new TicketCounter());

  constructor(ticketCounter: TicketCounter) {
    setValues(this.ticketCounter, ticketCounter);
  }

  run(): void {
    getValues(this.ticketCounter.bookTicket());
  }
}

class TicketBookingTest {
  public synArray: any = getSyc();
  public sharedType: string = "object";

  public static main(args: string[]): void {
    const ticketCounter = new TicketCounter();
    const thread1 = new Thread(new TicketBookingTask(ticketCounter));
    const thread2 = new Thread(new TicketBookingTask(ticketCounter));
    const thread3 = new Thread(new TicketBookingTask(ticketCounter));
    getValues(thread1.start());
    getValues(thread2.start());
    getValues(thread3.start());
  }
}