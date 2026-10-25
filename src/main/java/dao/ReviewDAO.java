package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.BookReview;
import util.DBConnection;

public class ReviewDAO {

    public boolean hasStudentBorrowedBook(int bookId, int studentId) {
        String sql = "SELECT 1 FROM issue_books WHERE book_id = ? AND student_id = ? LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addOrUpdateReview(int bookId, int studentId, int rating, String reviewText) {
        if (rating < 1) rating = 1;
        if (rating > 5) rating = 5;

        String sql = "INSERT INTO book_reviews (book_id, student_id, rating, review_text) VALUES (?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE rating = VALUES(rating), review_text = VALUES(review_text), is_hidden = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, studentId);
            ps.setInt(3, rating);
            ps.setString(4, reviewText);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteReview(int reviewId, int studentId) {
        String sql = "DELETE FROM book_reviews WHERE id = ? AND student_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean setHidden(int reviewId, boolean hidden) {
        String sql = "UPDATE book_reviews SET is_hidden = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, hidden ? 1 : 0);
            ps.setInt(2, reviewId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public BookReview getStudentReview(int bookId, int studentId) {
        String sql = "SELECT r.id, r.book_id, r.student_id, s.name as student_name, r.rating, r.review_text, r.is_hidden, r.created_at, r.updated_at " +
                     "FROM book_reviews r JOIN students s ON r.student_id = s.id " +
                     "WHERE r.book_id = ? AND r.student_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapReview(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<BookReview> getReviewsForBook(int bookId, boolean includeHidden) {
        List<BookReview> list = new ArrayList<>();
        String sql = "SELECT r.id, r.book_id, r.student_id, s.name as student_name, r.rating, r.review_text, r.is_hidden, r.created_at, r.updated_at " +
                     "FROM book_reviews r JOIN students s ON r.student_id = s.id " +
                     "WHERE r.book_id = ? " + (includeHidden ? "" : "AND r.is_hidden = 0 ") +
                     "ORDER BY r.created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapReview(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public double[] getAverageRatingAndCount(int bookId) {
        String sql = "SELECT COALESCE(AVG(rating), 0.0) as avg_rating, COUNT(*) as cnt FROM book_reviews WHERE book_id = ? AND is_hidden = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new double[]{rs.getDouble("avg_rating"), rs.getDouble("cnt")};
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new double[]{0.0, 0.0};
    }

    private BookReview mapReview(ResultSet rs) throws Exception {
        BookReview r = new BookReview();
        r.setId(rs.getInt("id"));
        r.setBookId(rs.getInt("book_id"));
        r.setStudentId(rs.getInt("student_id"));
        r.setStudentName(rs.getString("student_name"));
        r.setRating(rs.getInt("rating"));
        r.setReviewText(rs.getString("review_text"));
        r.setHidden(rs.getInt("is_hidden") == 1);
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));
        return r;
    }
}
