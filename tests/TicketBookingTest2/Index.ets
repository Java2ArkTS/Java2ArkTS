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
  Thread,
} from './ThreadBridge';

export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className === 'TicketBookingTask') {
    archetype = new TicketBookingTask(new TicketCounter(), 'DefaultPassenger', 1);
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class TicketCounter {
  private ticketsAvailable = new SharedNumber(20);
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'TicketCounter';

  public bookTicket(passengerName: string, numberOfTickets: number): void {
    SynStart(this.syn);
    if (numberOfTickets <= this.ticketsAvailable.getValue()) {
      this.ticketsAvailable.setValue(this.ticketsAvailable.getValue() - numberOfTickets);
      console.log(
        `${passengerName} booked ${numberOfTickets} ticket(s). Tickets left: ${this.ticketsAvailable.getValue()}`
      );
    } else {
      console.log(
        `Not enough tickets for ${passengerName} to book ${numberOfTickets} ticket(s). Tickets left: ${this.ticketsAvailable.getValue()}`
      );
    }
    SynEnd(this.syn);
  }

  public getTicketsAvailable(): number {
    SynStart(this.syn);
    const availableTickets = this.ticketsAvailable.getValue();
    SynEnd(this.syn);
    return availableTickets;
  }
}

class TicketBookingTask implements Runnable {
  private ticketCounter: TicketCounter;
  private passengerName = new SharedString();
  private numberOfTickets = new SharedNumber();
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'TicketBookingTask';

  constructor(ticketCounter: TicketCounter, passengerName: string, numberOfTickets: number) {
    this.ticketCounter = ticketCounter;
    this.passengerName.setValue(passengerName);
    this.numberOfTickets.setValue(numberOfTickets);
  }

  run(): void {
    this.ticketCounter.bookTicket(this.passengerName.getValue(), this.numberOfTickets.getValue());
  }
}

class TicketBookingTest2 {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'TicketBookingTest2';

  public static main(args: string[]): void {
    const ticketCounter = new TicketCounter();
    const thread1 = new Thread(new TicketBookingTask(ticketCounter, 'Passenger1', 5));
    const thread2 = new Thread(new TicketBookingTask(ticketCounter, 'Passenger2', 7));
    const thread3 = new Thread(new TicketBookingTask(ticketCounter, 'Passenger3', 4));
    const thread4 = new Thread(new TicketBookingTask(ticketCounter, 'Passenger4', 6));
    thread1.start();
    thread2.start();
    thread3.start();
    thread4.start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}