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
    archetype = new TicketBookingTask(new TicketCounter());
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}

class TicketCounter {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'TicketCounter';

  private ticketsAvailable = new SharedNumber(10);

  public bookTicket(): void {
    {
      SynStart(this.syn);
      if (this.ticketsAvailable.getValue() > 0) {
        this.ticketsAvailable.setValue(this.ticketsAvailable.getValue() - 1);
        console.log(
          ' booked a ticket. Tickets left: ' + this.ticketsAvailable.getValue()
        );
      } else {
        console.log('No tickets available for ');
      }
      SynEnd(this.syn);
    }
  }
}

class TicketBookingTask implements Runnable {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'TicketBookingTask';

  private ticketCounter: TicketCounter;

  constructor(ticketCounter: TicketCounter) {
    this.ticketCounter = ticketCounter;
  }

  run(): void {
    this.ticketCounter.bookTicket();
  }
}

export class TicketBookingTest {
  public syn: Syc = new Syc();
  public static staticSyn: Syc = new Syc();
  public className: string = 'TicketBookingTest';

  public static main(args: string[]): void {
    const ticketCounter = new TicketCounter();
    const thread1 = new Thread(new TicketBookingTask(ticketCounter));
    const thread2 = new Thread(new TicketBookingTask(ticketCounter));
    const thread3 = new Thread(new TicketBookingTask(ticketCounter));
    thread1.start();
    thread2.start();
    thread3.start();
  }
}

if (isMainThread()) {
  // You can put the entry of your code here to test.
}