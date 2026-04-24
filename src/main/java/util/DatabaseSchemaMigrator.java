package util;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

public final class DatabaseSchemaMigrator {

    private DatabaseSchemaMigrator() {
    }

    public static void migrate(Connection con) throws SQLException {
        // Admin table
        execute(con, "CREATE TABLE IF NOT EXISTS admin (admin_id INT PRIMARY KEY AUTO_INCREMENT, username VARCHAR(50) NOT NULL UNIQUE, password VARCHAR(100) NOT NULL)");
        
        // Books table
        execute(con, "CREATE TABLE IF NOT EXISTS books (id INT PRIMARY KEY AUTO_INCREMENT, title VARCHAR(150) NOT NULL, author VARCHAR(120) NOT NULL, category VARCHAR(100), isbn VARCHAR(50), rack_no VARCHAR(50), price DECIMAL(10,2) NOT NULL DEFAULT 0.00, quantity INT NOT NULL DEFAULT 0)");
        
        // Students table
        execute(con, "CREATE TABLE IF NOT EXISTS students (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL UNIQUE, mobile VARCHAR(20), password VARCHAR(100) NOT NULL, course VARCHAR(50), `year` VARCHAR(20), section VARCHAR(20), address TEXT)");

        // Issue Books table (with all metadata columns)
        execute(con, "CREATE TABLE IF NOT EXISTS issue_books (id INT PRIMARY KEY AUTO_INCREMENT, book_id INT NOT NULL, student_id INT NOT NULL, student_name VARCHAR(100), student_contact VARCHAR(100), course VARCHAR(50), `year` VARCHAR(20), section VARCHAR(20), issue_date DATE NOT NULL, due_date DATE NOT NULL, return_date DATE, fine DECIMAL(10,2) DEFAULT 0.00, status VARCHAR(20) NOT NULL DEFAULT 'Issued', returned TINYINT(1) NOT NULL DEFAULT 0, CONSTRAINT fk_issue_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE, CONSTRAINT fk_issue_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE)");
        
        // Ensure columns exist in issue_books if table was created previously with fewer columns
        addColumnIfNotExists(con, "issue_books", "student_name", "VARCHAR(100)");
        addColumnIfNotExists(con, "issue_books", "student_contact", "VARCHAR(100)");
        addColumnIfNotExists(con, "issue_books", "course", "VARCHAR(50)");
        addColumnIfNotExists(con, "issue_books", "year", "VARCHAR(20)");
        addColumnIfNotExists(con, "issue_books", "section", "VARCHAR(20)");

        // Book Requests table
        execute(con, "CREATE TABLE IF NOT EXISTS book_requests (id INT PRIMARY KEY AUTO_INCREMENT, student_id INT NOT NULL, student_name VARCHAR(100), course VARCHAR(50), `year` VARCHAR(20), book_id INT NOT NULL, book_title VARCHAR(150), request_date DATE NOT NULL, status VARCHAR(20) NOT NULL DEFAULT 'Pending', CONSTRAINT fk_request_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE, CONSTRAINT fk_request_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE)");
        
        addColumnIfNotExists(con, "book_requests", "student_name", "VARCHAR(100)");
        addColumnIfNotExists(con, "book_requests", "course", "VARCHAR(50)");
        addColumnIfNotExists(con, "book_requests", "year", "VARCHAR(20)");
        addColumnIfNotExists(con, "book_requests", "book_title", "VARCHAR(150)");

        // Fine Settings
        execute(con, "CREATE TABLE IF NOT EXISTS fine_settings (id INT PRIMARY KEY, fine_per_day DECIMAL(10,2) NOT NULL DEFAULT 5.00)");

        execute(con, "INSERT IGNORE INTO fine_settings (id, fine_per_day) VALUES (1, 5.00)");
        execute(con, "INSERT IGNORE INTO admin (username, password) VALUES ('admin', 'admin123')");
    }

    private static void addColumnIfNotExists(Connection con, String tableName, String columnName, String columnType) throws SQLException {
        String sql = "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '" + tableName + "' AND COLUMN_NAME = '" + columnName + "'";
        try (Statement st = con.createStatement();
             java.sql.ResultSet rs = st.executeQuery(sql)) {
            if (!rs.next()) {
                st.execute("ALTER TABLE " + tableName + " ADD COLUMN " + columnName + " " + columnType);
            }
        }
    }

    private static void execute(Connection con, String sql) throws SQLException {
        try (Statement st = con.createStatement()) {
            st.execute(sql);
        }
    }
}
