class TicketCounter {
    private int ticketsAvailable = 10;

    public synchronized void bookTicket() {
        if (ticketsAvailable > 0) {
            ticketsAvailable--;
            System.out.println(" booked a ticket. Tickets left: " + ticketsAvailable);
        } else {
            System.out.println("No tickets available for ");
        }
    }
}

class TicketBookingTask implements Runnable {
    private TicketCounter ticketCounter;

    public TicketBookingTask(TicketCounter ticketCounter) {
        this.ticketCounter = ticketCounter;
    }

    @Override
    public void run() {
        ticketCounter.bookTicket();
    }
}

public class TicketBookingTest {
    public static void main(String[] args) {
        TicketCounter ticketCounter = new TicketCounter();
        Thread thread1 = new Thread(new TicketBookingTask(ticketCounter));
        Thread thread2 = new Thread(new TicketBookingTask(ticketCounter));
        Thread thread3 = new Thread(new TicketBookingTask(ticketCounter));

        thread1.start();
        thread2.start();
        thread3.start();
    }
}
