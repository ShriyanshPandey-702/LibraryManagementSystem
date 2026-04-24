package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import model.IssueRecord;
import util.DBConnection;

public class IssueDAO {

    public static class IssueResult {
        private final boolean success;
        private final String message;

        public IssueResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }
    }

    public boolean issueBook(int bookId, int studentId, String studentName, String studentContact,
                             String course, String year, String section, String dueDate) {

        return issueBookWithDetails(bookId, studentId, studentName, studentContact, course, year, section, dueDate).isSuccess();
    }

    public IssueResult issueBookWithDetails(int bookId, int studentId, String studentName, String studentContact,
                                            String course, String year, String section, String dueDate) {

        if (dueDate == null || dueDate.trim().isEmpty()) {
            return new IssueResult(false, "Due date is required.");
        }

        String verifyBookSql = "SELECT id FROM books WHERE id=?";
        String verifyStudentSql = "SELECT id FROM students WHERE id=?";
        String reserveCopySql = "UPDATE books SET quantity = quantity - 1 WHERE id=? AND quantity > 0";
        String insertSql = "INSERT INTO issue_books(book_id,student_id,student_name,student_contact,course,`year`,section,issue_date,due_date,fine,returned,status) "
            + "VALUES(?,?,?,?,?,?,?,CURDATE(),?,0,0,'Issued')";

        Date parsedDueDate;
        try {
            parsedDueDate = Date.valueOf(dueDate);
        } catch (Exception e) {
            return new IssueResult(false, "Invalid due date format.");
        }

        try (Connection con = DBConnection.getConnection()) {

            if (con == null) {
                return new IssueResult(false, "Database connection failed.");
            }

            con.setAutoCommit(false);

            try (PreparedStatement ps1 = con.prepareStatement(verifyBookSql)) {
                ps1.setInt(1, bookId);

                try (ResultSet rs = ps1.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return new IssueResult(false, "Selected book not found.");
                    }
                }
            }

            try (PreparedStatement ps1 = con.prepareStatement(verifyStudentSql)) {
                ps1.setInt(1, studentId);

                try (ResultSet rs = ps1.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return new IssueResult(false, "Selected student not found.");
                    }
                }
            }

            int reservedRows;
            try (PreparedStatement ps2 = con.prepareStatement(reserveCopySql)) {
                ps2.setInt(1, bookId);
                reservedRows = ps2.executeUpdate();
            }

            if (reservedRows <= 0) {
                con.rollback();
                return new IssueResult(false, "Book is not available for issue.");
            }

            int insertedRows;
            try (PreparedStatement ps3 = con.prepareStatement(insertSql)) {
                ps3.setInt(1, bookId);
                ps3.setInt(2, studentId);
                ps3.setString(3, studentName);
                ps3.setString(4, studentContact);
                ps3.setString(5, course);
                ps3.setString(6, year);
                ps3.setString(7, section);
                ps3.setDate(8, parsedDueDate);
                insertedRows = ps3.executeUpdate();
            }

            if (insertedRows <= 0) {
                con.rollback();
                return new IssueResult(false, "Issue transaction failed.");
            }

            con.commit();
            return new IssueResult(true, "Book issued successfully");

        } catch (SQLException e) {
            e.printStackTrace();
            String message = e.getMessage();
            if (message != null && message.length() > 150) {
                message = message.substring(0, 150);
            }
            return new IssueResult(false, "Database error while issuing book" + (message == null ? "." : (": " + message)));
        } catch (Exception e) {
            e.printStackTrace();
            return new IssueResult(false, "Unexpected error while issuing book.");
        }
    }

    public List<IssueRecord> getActiveIssues() {

        List<IssueRecord> list = new ArrayList<>();

        String sql =
        "SELECT ib.id, ib.book_id, b.title, ib.student_name, ib.student_contact, ib.issue_date, ib.due_date, ib.return_date, ib.fine, ib.status " +
        "FROM issue_books ib JOIN books b ON ib.book_id=b.id " +
        "WHERE ib.status='Issued' ORDER BY ib.id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            double finePerDay = getFinePerDay(con);

            while (rs.next()) {

                IssueRecord r = new IssueRecord();

                r.setIssueId(rs.getInt("id"));
                r.setBookId(rs.getInt("book_id"));
                r.setBookTitle(rs.getString("title"));
                r.setStudentName(rs.getString("student_name"));
                r.setStudentContact(rs.getString("student_contact"));
                r.setIssueDate(rs.getDate("issue_date"));
                r.setDueDate(rs.getDate("due_date"));
                String status = rs.getString("status");
                r.setFine(calculateDynamicFine(rs.getDate("due_date"), rs.getDate("return_date"), status, rs.getDouble("fine"), finePerDay));
                r.setStatus(status);

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public double returnBook(int issueId) {

        String getSql = "SELECT book_id, due_date FROM issue_books WHERE id=? AND status='Issued'";
        String updateIssue = "UPDATE issue_books SET status='Returned', return_date=CURDATE(), returned=1, fine=? WHERE id=?";
        String updateBook = "UPDATE books SET quantity=quantity+1 WHERE id=?";

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            int bookId = 0;
            double fine = 0;

            PreparedStatement ps1 = con.prepareStatement(getSql);
            ps1.setInt(1, issueId);

            ResultSet rs = ps1.executeQuery();

            if (rs.next()) {
                bookId = rs.getInt("book_id");

                Date dueDate = rs.getDate("due_date");
                LocalDate today = LocalDate.now();
                LocalDate due = dueDate.toLocalDate();

                long lateDays = java.time.temporal.ChronoUnit.DAYS.between(due, today);
                if (lateDays < 0) {
                    lateDays = 0;
                }

                double finePerDay = getFinePerDay(con);

                fine = lateDays * finePerDay;
            } else {
                con.rollback();
                return -1;
            }

            PreparedStatement ps2 = con.prepareStatement(updateIssue);
            ps2.setDouble(1, fine);
            ps2.setInt(2, issueId);
            ps2.executeUpdate();

            PreparedStatement ps3 = con.prepareStatement(updateBook);
            ps3.setInt(1, bookId);
            ps3.executeUpdate();

            con.commit();
            return fine;

        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    public int getTotalIssuedBooks() {

        String sql = "SELECT COUNT(*) FROM issue_books WHERE status='Issued'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<IssueRecord> getIssuesByStudentContact(String studentContact) {
        List<IssueRecord> list = new ArrayList<>();

        String sql = "SELECT ib.id, ib.book_id, b.title, ib.student_name, ib.student_contact, ib.issue_date, ib.due_date, ib.return_date, ib.fine, ib.status "
                + "FROM issue_books ib JOIN books b ON ib.book_id = b.id "
                + "WHERE ib.student_contact = ? ORDER BY ib.id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            double finePerDay = getFinePerDay(con);

            ps.setString(1, studentContact);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    IssueRecord record = new IssueRecord();
                    record.setIssueId(rs.getInt("id"));
                    record.setBookId(rs.getInt("book_id"));
                    record.setBookTitle(rs.getString("title"));
                    record.setStudentName(rs.getString("student_name"));
                    record.setStudentContact(rs.getString("student_contact"));
                    record.setIssueDate(rs.getDate("issue_date"));
                    record.setDueDate(rs.getDate("due_date"));
                    record.setReturnDate(rs.getDate("return_date"));
                    String status = rs.getString("status");
                    record.setFine(calculateDynamicFine(rs.getDate("due_date"), rs.getDate("return_date"), status, rs.getDouble("fine"), finePerDay));
                    record.setStatus(status);
                    list.add(record);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int getStudentActiveBorrowedCount(int studentId) {
        String sql = "SELECT COUNT(*) FROM issue_books WHERE student_id = ? AND status = 'Issued'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getStudentTotalFine(int studentId) {
        String sql = "SELECT id, due_date, return_date, fine, status FROM issue_books WHERE student_id = ?";
        double totalFine = 0;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            double finePerDay = getFinePerDay(con);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    totalFine += calculateDynamicFine(rs.getDate("due_date"), rs.getDate("return_date"), rs.getString("status"), rs.getDouble("fine"), finePerDay);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return totalFine;
    }

    public List<IssueRecord> getIssuesByStudentId(int studentId) {
        List<IssueRecord> list = new ArrayList<>();

        String sql = "SELECT ib.id, ib.book_id, b.title, ib.student_name, ib.student_contact, ib.issue_date, ib.due_date, ib.return_date, ib.fine, ib.status "
                + "FROM issue_books ib JOIN books b ON ib.book_id = b.id "
                + "WHERE ib.student_id = ? ORDER BY ib.id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            double finePerDay = getFinePerDay(con);

            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    IssueRecord record = new IssueRecord();
                    record.setIssueId(rs.getInt("id"));
                    record.setBookId(rs.getInt("book_id"));
                    record.setBookTitle(rs.getString("title"));
                    record.setStudentName(rs.getString("student_name"));
                    record.setStudentContact(rs.getString("student_contact"));
                    record.setIssueDate(rs.getDate("issue_date"));
                    record.setDueDate(rs.getDate("due_date"));
                    record.setReturnDate(rs.getDate("return_date"));
                    String status = rs.getString("status");
                    record.setFine(calculateDynamicFine(rs.getDate("due_date"), rs.getDate("return_date"), status, rs.getDouble("fine"), finePerDay));
                    record.setStatus(status);
                    list.add(record);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private double getFinePerDay(Connection con) {
        String sql = "SELECT fine_per_day FROM fine_settings WHERE id=1";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getDouble("fine_per_day");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 5.0;
    }

    private double calculateDynamicFine(Date dueDate, Date returnDate, String status, double storedFine, double finePerDay) {
        if (dueDate == null) {
            return storedFine;
        }

        if (!"Issued".equalsIgnoreCase(status)) {
            return storedFine;
        }

        LocalDate today = LocalDate.now();
        LocalDate due = dueDate.toLocalDate();
        long lateDays = java.time.temporal.ChronoUnit.DAYS.between(due, today);
        if (lateDays < 0) {
            lateDays = 0;
        }

        double dynamicFine = lateDays * finePerDay;
        return Math.max(dynamicFine, storedFine);
    }
}