package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.Book;
import util.DBConnection;

public class BookDAO {

    public boolean addBook(Book book) {
        String sql = "INSERT INTO books (title, author, category, isbn, rack_no, price, quantity) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, book.getTitle());
            ps.setString(2, book.getAuthor());
            ps.setString(3, book.getCategory());
            ps.setString(4, book.getIsbn());
            ps.setString(5, book.getRackNo());
            ps.setDouble(6, book.getPrice());
            ps.setInt(7, book.getQuantity());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Book> getAllBooks() {
        List<Book> books = new ArrayList<>();

        String sql = "SELECT id, title, author, category, isbn, rack_no, price, quantity FROM books WHERE is_deleted = 0 ORDER BY id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Book book = new Book();

                book.setBookId(rs.getInt("id"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setCategory(rs.getString("category"));
                book.setIsbn(rs.getString("isbn"));
                book.setRackNo(rs.getString("rack_no"));
                book.setPrice(rs.getDouble("price"));
                book.setQuantity(rs.getInt("quantity"));

                books.add(book);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return books;
    }

    public List<Book> getAvailableBooks() {
        List<Book> books = new ArrayList<>();

        String sql = "SELECT id, title, author, category, isbn, rack_no, price, quantity FROM books WHERE is_deleted = 0 AND quantity > 0 ORDER BY id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Book book = new Book();
                book.setBookId(rs.getInt("id"));
                book.setTitle(rs.getString("title"));
                book.setAuthor(rs.getString("author"));
                book.setCategory(rs.getString("category"));
                book.setIsbn(rs.getString("isbn"));
                book.setRackNo(rs.getString("rack_no"));
                book.setPrice(rs.getDouble("price"));
                book.setQuantity(rs.getInt("quantity"));
                books.add(book);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return books;
    }

    public int getTotalBookTitles() {
        String sql = "SELECT COUNT(*) FROM books WHERE is_deleted = 0";

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

    public List<Book> searchAvailableBooks(String keyword) {
        List<Book> books = new ArrayList<>();

        String sql = "SELECT id, title, author, category, isbn, rack_no, price, quantity FROM books "
                + "WHERE is_deleted = 0 AND quantity > 0 AND (title LIKE ? OR author LIKE ? OR category LIKE ? OR isbn LIKE ?) ORDER BY id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String searchKeyword = "%" + keyword + "%";
            ps.setString(1, searchKeyword);
            ps.setString(2, searchKeyword);
            ps.setString(3, searchKeyword);
            ps.setString(4, searchKeyword);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Book book = new Book();
                    book.setBookId(rs.getInt("id"));
                    book.setTitle(rs.getString("title"));
                    book.setAuthor(rs.getString("author"));
                    book.setCategory(rs.getString("category"));
                    book.setIsbn(rs.getString("isbn"));
                    book.setRackNo(rs.getString("rack_no"));
                    book.setPrice(rs.getDouble("price"));
                    book.setQuantity(rs.getInt("quantity"));
                    books.add(book);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return books;
    }

    public List<Book> searchBooks(String keyword) {
        List<Book> books = new ArrayList<>();

        String sql = "SELECT id, title, author, category, isbn, rack_no, price, quantity FROM books "
                + "WHERE is_deleted = 0 AND (title LIKE ? OR author LIKE ? OR category LIKE ? OR isbn LIKE ?) ORDER BY id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String searchKeyword = "%" + keyword + "%";
            ps.setString(1, searchKeyword);
            ps.setString(2, searchKeyword);
            ps.setString(3, searchKeyword);
            ps.setString(4, searchKeyword);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Book book = new Book();
                    book.setBookId(rs.getInt("id"));
                    book.setTitle(rs.getString("title"));
                    book.setAuthor(rs.getString("author"));
                    book.setCategory(rs.getString("category"));
                    book.setIsbn(rs.getString("isbn"));
                    book.setRackNo(rs.getString("rack_no"));
                    book.setPrice(rs.getDouble("price"));
                    book.setQuantity(rs.getInt("quantity"));
                    books.add(book);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return books;
    }

    public Book getBookById(int id) {
        String sql = "SELECT id, title, author, category, isbn, rack_no, price, quantity FROM books WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Book book = new Book();
                    book.setBookId(rs.getInt("id"));
                    book.setTitle(rs.getString("title"));
                    book.setAuthor(rs.getString("author"));
                    book.setCategory(rs.getString("category"));
                    book.setIsbn(rs.getString("isbn"));
                    book.setRackNo(rs.getString("rack_no"));
                    book.setPrice(rs.getDouble("price"));
                    book.setQuantity(rs.getInt("quantity"));
                    return book;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean isBookAvailable(int id) {
        String sql = "SELECT quantity FROM books WHERE id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("quantity") > 0;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateBook(Book book) {
        String sql = "UPDATE books SET title=?, author=?, category=?, isbn=?, rack_no=?, price=?, quantity=? WHERE id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, book.getTitle());
            ps.setString(2, book.getAuthor());
            ps.setString(3, book.getCategory());
            ps.setString(4, book.getIsbn());
            ps.setString(5, book.getRackNo());
            ps.setDouble(6, book.getPrice());
            ps.setInt(7, book.getQuantity());
            ps.setInt(8, book.getBookId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteBook(int id) {
        String sql = "UPDATE books SET is_deleted=1 WHERE id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getTotalBookCopies() {
        String sql = "SELECT IFNULL(SUM(quantity), 0) FROM books WHERE is_deleted = 0";

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

    public int getLowStockCount() {
        String sql = "SELECT COUNT(*) FROM books WHERE is_deleted = 0 AND quantity <= 2";

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

    public java.util.Map<String, Integer> getCategoryDistribution() {
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        String sql = "SELECT IFNULL(category, 'General') as cat, COUNT(*) as cnt " +
                     "FROM books WHERE is_deleted = 0 GROUP BY category ORDER BY cnt DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String cat = rs.getString("cat");
                if (cat == null || cat.isBlank()) cat = "General";
                map.put(cat, rs.getInt("cnt"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    public boolean isIsbnExists(String isbn, int excludeBookId) {
        String sql = "SELECT 1 FROM books WHERE isbn = ? AND id != ? AND is_deleted = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, isbn);
            ps.setInt(2, excludeBookId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}