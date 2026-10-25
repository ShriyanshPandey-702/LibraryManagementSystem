package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.BookCopy;
import util.DBConnection;

public class BookCopyDAO {

    public boolean createCopies(int bookId, int count) {
        String maxCopySql = "SELECT COALESCE(MAX(copy_number), 0) FROM book_copies WHERE book_id = ?";
        String insertSql = "INSERT INTO book_copies (book_id, copy_number, barcode_id, status) VALUES (?, ?, ?, 'Available')";

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) return false;

            int startNumber = 0;
            try (PreparedStatement psMax = con.prepareStatement(maxCopySql)) {
                psMax.setInt(1, bookId);
                try (ResultSet rs = psMax.executeQuery()) {
                    if (rs.next()) {
                        startNumber = rs.getInt(1);
                    }
                }
            }

            try (PreparedStatement psIns = con.prepareStatement(insertSql)) {
                for (int i = 1; i <= count; i++) {
                    int copyNum = startNumber + i;
                    psIns.setInt(1, bookId);
                    psIns.setInt(2, copyNum);
                    psIns.setString(3, "BC-" + bookId + "-" + String.format("%03d", copyNum));
                    psIns.addBatch();
                }
                psIns.executeBatch();
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<BookCopy> getCopiesForBook(int bookId) {
        List<BookCopy> list = new ArrayList<>();
        String sql = "SELECT c.id, c.book_id, b.title as book_title, c.copy_number, c.barcode_id, c.status, c.condition_notes, c.acquisition_date " +
                     "FROM book_copies c JOIN books b ON c.book_id = b.id " +
                     "WHERE c.book_id = ? ORDER BY c.copy_number ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCopy(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public BookCopy getCopyByBarcode(String barcodeId) {
        if (barcodeId == null || barcodeId.trim().isEmpty()) return null;
        String sql = "SELECT c.id, c.book_id, b.title as book_title, c.copy_number, c.barcode_id, c.status, c.condition_notes, c.acquisition_date " +
                     "FROM book_copies c JOIN books b ON c.book_id = b.id " +
                     "WHERE c.barcode_id = ? LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, barcodeId.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCopy(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public BookCopy getAvailableCopyForBook(int bookId) {
        String sql = "SELECT c.id, c.book_id, b.title as book_title, c.copy_number, c.barcode_id, c.status, c.condition_notes, c.acquisition_date " +
                     "FROM book_copies c JOIN books b ON c.book_id = b.id " +
                     "WHERE c.book_id = ? AND c.status = 'Available' ORDER BY c.copy_number ASC LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCopy(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateCopyStatus(int copyId, String status, String conditionNotes) {
        String sql = "UPDATE book_copies SET status = ?, condition_notes = COALESCE(?, condition_notes) WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, conditionNotes);
            ps.setInt(3, copyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private BookCopy mapCopy(ResultSet rs) throws Exception {
        BookCopy c = new BookCopy();
        c.setId(rs.getInt("id"));
        c.setBookId(rs.getInt("book_id"));
        c.setBookTitle(rs.getString("book_title"));
        c.setCopyNumber(rs.getInt("copy_number"));
        c.setBarcodeId(rs.getString("barcode_id"));
        c.setStatus(rs.getString("status"));
        c.setConditionNotes(rs.getString("condition_notes"));
        c.setAcquisitionDate(rs.getDate("acquisition_date"));
        return c;
    }
}
