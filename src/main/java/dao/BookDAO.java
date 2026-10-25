package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;

import model.Book;
import util.DBConnection;

public class BookDAO {

    public boolean addBook(Book book) {
        String sql = "INSERT INTO books (title, author, category, isbn, rack_no, price, quantity, description, cover_image, publisher, publication_year) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, book.getTitle() != null ? book.getTitle().trim() : "");
            ps.setString(2, book.getAuthor() != null ? book.getAuthor().trim() : "");
            setNullableString(ps, 3, book.getCategory());
            setNullableString(ps, 4, book.getIsbn());
            setNullableString(ps, 5, book.getRackNo());
            ps.setDouble(6, book.getPrice());
            ps.setInt(7, book.getQuantity());
            setNullableString(ps, 8, book.getDescription());
            setNullableString(ps, 9, book.getCoverImage());
            setNullableString(ps, 10, book.getPublisher());
            if (book.getPublicationYear() != null && book.getPublicationYear() > 0) {
                ps.setInt(11, book.getPublicationYear());
            } else {
                ps.setNull(11, Types.INTEGER);
            }

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int newBookId = generatedKeys.getInt(1);
                        book.setBookId(newBookId);
                        // Generate physical copies
                        if (book.getQuantity() > 0) {
                            new BookCopyDAO().createCopies(newBookId, book.getQuantity());
                        }
                    }
                }
                return true;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateBook(Book book) {
        String sql = "UPDATE books SET title=?, author=?, category=?, isbn=?, rack_no=?, price=?, quantity=?, " +
                     "description=?, cover_image=COALESCE(?, cover_image), publisher=?, publication_year=? WHERE id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, book.getTitle() != null ? book.getTitle().trim() : "");
            ps.setString(2, book.getAuthor() != null ? book.getAuthor().trim() : "");
            setNullableString(ps, 3, book.getCategory());
            setNullableString(ps, 4, book.getIsbn());
            setNullableString(ps, 5, book.getRackNo());
            ps.setDouble(6, book.getPrice());
            ps.setInt(7, book.getQuantity());
            setNullableString(ps, 8, book.getDescription());
            setNullableString(ps, 9, book.getCoverImage());
            setNullableString(ps, 10, book.getPublisher());
            if (book.getPublicationYear() != null && book.getPublicationYear() > 0) {
                ps.setInt(11, book.getPublicationYear());
            } else {
                ps.setNull(11, Types.INTEGER);
            }
            ps.setInt(12, book.getBookId());

            int updated = ps.executeUpdate();
            if (updated > 0) {
                // Ensure physical copies exist matching at least the quantity
                new BookCopyDAO().createCopies(book.getBookId(), 0); // safe no-op or backfill
                return true;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Book> getAllBooks() {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.id, b.title, b.author, b.category, b.isbn, b.rack_no, b.price, b.quantity, " +
                     "b.description, b.cover_image, b.publisher, b.publication_year, " +
                     "COALESCE(AVG(r.rating), 0.0) as avg_rating, COUNT(r.id) as review_count " +
                     "FROM books b LEFT JOIN book_reviews r ON b.id = r.book_id AND r.is_hidden = 0 " +
                     "WHERE b.is_deleted = 0 GROUP BY b.id ORDER BY b.id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                books.add(mapBook(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return books;
    }

    public List<Book> getAvailableBooks() {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.id, b.title, b.author, b.category, b.isbn, b.rack_no, b.price, b.quantity, " +
                     "b.description, b.cover_image, b.publisher, b.publication_year, " +
                     "COALESCE(AVG(r.rating), 0.0) as avg_rating, COUNT(r.id) as review_count " +
                     "FROM books b LEFT JOIN book_reviews r ON b.id = r.book_id AND r.is_hidden = 0 " +
                     "WHERE b.is_deleted = 0 AND b.quantity > 0 GROUP BY b.id ORDER BY b.id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                books.add(mapBook(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return books;
    }

    public Book getBookById(int id) {
        String sql = "SELECT b.id, b.title, b.author, b.category, b.isbn, b.rack_no, b.price, b.quantity, " +
                     "b.description, b.cover_image, b.publisher, b.publication_year, " +
                     "COALESCE(AVG(r.rating), 0.0) as avg_rating, COUNT(r.id) as review_count " +
                     "FROM books b LEFT JOIN book_reviews r ON b.id = r.book_id AND r.is_hidden = 0 " +
                     "WHERE b.id = ? AND b.is_deleted = 0 GROUP BY b.id";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapBook(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    /** Advanced search with multiple filters, sorting, and pagination */
    public List<Book> searchBooksAdvanced(String keyword, String category, String availability,
                                          Integer minRating, Integer year, String sortBy,
                                          int offset, int limit) {
        List<Book> books = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT b.id, b.title, b.author, b.category, b.isbn, b.rack_no, b.price, b.quantity, " +
            "b.description, b.cover_image, b.publisher, b.publication_year, " +
            "COALESCE(AVG(r.rating), 0.0) as avg_rating, COUNT(r.id) as review_count " +
            "FROM books b LEFT JOIN book_reviews r ON b.id = r.book_id AND r.is_hidden = 0 " +
            "WHERE b.is_deleted = 0 "
        );

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (b.title LIKE ? OR b.author LIKE ? OR b.isbn LIKE ? OR b.category LIKE ? OR b.publisher LIKE ? OR b.description LIKE ?) ");
            String term = "%" + keyword.trim() + "%";
            for (int i = 0; i < 6; i++) params.add(term);
        }

        if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
            sql.append("AND b.category = ? ");
            params.add(category.trim());
        }

        if ("available".equalsIgnoreCase(availability)) {
            sql.append("AND b.quantity > 0 ");
        }

        if (year != null && year > 0) {
            sql.append("AND b.publication_year = ? ");
            params.add(year);
        }

        sql.append("GROUP BY b.id ");

        if (minRating != null && minRating > 0) {
            sql.append("HAVING avg_rating >= ? ");
            params.add(minRating.doubleValue());
        }

        // Sorting
        if ("title_asc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY b.title ASC ");
        } else if ("title_desc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY b.title DESC ");
        } else if ("author_asc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY b.author ASC ");
        } else if ("rating_desc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY avg_rating DESC, review_count DESC ");
        } else if ("year_desc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY b.publication_year DESC, b.id DESC ");
        } else {
            sql.append("ORDER BY b.id DESC ");
        }

        sql.append("LIMIT ? OFFSET ?");
        params.add(limit > 0 ? limit : 20);
        params.add(offset >= 0 ? offset : 0);

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    books.add(mapBook(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return books;
    }

    public List<String> getAllCategories() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM books WHERE is_deleted = 0 AND category IS NOT NULL AND category != '' ORDER BY category ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("category"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean isBookAvailable(int id) {
        String sql = "SELECT quantity FROM books WHERE id = ? AND is_deleted = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("quantity") > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
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

    public int getTotalBookTitles() {
        String sql = "SELECT COUNT(*) FROM books WHERE is_deleted = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTotalBookCopies() {
        String sql = "SELECT IFNULL(SUM(quantity), 0) FROM books WHERE is_deleted = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
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
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Map<String, Integer> getCategoryDistribution() {
        Map<String, Integer> map = new LinkedHashMap<>();
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
        if (isbn == null || isbn.trim().isEmpty()) return false;
        String sql = "SELECT 1 FROM books WHERE isbn = ? AND id != ? AND is_deleted = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, isbn.trim());
            ps.setInt(2, excludeBookId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private void setNullableString(PreparedStatement ps, int paramIndex, String value) throws Exception {
        if (value == null || value.trim().isEmpty()) {
            ps.setNull(paramIndex, Types.VARCHAR);
        } else {
            ps.setString(paramIndex, value.trim());
        }
    }

    private Book mapBook(ResultSet rs) throws Exception {
        Book book = new Book();
        book.setBookId(rs.getInt("id"));
        book.setTitle(rs.getString("title"));
        book.setAuthor(rs.getString("author"));
        book.setCategory(rs.getString("category"));
        book.setIsbn(rs.getString("isbn"));
        book.setRackNo(rs.getString("rack_no"));
        book.setPrice(rs.getDouble("price"));
        book.setQuantity(rs.getInt("quantity"));
        book.setDescription(rs.getString("description"));
        book.setCoverImage(rs.getString("cover_image"));
        book.setPublisher(rs.getString("publisher"));
        int yr = rs.getInt("publication_year");
        book.setPublicationYear(rs.wasNull() ? null : yr);
        book.setAverageRating(rs.getDouble("avg_rating"));
        book.setReviewCount(rs.getInt("review_count"));
        return book;
    }
}