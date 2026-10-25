package model;

import java.sql.Date;

public class BookCopy {
    private int id;
    private int bookId;
    private String bookTitle;
    private int copyNumber;
    private String barcodeId;
    private String status; // 'Available', 'Borrowed', 'Reserved', 'Lost', 'Damaged', 'Under Repair', 'Withdrawn'
    private String conditionNotes;
    private Date acquisitionDate;

    public BookCopy() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }

    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }

    public int getCopyNumber() { return copyNumber; }
    public void setCopyNumber(int copyNumber) { this.copyNumber = copyNumber; }

    public String getBarcodeId() { return barcodeId; }
    public void setBarcodeId(String barcodeId) { this.barcodeId = barcodeId; }

    public String getBarcode() { return barcodeId; }
    public void setBarcode(String barcode) { this.barcodeId = barcode; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getConditionNotes() { return conditionNotes; }
    public void setConditionNotes(String conditionNotes) { this.conditionNotes = conditionNotes; }

    public Date getAcquisitionDate() { return acquisitionDate; }
    public void setAcquisitionDate(Date acquisitionDate) { this.acquisitionDate = acquisitionDate; }

    public Date getCreatedAt() { return acquisitionDate; }
    public void setCreatedAt(Date createdAt) { this.acquisitionDate = createdAt; }
}
