class TicketCounter {
    private int ticketsAvailable = 20;

    public synchronized void bookTicket(String passengerName, int numberOfTickets) {
        if (numberOfTickets <= ticketsAvailable) {
            ticketsAvailable -= numberOfTickets;
            System.out.println(passengerName + " booked " + numberOfTickets + " ticket(s). Tickets left: " + ticketsAvailable);
        } else {
            System.out.println("Not enough tickets for " + passengerName + " to book " + numberOfTickets + " ticket(s). Tickets left: " + ticketsAvailable);
        }
    }

    public synchronized int getTicketsAvailable() {
        return ticketsAvailable;
    }
}

class TicketBookingTask implements Runnable {
    private TicketCounter ticketCounter;
    private String passengerName;
    private int numberOfTickets;

    public TicketBookingTask(TicketCounter ticketCounter, String passengerName, int numberOfTickets) {
        this.ticketCounter = ticketCounter;
        this.passengerName = passengerName;
        this.numberOfTickets = numberOfTickets;
    }

    @Override
    public void run() {
        while(1){
            ticketCounter.bookTicket(passengerName, numberOfTickets);
        }
    }
}

public class TicketBookingTest3 {
    public static void main(String[] args) {
        TicketCounter ticketCounter = new TicketCounter();

        Thread thread1 = new Thread(new TicketBookingTask(ticketCounter, "Passenger1", 5));
        Thread thread2 = new Thread(new TicketBookingTask(ticketCounter, "Passenger2", 7));
        Thread thread3 = new Thread(new TicketBookingTask(ticketCounter, "Passenger3", 4));
        Thread thread4 = new Thread(new TicketBookingTask(ticketCounter, "Passenger4", 6));

        thread1.start();
        thread2.start();
        thread3.start();
        thread4.start();
    }
}