package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.BookRequest;
import util.DBConnection;

public class BookRequestDAO {

    public boolean createRequest(BookRequest bookRequest) {
        String sql = "INSERT INTO book_requests(student_id, student_name, course, `year`, book_id, book_title, request_date, status) "
                + "VALUES(?,?,?,?,?,?,CURDATE(),'Pending')";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, bookRequest.getStudentId());
            ps.setString(2, bookRequest.getStudentName());
            ps.setString(3, bookRequest.getCourse());
            ps.setString(4, bookRequest.getYear());
            ps.setInt(5, bookRequest.getBookId());
            ps.setString(6, bookRequest.getBookTitle());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getPendingRequestCount() {
        String sql = "SELECT COUNT(*) FROM book_requests WHERE status = 'Pending'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<BookRequest> getPendingRequests() {
        List<BookRequest> requests = new ArrayList<>();
        String sql = "SELECT id, student_id, student_name, course, `year`, book_id, book_title, request_date, status "
                + "FROM book_requests WHERE status = 'Pending' ORDER BY request_date DESC, id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                BookRequest request = new BookRequest();
                request.setId(rs.getInt("id"));
                request.setStudentId(rs.getInt("student_id"));
                request.setStudentName(rs.getString("student_name"));
                request.setCourse(rs.getString("course"));
                request.setYear(rs.getString("year"));
                request.setBookId(rs.getInt("book_id"));
                request.setBookTitle(rs.getString("book_title"));
                request.setRequestDate(rs.getDate("request_date"));
                request.setStatus(rs.getString("status"));
                requests.add(request);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return requests;
    }

    public BookRequest getRequestById(int requestId) {
        String sql = "SELECT id, student_id, student_name, course, `year`, book_id, book_title, request_date, status "
                + "FROM book_requests WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, requestId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BookRequest request = new BookRequest();
                    request.setId(rs.getInt("id"));
                    request.setStudentId(rs.getInt("student_id"));
                    request.setStudentName(rs.getString("student_name"));
                    request.setCourse(rs.getString("course"));
                    request.setYear(rs.getString("year"));
                    request.setBookId(rs.getInt("book_id"));
                    request.setBookTitle(rs.getString("book_title"));
                    request.setRequestDate(rs.getDate("request_date"));
                    request.setStatus(rs.getString("status"));
                    return request;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean hasPendingRequest(int studentId, int bookId) {
        String sql = "SELECT 1 FROM book_requests WHERE student_id = ? AND book_id = ? AND status = 'Pending'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getStudentPendingRequestCount(int studentId) {
        String sql = "SELECT COUNT(*) FROM book_requests WHERE student_id = ? AND status = 'Pending'";
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

    public boolean markRequestApproved(int requestId) {
        String sql = "UPDATE book_requests SET status = 'Approved' WHERE id = ? AND status = 'Pending'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean markRequestRejected(int requestId) {
        String sql = "UPDATE book_requests SET status = 'Rejected' WHERE id = ? AND status = 'Pending'";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
