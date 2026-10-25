package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.BookReservation;
import model.Notification;
import util.DBConnection;

public class ReservationDAO {

    public static class ReservationResult {
        private final boolean success;
        private final String message;

        public ReservationResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
    }

    public ReservationResult reserveBook(int bookId, int studentId) {
        String checkDuplicateSql = "SELECT id, status FROM book_reservations WHERE book_id = ? AND student_id = ? AND status IN ('Waiting', 'Ready for Pickup')";
        String checkBookSql = "SELECT title, quantity FROM books WHERE id = ? AND is_deleted = 0";
        String insertSql = "INSERT INTO book_reservations (book_id, student_id, status) VALUES (?, ?, 'Waiting')";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return new ReservationResult(false, "Database connection unavailable.");

            // Check duplicate
            try (PreparedStatement ps = con.prepareStatement(checkDuplicateSql)) {
                ps.setInt(1, bookId);
                ps.setInt(2, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return new ReservationResult(false, "You already have an active reservation for this title.");
                    }
                }
            }

            // Check book existence
            String bookTitle = "Book";
            try (PreparedStatement ps = con.prepareStatement(checkBookSql)) {
                ps.setInt(1, bookId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return new ReservationResult(false, "Book not found or has been removed.");
                    }
                    bookTitle = rs.getString("title");
                }
            }

            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setInt(1, bookId);
                ps.setInt(2, studentId);
                if (ps.executeUpdate() > 0) {
                    int pos = getQueuePosition(bookId, studentId);
                    // Notify student
                    new NotificationDAO().createNotification(new Notification(
                        studentId, "student",
                        "Reservation Placed: " + bookTitle,
                        "You are currently #" + pos + " on the waiting list for \"" + bookTitle + "\". We will notify you when a copy becomes available.",
                        "GENERAL", "StudentReservationsServlet"
                    ));
                    // Notify admins
                    new NotificationDAO().notifyAdmins(
                        "New Waitlist Reservation: " + bookTitle,
                        "Student #" + studentId + " reserved out-of-stock title \"" + bookTitle + "\" (Queue position #" + pos + ").",
                        "RESERVATION",
                        "AdminReservationsServlet"
                    );
                    return new ReservationResult(true, "Reservation placed successfully! You are #" + pos + " in the waiting list.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return new ReservationResult(false, "Unable to place reservation. Please try again.");
    }

    public boolean cancelReservation(int reservationId, int studentId) {
        String sql = "UPDATE book_reservations SET status = 'Cancelled' WHERE id = ? AND student_id = ? AND status IN ('Waiting', 'Ready for Pickup')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getQueuePosition(int bookId, int studentId) {
        String sql = "SELECT COUNT(*) FROM book_reservations WHERE book_id = ? AND status = 'Waiting' AND reservation_date <= " +
                     "(SELECT reservation_date FROM book_reservations WHERE book_id = ? AND student_id = ? AND status = 'Waiting' ORDER BY reservation_date ASC LIMIT 1)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, bookId);
            ps.setInt(3, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1;
    }

    public List<BookReservation> getStudentReservations(int studentId) {
        List<BookReservation> list = new ArrayList<>();
        String sql = "SELECT r.id, r.book_id, b.title as book_title, r.student_id, r.reservation_date, r.status, r.pickup_deadline, r.notified " +
                     "FROM book_reservations r JOIN books b ON r.book_id = b.id " +
                     "WHERE r.student_id = ? ORDER BY r.reservation_date DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookReservation res = mapReservation(rs);
                    if ("Waiting".equalsIgnoreCase(res.getStatus())) {
                        res.setQueuePosition(getQueuePosition(res.getBookId(), studentId));
                    }
                    list.add(res);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<BookReservation> getAllReservations(String statusFilter) {
        List<BookReservation> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT r.id, r.book_id, b.title as book_title, r.student_id, s.name as student_name, r.reservation_date, r.status, r.pickup_deadline, r.notified " +
            "FROM book_reservations r JOIN books b ON r.book_id = b.id JOIN students s ON r.student_id = s.id "
        );
        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("WHERE r.status = ? ");
        }
        sql.append("ORDER BY r.reservation_date DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
                ps.setString(1, statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookReservation res = mapReservation(rs);
                    res.setStudentName(rs.getString("student_name"));
                    list.add(res);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Called atomically when a book is returned: advances the waiting queue and alerts the student */
    public boolean checkAndFulfillWaitingReservation(Connection con, int bookId) {
        String findNextSql = "SELECT r.id, r.student_id, b.title " +
                             "FROM book_reservations r JOIN books b ON r.book_id = b.id " +
                             "WHERE r.book_id = ? AND r.status = 'Waiting' " +
                             "ORDER BY r.reservation_date ASC LIMIT 1";

        int pickupDays = new SettingsDAO().getIntSetting("reservation_pickup_days", 3);
        String updateSql = "UPDATE book_reservations SET status = 'Ready for Pickup', " +
                           "pickup_deadline = DATE_ADD(CURDATE(), INTERVAL ? DAY), notified = 1 WHERE id = ?";

        try (PreparedStatement psFind = con.prepareStatement(findNextSql)) {
            psFind.setInt(1, bookId);
            try (ResultSet rs = psFind.executeQuery()) {
                if (rs.next()) {
                    int resId = rs.getInt("id");
                    int studentId = rs.getInt("student_id");
                    String bookTitle = rs.getString("title");

                    try (PreparedStatement psUp = con.prepareStatement(updateSql)) {
                        psUp.setInt(1, pickupDays);
                        psUp.setInt(2, resId);
                        psUp.executeUpdate();
                    }

                    // Send notification to the student
                    new NotificationDAO().createNotification(new Notification(
                        studentId, "student",
                        "Reserved Book Ready: " + bookTitle,
                        "Great news! Your reserved book \"" + bookTitle + "\" is now ready for pickup at the circulation desk. Please collect it within " + pickupDays + " days.",
                        "RESERVATION_READY", "StudentReservationsServlet"
                    ));

                    return true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Automatically expires uncollected reservations whose pickup deadline has passed */
    public void expireOverduePickups() {
        String selectSql = "SELECT id, book_id, student_id FROM book_reservations " +
                           "WHERE status = 'Ready for Pickup' AND pickup_deadline < CURDATE()";
        String expireSql = "UPDATE book_reservations SET status = 'Expired' WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement psSel = con.prepareStatement(selectSql);
             ResultSet rs = psSel.executeQuery()) {
            while (rs.next()) {
                int resId = rs.getInt("id");
                int bookId = rs.getInt("book_id");
                try (PreparedStatement psExp = con.prepareStatement(expireSql)) {
                    psExp.setInt(1, resId);
                    psExp.executeUpdate();
                }
                // Try to fulfill for next waiting person
                checkAndFulfillWaitingReservation(con, bookId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private BookReservation mapReservation(ResultSet rs) throws Exception {
        BookReservation r = new BookReservation();
        r.setId(rs.getInt("id"));
        r.setBookId(rs.getInt("book_id"));
        r.setBookTitle(rs.getString("book_title"));
        r.setStudentId(rs.getInt("student_id"));
        r.setReservationDate(rs.getTimestamp("reservation_date"));
        r.setStatus(rs.getString("status"));
        r.setPickupDeadline(rs.getDate("pickup_deadline"));
        r.setNotified(rs.getInt("notified") == 1);
        return r;
    }
}
