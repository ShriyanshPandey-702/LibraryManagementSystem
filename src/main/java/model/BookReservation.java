package model;

import java.sql.Date;
import java.sql.Timestamp;

public class BookReservation {
    private int id;
    private int bookId;
    private String bookTitle;
    private int studentId;
    private String studentName;
    private Timestamp reservationDate;
    private String status; // 'Waiting', 'Ready for Pickup', 'Fulfilled', 'Cancelled', 'Expired'
    private Date pickupDeadline;
    private int queuePosition;
    private boolean notified;

    public BookReservation() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }

    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public Timestamp getReservationDate() { return reservationDate; }
    public void setReservationDate(Timestamp reservationDate) { this.reservationDate = reservationDate; }

    public Timestamp getCreatedAt() { return reservationDate; }
    public void setCreatedAt(Timestamp createdAt) { this.reservationDate = createdAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getPickupDeadline() { return pickupDeadline; }
    public void setPickupDeadline(Date pickupDeadline) { this.pickupDeadline = pickupDeadline; }

    public Date getExpiryDate() { return pickupDeadline; }
    public void setExpiryDate(Date expiryDate) { this.pickupDeadline = expiryDate; }

    public int getQueuePosition() { return queuePosition; }
    public void setQueuePosition(int queuePosition) { this.queuePosition = queuePosition; }

    public boolean isNotified() { return notified; }
    public void setNotified(boolean notified) { this.notified = notified; }
}
