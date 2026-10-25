package model;

import java.sql.Date;
import java.sql.Timestamp;

public class IssueRecord {

    private int issueId;
    private int bookId;
    private String bookTitle;
    private String bookAuthor;
    private String bookIsbn;
    private String bookCoverImage;
    private String studentName;
    private String studentContact;
    private int studentId;
    private Date issueDate;
    private Date dueDate;
    private Date returnDate;
    private double fine;
    private String status;
    private boolean finePaid;
    private int renewCount;

    // Issue confirmation tracking
    private Date requestDate;
    private Timestamp adminIssuedAt;
    private Timestamp confirmedAt;
    private String rejectionReason;

    // ── Getters & Setters ──────────────────────────────────────────

    public int getIssueId() { return issueId; }
    public void setIssueId(int issueId) { this.issueId = issueId; }

    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }

    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }

    public String getBookAuthor() { return bookAuthor; }
    public void setBookAuthor(String bookAuthor) { this.bookAuthor = bookAuthor; }

    public String getBookIsbn() { return bookIsbn; }
    public void setBookIsbn(String bookIsbn) { this.bookIsbn = bookIsbn; }

    public String getBookCoverImage() { return bookCoverImage; }
    public void setBookCoverImage(String bookCoverImage) { this.bookCoverImage = bookCoverImage; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentContact() { return studentContact; }
    public void setStudentContact(String studentContact) { this.studentContact = studentContact; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public Date getIssueDate() { return issueDate; }
    public void setIssueDate(Date issueDate) { this.issueDate = issueDate; }

    public Date getReturnDate() { return returnDate; }
    public void setReturnDate(Date returnDate) { this.returnDate = returnDate; }

    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }

    public double getFine() { return fine; }
    public void setFine(double fine) { this.fine = fine; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isFinePaid() { return finePaid; }
    public void setFinePaid(boolean finePaid) { this.finePaid = finePaid; }

    public int getRenewCount() { return renewCount; }
    public void setRenewCount(int renewCount) { this.renewCount = renewCount; }

    public Date getRequestDate() { return requestDate; }
    public void setRequestDate(Date requestDate) { this.requestDate = requestDate; }

    public Timestamp getAdminIssuedAt() { return adminIssuedAt; }
    public void setAdminIssuedAt(Timestamp adminIssuedAt) { this.adminIssuedAt = adminIssuedAt; }

    public Timestamp getConfirmedAt() { return confirmedAt; }
    public void setConfirmedAt(Timestamp confirmedAt) { this.confirmedAt = confirmedAt; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    /** Helper: days borrowed between issue_date and return_date (or today if still issued) */
    public long getDaysBorrowed() {
        if (issueDate == null) return 0;
        java.time.LocalDate start = issueDate.toLocalDate();
        java.time.LocalDate end = (returnDate != null) ? returnDate.toLocalDate() : java.time.LocalDate.now();
        return java.time.temporal.ChronoUnit.DAYS.between(start, end);
    }
}
