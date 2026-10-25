package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Notification;
import util.DBConnection;

public class NotificationDAO {

    public boolean createNotification(Notification n) {
        String sql = "INSERT INTO notifications (user_id, user_role, title, message, type, link) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, n.getUserId());
            ps.setString(2, n.getUserRole());
            ps.setString(3, n.getTitle());
            ps.setString(4, n.getMessage());
            ps.setString(5, n.getType());
            ps.setString(6, n.getLink());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean notifyAdmins(String title, String message, String type, String link) {
        Notification n = new Notification(0, "admin", title, message, type, link);
        return createNotification(n);
    }

    public List<Notification> getUserNotifications(int userId, String role, int limit) {
        List<Notification> list = new ArrayList<>();
        String sql;
        boolean isAdmin = "admin".equalsIgnoreCase(role);
        if (isAdmin) {
            sql = "SELECT id, user_id, user_role, title, message, type, link, is_read, created_at " +
                  "FROM notifications WHERE user_role = 'admin' " +
                  "ORDER BY created_at DESC LIMIT ?";
        } else {
            sql = "SELECT id, user_id, user_role, title, message, type, link, is_read, created_at " +
                  "FROM notifications WHERE user_id = ? AND user_role = ? " +
                  "ORDER BY created_at DESC LIMIT ?";
        }
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (isAdmin) {
                ps.setInt(1, limit);
            } else {
                ps.setInt(1, userId);
                ps.setString(2, role);
                ps.setInt(3, limit);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getInt("id"));
                    n.setUserId(rs.getInt("user_id"));
                    n.setUserRole(rs.getString("user_role"));
                    n.setTitle(rs.getString("title"));
                    n.setMessage(rs.getString("message"));
                    n.setType(rs.getString("type"));
                    n.setLink(rs.getString("link"));
                    n.setRead(rs.getInt("is_read") == 1);
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(n);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getUnreadCount(int userId, String role) {
        boolean isAdmin = "admin".equalsIgnoreCase(role);
        String sql = isAdmin
            ? "SELECT COUNT(*) FROM notifications WHERE user_role = 'admin' AND is_read = 0"
            : "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND user_role = ? AND is_read = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (!isAdmin) {
                ps.setInt(1, userId);
                ps.setString(2, role);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean markAsRead(int notificationId, int userId, String role) {
        boolean isAdmin = "admin".equalsIgnoreCase(role);
        String sql = isAdmin
            ? "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_role = 'admin'"
            : "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ? AND user_role = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            if (!isAdmin) {
                ps.setInt(2, userId);
                ps.setString(3, role);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean markAllAsRead(int userId, String role) {
        boolean isAdmin = "admin".equalsIgnoreCase(role);
        String sql = isAdmin
            ? "UPDATE notifications SET is_read = 1 WHERE user_role = 'admin' AND is_read = 0"
            : "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND user_role = ? AND is_read = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (!isAdmin) {
                ps.setInt(1, userId);
                ps.setString(2, role);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /** Generates automated due-date reminders and overdue notifications idempotently */
    public void generateAutomatedReminders() {
        // Due soon reminder (within 2 days)
        String dueSoonSql = 
            "SELECT i.id, i.student_id, b.title, i.due_date " +
            "FROM issue_books i JOIN books b ON i.book_id = b.id " +
            "WHERE i.status = 'Issued' AND i.due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 2 DAY) " +
            "AND NOT EXISTS (" +
            "   SELECT 1 FROM notifications n WHERE n.user_id = i.student_id AND n.user_role = 'student' " +
            "   AND n.type = 'DUE_SOON' AND n.message LIKE CONCAT('%', b.title, '%') " +
            "   AND DATE(n.created_at) = CURDATE()" +
            ")";

        // Overdue reminder
        String overdueSql = 
            "SELECT i.id, i.student_id, b.title, i.due_date " +
            "FROM issue_books i JOIN books b ON i.book_id = b.id " +
            "WHERE i.status = 'Issued' AND i.due_date < CURDATE() " +
            "AND NOT EXISTS (" +
            "   SELECT 1 FROM notifications n WHERE n.user_id = i.student_id AND n.user_role = 'student' " +
            "   AND n.type = 'OVERDUE' AND n.message LIKE CONCAT('%', b.title, '%') " +
            "   AND DATE(n.created_at) = CURDATE()" +
            ")";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return;
            // Generate due soon
            try (PreparedStatement ps = con.prepareStatement(dueSoonSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification(
                        rs.getInt("student_id"), "student",
                        "Loan Due Soon: " + rs.getString("title"),
                        "Your loan for \"" + rs.getString("title") + "\" is due on " + rs.getDate("due_date") + ". Please return or renew in time.",
                        "DUE_SOON", "StudentIssuedBooksServlet"
                    );
                    createNotification(n);
                }
            }

            // Generate overdue
            try (PreparedStatement ps = con.prepareStatement(overdueSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification(
                        rs.getInt("student_id"), "student",
                        "Overdue Loan: " + rs.getString("title"),
                        "Your loan for \"" + rs.getString("title") + "\" was due on " + rs.getDate("due_date") + ". Daily overdue fines are accumulating.",
                        "OVERDUE", "StudentFineStatusServlet"
                    );
                    createNotification(n);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Automatically creates admin notifications for pending student requests, waitlists, and incident reports */
    public void generateAdminAlerts() {
        // 1. Pending Book Requests
        String pendingRequestsSql =
            "SELECT r.id, r.student_id, r.student_name, r.book_title " +
            "FROM book_requests r " +
            "WHERE r.status = 'Pending' " +
            "AND NOT EXISTS (" +
            "   SELECT 1 FROM notifications n WHERE n.user_role = 'admin' " +
            "   AND n.type = 'REQUEST' AND n.message LIKE CONCAT('%', r.book_title, '%') " +
            "   AND n.message LIKE CONCAT('%Student ', r.student_name, '%')" +
            ")";

        // 2. Pending Lost / Damaged Reports
        String pendingIncidentsSql =
            "SELECT l.id, l.student_id, l.report_type, b.title " +
            "FROM lost_damaged_reports l JOIN books b ON l.book_id = b.id " +
            "WHERE l.status = 'Under Review' " +
            "AND NOT EXISTS (" +
            "   SELECT 1 FROM notifications n WHERE n.user_role = 'admin' " +
            "   AND n.type = 'INCIDENT' AND n.link = 'AdminLostDamagedServlet' " +
            "   AND n.message LIKE CONCAT('%', b.title, '%')" +
            ")";

        // 3. Active Waiting Reservations
        String waitingReservationsSql =
            "SELECT r.id, r.student_id, b.title " +
            "FROM book_reservations r JOIN books b ON r.book_id = b.id " +
            "WHERE r.status = 'Waiting' " +
            "AND NOT EXISTS (" +
            "   SELECT 1 FROM notifications n WHERE n.user_role = 'admin' " +
            "   AND n.type = 'RESERVATION' AND n.message LIKE CONCAT('%', b.title, '%') " +
            "   AND DATE(n.created_at) = CURDATE()" +
            ")";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return;

            // Generate pending request alerts
            try (PreparedStatement ps = con.prepareStatement(pendingRequestsSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifyAdmins(
                        "New Book Request: " + rs.getString("book_title"),
                        "Student " + rs.getString("student_name") + " (ID #" + rs.getInt("student_id") + ") requested \"" + rs.getString("book_title") + "\".",
                        "REQUEST",
                        "AdminBookRequestsServlet"
                    );
                }
            }

            // Generate incident alerts
            try (PreparedStatement ps = con.prepareStatement(pendingIncidentsSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifyAdmins(
                        "Incident Report: " + rs.getString("title"),
                        "Student #" + rs.getInt("student_id") + " submitted a " + rs.getString("report_type") + " report for \"" + rs.getString("title") + "\".",
                        "INCIDENT",
                        "AdminLostDamagedServlet"
                    );
                }
            }

            // Generate reservation alerts
            try (PreparedStatement ps = con.prepareStatement(waitingReservationsSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifyAdmins(
                        "Waitlist Queue: " + rs.getString("title"),
                        "Student #" + rs.getInt("student_id") + " joined the waitlist for \"" + rs.getString("title") + "\".",
                        "RESERVATION",
                        "AdminReservationsServlet"
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
