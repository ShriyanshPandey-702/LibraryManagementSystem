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

    public static final int MAX_BORROW_LIMIT = 3;

    public int getMaxBorrowLimit() {
        return new SettingsDAO().getIntSetting("max_books_per_student", MAX_BORROW_LIMIT);
    }

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
        return issueBookWithDetails(bookId, studentId, studentName, studentContact, course, year, section, dueDate, 0);
    }

    public IssueResult issueBookWithDetails(int bookId, int studentId, String studentName, String studentContact,
                                            String course, String year, String section, String dueDate, int requestId) {

        if (dueDate == null || dueDate.trim().isEmpty()) {
            return new IssueResult(false, "Due date is required.");
        }

        String verifyBookSql = "SELECT id, title FROM books WHERE id=? AND is_deleted=0";
        String verifyStudentSql = "SELECT id, name, email FROM students WHERE id=?";
        String countActiveSql = "SELECT COUNT(*) FROM issue_books WHERE student_id=? AND status IN ('Issued', 'Pending')";
        String reserveCopySql = "UPDATE books SET quantity = quantity - 1 WHERE id=? AND quantity > 0 AND is_deleted=0";
        String getReqDateSql = "SELECT request_date FROM book_requests WHERE id=?";
        String insertSql = "INSERT INTO issue_books(book_id, student_id, student_name, student_contact, course, `year`, section, issue_date, due_date, fine, returned, status, fine_paid, renew_count, admin_issued_at, request_date) "
            + "VALUES(?,?,?,?,?,?,?,CURDATE(),?,0,0,'Pending',0,0,CURRENT_TIMESTAMP,?)";

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

            String bookTitle = "Book";
            try (PreparedStatement ps1 = con.prepareStatement(verifyBookSql)) {
                ps1.setInt(1, bookId);
                try (ResultSet rs = ps1.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return new IssueResult(false, "Selected book not found or has been deleted.");
                    }
                    bookTitle = rs.getString("title");
                }
            }

            String realStudentName = studentName;
            try (PreparedStatement ps1 = con.prepareStatement(verifyStudentSql)) {
                ps1.setInt(1, studentId);
                try (ResultSet rs = ps1.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return new IssueResult(false, "Selected student not found.");
                    }
                    if (realStudentName == null || realStudentName.trim().isEmpty()) {
                        realStudentName = rs.getString("name");
                    }
                }
            }

            // Quota check: limit to configured active + pending books
            int maxLimit = getMaxBorrowLimit();
            try (PreparedStatement psCount = con.prepareStatement(countActiveSql)) {
                psCount.setInt(1, studentId);
                try (ResultSet rsCount = psCount.executeQuery()) {
                    if (rsCount.next() && rsCount.getInt(1) >= maxLimit) {
                        con.rollback();
                        return new IssueResult(false, "Student has reached maximum loan limit (" + maxLimit + " books, including pending confirmations). Please return a book first.");
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
                return new IssueResult(false, "Book is not available for issue (zero stock).");
            }

            Date reqDate = new Date(System.currentTimeMillis());
            if (requestId > 0) {
                try (PreparedStatement psReq = con.prepareStatement(getReqDateSql)) {
                    psReq.setInt(1, requestId);
                    try (ResultSet rsReq = psReq.executeQuery()) {
                        if (rsReq.next() && rsReq.getDate("request_date") != null) {
                            reqDate = rsReq.getDate("request_date");
                        }
                    }
                }
            }

            int insertedRows;
            try (PreparedStatement ps3 = con.prepareStatement(insertSql)) {
                ps3.setInt(1, bookId);
                ps3.setInt(2, studentId);
                ps3.setString(3, realStudentName);
                ps3.setString(4, studentContact);
                ps3.setString(5, course);
                ps3.setString(6, year);
                ps3.setString(7, section);
                ps3.setDate(8, parsedDueDate);
                ps3.setDate(9, reqDate);
                insertedRows = ps3.executeUpdate();
            }

            if (insertedRows <= 0) {
                con.rollback();
                return new IssueResult(false, "Issue transaction failed.");
            }

            con.commit();

            // Send confirmation request notification to the student
            new NotificationDAO().createNotification(new model.Notification(
                studentId, "student",
                "Book Issue Confirmation: " + bookTitle,
                "The library administration has assigned \"" + bookTitle + "\" to you. Please confirm whether you accept or reject this book loan.",
                "CONFIRMATION", "StudentIssuedBooksServlet"
            ));

            return new IssueResult(true, "Book issue request created successfully. Awaiting student confirmation.");

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

    public IssueResult acceptBookIssue(int issueId, int studentId) {
        String checkSql = "SELECT ib.id, ib.book_id, b.title, ib.student_name, ib.due_date " +
                          "FROM issue_books ib JOIN books b ON ib.book_id = b.id " +
                          "WHERE ib.id = ? AND ib.student_id = ? AND ib.status = 'Pending'";
        String updateSql = "UPDATE issue_books SET status = 'Issued', confirmed_at = CURRENT_TIMESTAMP, issue_date = CURDATE() WHERE id = ?";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return new IssueResult(false, "Database connection unavailable.");
            con.setAutoCommit(false);

            String bookTitle = "Book";
            String studentName = "Student";
            Date dueDate = null;

            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setInt(1, issueId);
                ps.setInt(2, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return new IssueResult(false, "Pending issue request not found or has already been processed.");
                    }
                    bookTitle = rs.getString("title");
                    studentName = rs.getString("student_name");
                    dueDate = rs.getDate("due_date");
                }
            }

            try (PreparedStatement ps2 = con.prepareStatement(updateSql)) {
                ps2.setInt(1, issueId);
                int rows = ps2.executeUpdate();
                if (rows <= 0) {
                    con.rollback();
                    return new IssueResult(false, "Failed to confirm book issue.");
                }
            }

            con.commit();

            // Send notification to Admin and Student
            NotificationDAO notifDAO = new NotificationDAO();
            notifDAO.notifyAdmins(
                "Book Issue Accepted: " + bookTitle,
                "Student " + studentName + " (ID #" + studentId + ") accepted the issue for \"" + bookTitle + "\". The book is now officially checked out.",
                "ACCEPT",
                "ReturnBookServlet"
            );
            notifDAO.createNotification(new model.Notification(
                studentId, "student",
                "Loan Confirmed: " + bookTitle,
                "You have accepted \"" + bookTitle + "\". It has been officially issued to your account. Due date: " + (dueDate != null ? dueDate.toString() : "Standard period") + ".",
                "CONFIRMATION",
                "StudentIssuedBooksServlet"
            ));

            return new IssueResult(true, "Book issue for \"" + bookTitle + "\" accepted successfully! It is now in your active borrowed books.");
        } catch (Exception e) {
            e.printStackTrace();
            return new IssueResult(false, "Error accepting book issue: " + e.getMessage());
        }
    }

    public IssueResult rejectBookIssue(int issueId, int studentId, String reason) {
        String checkSql = "SELECT ib.id, ib.book_id, b.title, ib.student_name " +
                          "FROM issue_books ib JOIN books b ON ib.book_id = b.id " +
                          "WHERE ib.id = ? AND ib.student_id = ? AND ib.status = 'Pending'";
        String updateIssue = "UPDATE issue_books SET status = 'Rejected', rejection_reason = ?, returned = 1, return_date = CURDATE() WHERE id = ?";
        String updateBook = "UPDATE books SET quantity = quantity + 1 WHERE id = ?";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return new IssueResult(false, "Database connection unavailable.");
            con.setAutoCommit(false);

            int bookId = 0;
            String bookTitle = "Book";
            String studentName = "Student";

            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setInt(1, issueId);
                ps.setInt(2, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        return new IssueResult(false, "Pending issue request not found or has already been processed.");
                    }
                    bookId = rs.getInt("book_id");
                    bookTitle = rs.getString("title");
                    studentName = rs.getString("student_name");
                }
            }

            String finalReason = (reason != null && !reason.trim().isEmpty()) ? reason.trim() : "Declined by student";

            try (PreparedStatement ps2 = con.prepareStatement(updateIssue)) {
                ps2.setString(1, finalReason);
                ps2.setInt(2, issueId);
                ps2.executeUpdate();
            }

            try (PreparedStatement ps3 = con.prepareStatement(updateBook)) {
                ps3.setInt(1, bookId);
                ps3.executeUpdate();
            }

            // Fulfill waiting reservations if any
            new ReservationDAO().checkAndFulfillWaitingReservation(con, bookId);

            con.commit();

            NotificationDAO notifDAO = new NotificationDAO();
            notifDAO.notifyAdmins(
                "Book Issue Rejected: " + bookTitle,
                "Student " + studentName + " (ID #" + studentId + ") rejected the issue for \"" + bookTitle + "\". Reason: " + finalReason + ". Book copy restored to catalog.",
                "REJECT",
                "IssueBookServlet"
            );
            notifDAO.createNotification(new model.Notification(
                studentId, "student",
                "Book Issue Declined: " + bookTitle,
                "You declined the issue for \"" + bookTitle + "\". The copy has been released.",
                "INFO",
                "StudentIssuedBooksServlet"
            ));

            return new IssueResult(true, "Book issue for \"" + bookTitle + "\" declined. The book has been made available to other students.");
        } catch (Exception e) {
            e.printStackTrace();
            return new IssueResult(false, "Error rejecting book issue: " + e.getMessage());
        }
    }

    public List<IssueRecord> getActiveIssues() {

        List<IssueRecord> list = new ArrayList<>();

        String sql =
        "SELECT ib.id, ib.book_id, COALESCE(b.title, 'Unavailable Title') as title, " +
        "COALESCE(b.author, 'Unknown Author') as author, COALESCE(b.isbn, '') as isbn, " +
        "b.cover_image, ib.student_id, ib.student_name, ib.student_contact, " +
        "ib.request_date, ib.admin_issued_at, ib.confirmed_at, ib.issue_date, " +
        "ib.due_date, ib.return_date, ib.fine, ib.status, ib.fine_paid, " +
        "ib.renew_count, ib.rejection_reason " +
        "FROM issue_books ib LEFT JOIN books b ON ib.book_id=b.id " +
        "WHERE ib.status='Issued' ORDER BY ib.id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            double finePerDay = getFinePerDay(con);

            while (rs.next()) {
                list.add(mapIssueRecord(rs, finePerDay));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<IssueRecord> getAllIssues() {
        List<IssueRecord> list = new ArrayList<>();
        String sql =
        "SELECT ib.id, ib.book_id, COALESCE(b.title, 'Unavailable Title') as title, " +
        "COALESCE(b.author, 'Unknown Author') as author, COALESCE(b.isbn, '') as isbn, " +
        "b.cover_image, ib.student_id, ib.student_name, ib.student_contact, " +
        "ib.request_date, ib.admin_issued_at, ib.confirmed_at, ib.issue_date, " +
        "ib.due_date, ib.return_date, ib.fine, ib.status, ib.fine_paid, " +
        "ib.renew_count, ib.rejection_reason " +
        "FROM issue_books ib LEFT JOIN books b ON ib.book_id=b.id " +
        "ORDER BY ib.id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            double finePerDay = getFinePerDay(con);

            while (rs.next()) {
                list.add(mapIssueRecord(rs, finePerDay));
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

            // Check and fulfill any waiting reservation
            new ReservationDAO().checkAndFulfillWaitingReservation(con, bookId);

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
        String sql = "SELECT id, due_date, return_date, fine, status, fine_paid FROM issue_books WHERE student_id = ? AND (fine_paid = 0 OR fine_paid IS NULL)";
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

    private IssueRecord mapIssueRecord(ResultSet rs, double finePerDay) throws SQLException {
        IssueRecord record = new IssueRecord();
        record.setIssueId(rs.getInt("id"));
        record.setBookId(rs.getInt("book_id"));
        record.setBookTitle(rs.getString("title"));
        try { record.setBookAuthor(rs.getString("author")); } catch (Exception ignored) {}
        try { record.setBookIsbn(rs.getString("isbn")); } catch (Exception ignored) {}
        try { record.setBookCoverImage(rs.getString("cover_image")); } catch (Exception ignored) {}
        try { record.setStudentId(rs.getInt("student_id")); } catch (Exception ignored) {}
        record.setStudentName(rs.getString("student_name"));
        record.setStudentContact(rs.getString("student_contact"));
        try { record.setRequestDate(rs.getDate("request_date")); } catch (Exception ignored) {}
        try { record.setAdminIssuedAt(rs.getTimestamp("admin_issued_at")); } catch (Exception ignored) {}
        try { record.setConfirmedAt(rs.getTimestamp("confirmed_at")); } catch (Exception ignored) {}
        record.setIssueDate(rs.getDate("issue_date"));
        record.setDueDate(rs.getDate("due_date"));
        record.setReturnDate(rs.getDate("return_date"));
        String status = rs.getString("status");
        record.setFine(calculateDynamicFine(rs.getDate("due_date"), rs.getDate("return_date"), status, rs.getDouble("fine"), finePerDay));
        record.setStatus(status);
        try { record.setFinePaid(rs.getInt("fine_paid") == 1); } catch (Exception ignored) {}
        try { record.setRenewCount(rs.getInt("renew_count")); } catch (Exception ignored) {}
        try { record.setRejectionReason(rs.getString("rejection_reason")); } catch (Exception ignored) {}
        return record;
    }

    public List<IssueRecord> getIssuesByStudentId(int studentId) {
        List<IssueRecord> list = new ArrayList<>();

        String sql = "SELECT ib.id, ib.book_id, COALESCE(b.title, 'Unavailable Title') as title, "
                + "COALESCE(b.author, 'Unknown Author') as author, COALESCE(b.isbn, '') as isbn, "
                + "b.cover_image, ib.student_id, ib.student_name, ib.student_contact, "
                + "ib.request_date, ib.admin_issued_at, ib.confirmed_at, ib.issue_date, "
                + "ib.due_date, ib.return_date, ib.fine, ib.status, ib.fine_paid, "
                + "ib.renew_count, ib.rejection_reason "
                + "FROM issue_books ib LEFT JOIN books b ON ib.book_id = b.id "
                + "WHERE ib.student_id = ? ORDER BY ib.id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            double finePerDay = getFinePerDay(con);
            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapIssueRecord(rs, finePerDay));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<IssueRecord> getPendingIssuesByStudentId(int studentId) {
        List<IssueRecord> list = new ArrayList<>();
        String sql = "SELECT ib.id, ib.book_id, COALESCE(b.title, 'Unavailable Title') as title, "
                + "COALESCE(b.author, 'Unknown Author') as author, COALESCE(b.isbn, '') as isbn, "
                + "b.cover_image, ib.student_id, ib.student_name, ib.student_contact, "
                + "ib.request_date, ib.admin_issued_at, ib.confirmed_at, ib.issue_date, "
                + "ib.due_date, ib.return_date, ib.fine, ib.status, ib.fine_paid, "
                + "ib.renew_count, ib.rejection_reason "
                + "FROM issue_books ib LEFT JOIN books b ON ib.book_id = b.id "
                + "WHERE ib.student_id = ? AND ib.status = 'Pending' "
                + "ORDER BY ib.id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            double finePerDay = getFinePerDay(con);
            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapIssueRecord(rs, finePerDay));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<IssueRecord> getActiveIssuesByStudentId(int studentId) {
        List<IssueRecord> list = new ArrayList<>();
        String sql = "SELECT ib.id, ib.book_id, COALESCE(b.title, 'Unavailable Title') as title, "
                + "COALESCE(b.author, 'Unknown Author') as author, COALESCE(b.isbn, '') as isbn, "
                + "b.cover_image, ib.student_id, ib.student_name, ib.student_contact, "
                + "ib.request_date, ib.admin_issued_at, ib.confirmed_at, ib.issue_date, "
                + "ib.due_date, ib.return_date, ib.fine, ib.status, ib.fine_paid, "
                + "ib.renew_count, ib.rejection_reason "
                + "FROM issue_books ib LEFT JOIN books b ON ib.book_id = b.id "
                + "WHERE ib.student_id = ? AND ib.status = 'Issued' "
                + "ORDER BY ib.id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            double finePerDay = getFinePerDay(con);
            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapIssueRecord(rs, finePerDay));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getPendingIssuesCountByStudentId(int studentId) {
        String sql = "SELECT COUNT(*) FROM issue_books WHERE student_id = ? AND status = 'Pending'";
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

    public List<IssueRecord> getBorrowingHistory(int studentId, String search, String statusFilter, String startDate, String endDate) {
        List<IssueRecord> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT ib.id, ib.book_id, COALESCE(b.title, 'Unavailable Title') as title, " +
            "COALESCE(b.author, 'Unknown Author') as author, COALESCE(b.isbn, '') as isbn, " +
            "b.cover_image, ib.student_id, ib.student_name, ib.student_contact, " +
            "ib.request_date, ib.admin_issued_at, ib.confirmed_at, ib.issue_date, " +
            "ib.due_date, ib.return_date, ib.fine, ib.status, ib.fine_paid, " +
            "ib.renew_count, ib.rejection_reason " +
            "FROM issue_books ib LEFT JOIN books b ON ib.book_id = b.id " +
            "WHERE ib.student_id = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(studentId);

        if (search != null && !search.trim().isEmpty()) {
            String s = "%" + search.trim() + "%";
            sql.append("AND (b.title LIKE ? OR b.author LIKE ? OR b.isbn LIKE ?) ");
            params.add(s);
            params.add(s);
            params.add(s);
        }

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            if ("ISSUED".equalsIgnoreCase(statusFilter) || "ACTIVE".equalsIgnoreCase(statusFilter)) {
                sql.append("AND ib.status = 'Issued' ");
            } else if ("PENDING".equalsIgnoreCase(statusFilter)) {
                sql.append("AND ib.status = 'Pending' ");
            } else if ("RETURNED".equalsIgnoreCase(statusFilter)) {
                sql.append("AND ib.status = 'Returned' ");
            } else if ("OVERDUE".equalsIgnoreCase(statusFilter)) {
                sql.append("AND ib.status = 'Issued' AND ib.due_date < CURDATE() ");
            } else if ("REJECTED".equalsIgnoreCase(statusFilter)) {
                sql.append("AND ib.status = 'Rejected' ");
            }
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            try {
                Date sDate = Date.valueOf(startDate.trim());
                sql.append("AND ib.issue_date >= ? ");
                params.add(sDate);
            } catch (Exception ignored) {}
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            try {
                Date eDate = Date.valueOf(endDate.trim());
                sql.append("AND ib.issue_date <= ? ");
                params.add(eDate);
            } catch (Exception ignored) {}
        }

        sql.append("ORDER BY ib.id DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            double finePerDay = getFinePerDay(con);
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) ps.setInt(i + 1, (Integer) p);
                else if (p instanceof String) ps.setString(i + 1, (String) p);
                else if (p instanceof Date) ps.setDate(i + 1, (Date) p);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapIssueRecord(rs, finePerDay));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public static class LifetimeStats {
        public int totalCount;
        public int activeCount;
        public int pendingCount;
        public int returnedCount;
        public int overdueCount;
        public int rejectedCount;
        public double totalFines;
    }

    public LifetimeStats getLifetimeStats(int studentId) {
        LifetimeStats stats = new LifetimeStats();
        List<IssueRecord> all = getBorrowingHistory(studentId, null, "ALL", null, null);
        stats.totalCount = all.size();
        for (IssueRecord r : all) {
            if ("Issued".equalsIgnoreCase(r.getStatus())) {
                stats.activeCount++;
                if (r.getDueDate() != null && r.getDueDate().toLocalDate().isBefore(LocalDate.now())) {
                    stats.overdueCount++;
                }
            } else if ("Pending".equalsIgnoreCase(r.getStatus())) {
                stats.pendingCount++;
            } else if ("Returned".equalsIgnoreCase(r.getStatus())) {
                stats.returnedCount++;
            } else if ("Rejected".equalsIgnoreCase(r.getStatus())) {
                stats.rejectedCount++;
            }
            if (r.getFine() > 0) {
                stats.totalFines += r.getFine();
            }
        }
        return stats;
    }

    public IssueResult renewBook(int issueId, int studentId) {
        String checkSql = "SELECT due_date, fine, renew_count, status FROM issue_books WHERE id = ? AND student_id = ?";
        try (Connection con = DBConnection.getConnection()) {
            double finePerDay = getFinePerDay(con);
            Date dueDate = null;
            int renewCount = 0;
            String status = null;
            double fine = 0;

            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setInt(1, issueId);
                ps.setInt(2, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return new IssueResult(false, "Borrow record not found.");
                    }
                    dueDate = rs.getDate("due_date");
                    renewCount = rs.getInt("renew_count");
                    status = rs.getString("status");
                    fine = calculateDynamicFine(dueDate, null, status, rs.getDouble("fine"), finePerDay);
                }
            }

            if (!"Issued".equalsIgnoreCase(status)) {
                return new IssueResult(false, "Only currently issued books can be renewed.");
            }
            if (renewCount >= 2) {
                return new IssueResult(false, "Maximum renewals reached (2 renewals per issued book).");
            }
            if (fine > 0) {
                return new IssueResult(false, "Cannot renew overdue books with outstanding fines. Please return the book.");
            }

            int renewalDays = new SettingsDAO().getIntSetting("renewal_days", 7);
            String updateSql = "UPDATE issue_books SET due_date = DATE_ADD(due_date, INTERVAL ? DAY), renew_count = renew_count + 1 WHERE id = ?";
            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setInt(1, renewalDays);
                ps.setInt(2, issueId);
                if (ps.executeUpdate() > 0) {
                    new NotificationDAO().createNotification(new model.Notification(
                        studentId, "student", "Loan Renewal Confirmed",
                        "Your loan has been renewed (+" + renewalDays + " days added to due date).",
                        "RENEWAL", "StudentIssuedBooksServlet"
                    ));
                    return new IssueResult(true, "Book successfully renewed (+" + renewalDays + " days added to due date).");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new IssueResult(false, "Failed to renew book. Please try again.");
    }

    public IssueResult returnBookByStudent(int issueId, int studentId) {
        String getSql = "SELECT ib.book_id, ib.due_date, ib.status, b.title FROM issue_books ib JOIN books b ON ib.book_id = b.id WHERE ib.id=? AND ib.student_id=?";
        String updateIssue = "UPDATE issue_books SET returned=1, return_date=CURDATE(), fine=?, status='Returned' WHERE id=?";
        String updateBook = "UPDATE books SET quantity = quantity + 1 WHERE id=?";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return new IssueResult(false, "Database connection unavailable.");
            con.setAutoCommit(false);

            int bookId = 0;
            double fine = 0;
            String bookTitle = "Book";

            try (PreparedStatement ps1 = con.prepareStatement(getSql)) {
                ps1.setInt(1, issueId);
                ps1.setInt(2, studentId);
                try (ResultSet rs = ps1.executeQuery()) {
                    if (rs.next()) {
                        if (!"Issued".equalsIgnoreCase(rs.getString("status"))) {
                            con.rollback();
                            return new IssueResult(false, "This loan is already returned or closed.");
                        }
                        bookId = rs.getInt("book_id");
                        bookTitle = rs.getString("title");
                        Date dueDate = rs.getDate("due_date");
                        LocalDate today = LocalDate.now();
                        LocalDate due = dueDate.toLocalDate();
                        long lateDays = java.time.temporal.ChronoUnit.DAYS.between(due, today);
                        if (lateDays > 0) {
                            double finePerDay = getFinePerDay(con);
                            fine = lateDays * finePerDay;
                        }
                    } else {
                        con.rollback();
                        return new IssueResult(false, "Loan record not found or does not belong to you.");
                    }
                }
            }

            try (PreparedStatement ps2 = con.prepareStatement(updateIssue)) {
                ps2.setDouble(1, fine);
                ps2.setInt(2, issueId);
                ps2.executeUpdate();
            }

            try (PreparedStatement ps3 = con.prepareStatement(updateBook)) {
                ps3.setInt(1, bookId);
                ps3.executeUpdate();
            }

            // Check waiting reservation
            new ReservationDAO().checkAndFulfillWaitingReservation(con, bookId);

            con.commit();

            String msg = "Book \"" + bookTitle + "\" returned successfully.";
            if (fine > 0) {
                msg += " Overdue penalty of ₹" + String.format("%.2f", fine) + " has been added to your fine ledger.";
            }
            new NotificationDAO().createNotification(new model.Notification(
                studentId, "student", "Book Return Confirmed", msg, "RETURN", "StudentIssuedBooksServlet"
            ));
            new NotificationDAO().notifyAdmins(
                "Book Returned: " + bookTitle,
                "Student #" + studentId + " returned \"" + bookTitle + "\" (Loan #" + issueId + ").",
                "RETURN",
                "ReturnBookServlet"
            );

            String retMsg = "Book successfully returned.";
            if (fine > 0) {
                retMsg += " Note: An overdue fine of ₹" + String.format("%.2f", fine) + " applies.";
            }
            return new IssueResult(true, retMsg);
        } catch (Exception e) {
            e.printStackTrace();
            return new IssueResult(false, "Failed to process return. Please try again.");
        }
    }

    public boolean payFine(int issueId, int studentId) {
        String sql = "UPDATE issue_books SET fine_paid = 1 WHERE id = ? AND student_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, issueId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public java.util.Map<String, Integer> getRecentBorrowingTrends() {
        java.util.Map<String, Integer> trends = new java.util.LinkedHashMap<>();
        String sql = "SELECT DATE_FORMAT(issue_date, '%b %d') as dt, COUNT(*) as cnt " +
                     "FROM issue_books GROUP BY DATE_FORMAT(issue_date, '%b %d'), issue_date " +
                     "ORDER BY issue_date ASC LIMIT 7";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                trends.put(rs.getString("dt"), rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return trends;
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