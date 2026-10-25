package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.LostDamagedReport;
import model.Notification;
import util.DBConnection;

public class LostDamagedDAO {

    public boolean createReport(int issueId, int bookId, int studentId, String reportType, String description) {
        String verifySql = "SELECT id FROM issue_books WHERE id = ? AND student_id = ? AND status = 'Issued'";
        String insertSql = "INSERT INTO lost_damaged_reports (issue_id, book_id, student_id, report_type, description, status) " +
                           "VALUES (?, ?, ?, ?, ?, 'Pending')";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return false;

            // Verify student owns active loan
            try (PreparedStatement ps = con.prepareStatement(verifySql)) {
                ps.setInt(1, issueId);
                ps.setInt(2, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return false;
                }
            }

            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setInt(1, issueId);
                ps.setInt(2, bookId);
                ps.setInt(3, studentId);
                ps.setString(4, reportType);
                ps.setString(5, description);
                boolean ok = ps.executeUpdate() > 0;
                if (ok) {
                    new NotificationDAO().notifyAdmins(
                        "Incident Report Filed: " + reportType,
                        "Student #" + studentId + " filed a " + reportType + " incident report for Loan #" + issueId + ". Requires librarian assessment.",
                        "INCIDENT",
                        "AdminLostDamagedServlet"
                    );
                }
                return ok;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<LostDamagedReport> getStudentReports(int studentId) {
        List<LostDamagedReport> list = new ArrayList<>();
        String sql = "SELECT r.id, r.issue_id, r.book_id, b.title as book_title, r.student_id, r.copy_id, " +
                     "r.report_type, r.description, r.status, r.admin_notes, r.fine_amount, r.created_at, r.resolved_at " +
                     "FROM lost_damaged_reports r JOIN books b ON r.book_id = b.id " +
                     "WHERE r.student_id = ? ORDER BY r.created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReport(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<LostDamagedReport> getAllReports(String statusFilter) {
        List<LostDamagedReport> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT r.id, r.issue_id, r.book_id, b.title as book_title, r.student_id, s.name as student_name, r.copy_id, " +
            "r.report_type, r.description, r.status, r.admin_notes, r.fine_amount, r.created_at, r.resolved_at " +
            "FROM lost_damaged_reports r JOIN books b ON r.book_id = b.id JOIN students s ON r.student_id = s.id "
        );
        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("WHERE r.status = ? ");
        }
        sql.append("ORDER BY r.created_at DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
                ps.setString(1, statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LostDamagedReport r = mapReport(rs);
                    r.setStudentName(rs.getString("student_name"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean resolveReport(int reportId, String status, String adminNotes, double fineAmount) {
        String selectSql = "SELECT r.issue_id, r.student_id, b.title, r.report_type FROM lost_damaged_reports r " +
                           "JOIN books b ON r.book_id = b.id WHERE r.id = ?";
        String updateReportSql = "UPDATE lost_damaged_reports SET status = ?, admin_notes = ?, fine_amount = ?, resolved_at = CURRENT_TIMESTAMP WHERE id = ?";
        String updateFineSql = "UPDATE issue_books SET fine = fine + ? WHERE id = ?";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return false;
            con.setAutoCommit(false);

            int issueId = 0;
            int studentId = 0;
            String bookTitle = "Book";
            String reportType = "Incident";

            try (PreparedStatement ps = con.prepareStatement(selectSql)) {
                ps.setInt(1, reportId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        issueId = rs.getInt("issue_id");
                        studentId = rs.getInt("student_id");
                        bookTitle = rs.getString("title");
                        reportType = rs.getString("report_type");
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement(updateReportSql)) {
                ps.setString(1, status);
                ps.setString(2, adminNotes);
                ps.setDouble(3, fineAmount);
                ps.setInt(4, reportId);
                ps.executeUpdate();
            }

            if (fineAmount > 0 && issueId > 0) {
                try (PreparedStatement ps = con.prepareStatement(updateFineSql)) {
                    ps.setDouble(1, fineAmount);
                    ps.setInt(2, issueId);
                    ps.executeUpdate();
                }
            }

            con.commit();

            // Notify student
            String msg = "Your " + reportType + " report for \"" + bookTitle + "\" has been updated to [" + status + "].";
            if (fineAmount > 0) {
                msg += " A settlement assessment of ₹" + String.format("%.2f", fineAmount) + " has been added to your fine ledger.";
            }
            new NotificationDAO().createNotification(new Notification(
                studentId, "student",
                reportType + " Report Updated",
                msg,
                "FINE", "StudentFineStatusServlet"
            ));

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private LostDamagedReport mapReport(ResultSet rs) throws Exception {
        LostDamagedReport r = new LostDamagedReport();
        r.setId(rs.getInt("id"));
        r.setIssueId(rs.getInt("issue_id"));
        r.setBookId(rs.getInt("book_id"));
        r.setBookTitle(rs.getString("book_title"));
        r.setStudentId(rs.getInt("student_id"));
        int cId = rs.getInt("copy_id");
        r.setCopyId(rs.wasNull() ? null : cId);
        r.setReportType(rs.getString("report_type"));
        r.setDescription(rs.getString("description"));
        r.setStatus(rs.getString("status"));
        r.setAdminNotes(rs.getString("admin_notes"));
        r.setFineAmount(rs.getDouble("fine_amount"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setResolvedAt(rs.getTimestamp("resolved_at"));
        return r;
    }
}
