package util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Handles database schema creation and incremental migrations.
 * Every change is idempotent — safe to run on every startup.
 */
public final class DatabaseSchemaMigrator {

    private static final Logger log = LoggerFactory.getLogger(DatabaseSchemaMigrator.class);

    private DatabaseSchemaMigrator() {}

    public static void migrate(Connection con) throws SQLException {

        // ── Admin ──────────────────────────────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS admin (
                    admin_id  INT PRIMARY KEY AUTO_INCREMENT,
                    username  VARCHAR(50)  NOT NULL UNIQUE,
                    password  VARCHAR(255) NOT NULL
                )""");

        // ── Books ──────────────────────────────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS books (
                    id         INT PRIMARY KEY AUTO_INCREMENT,
                    title      VARCHAR(150) NOT NULL,
                    author     VARCHAR(120) NOT NULL,
                    category   VARCHAR(100),
                    isbn       VARCHAR(50),
                    rack_no    VARCHAR(50),
                    price      DECIMAL(10,2) NOT NULL DEFAULT 0.00,
                    quantity   INT           NOT NULL DEFAULT 0,
                    is_deleted TINYINT(1)    NOT NULL DEFAULT 0
                )""");

        addColumnIfNotExists(con, "books", "is_deleted", "TINYINT(1) NOT NULL DEFAULT 0");

        // ── Students ───────────────────────────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS students (
                    id       INT PRIMARY KEY AUTO_INCREMENT,
                    name     VARCHAR(100) NOT NULL,
                    email    VARCHAR(100) NOT NULL UNIQUE,
                    mobile   VARCHAR(20),
                    password VARCHAR(255) NOT NULL,
                    course   VARCHAR(50),
                    `year`   VARCHAR(20),
                    section  VARCHAR(20),
                    address  TEXT,
                    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )""");

        addColumnIfNotExists(con, "students", "created_at",
                "TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP");

        // ── Issue Books ────────────────────────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS issue_books (
                    id              INT PRIMARY KEY AUTO_INCREMENT,
                    book_id         INT          NOT NULL,
                    student_id      INT          NOT NULL,
                    student_name    VARCHAR(100),
                    student_contact VARCHAR(100),
                    course          VARCHAR(50),
                    `year`          VARCHAR(20),
                    section         VARCHAR(20),
                    issue_date      DATE         NOT NULL,
                    due_date        DATE         NOT NULL,
                    return_date     DATE,
                    fine            DECIMAL(10,2) DEFAULT 0.00,
                    status          VARCHAR(20)  NOT NULL DEFAULT 'Issued',
                    returned        TINYINT(1)   NOT NULL DEFAULT 0,
                    fine_paid       TINYINT(1)   NOT NULL DEFAULT 0,
                    renew_count     INT          NOT NULL DEFAULT 0,
                    CONSTRAINT fk_issue_book    FOREIGN KEY (book_id)    REFERENCES books(id)    ON DELETE CASCADE,
                    CONSTRAINT fk_issue_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
                )""");

        addColumnIfNotExists(con, "issue_books", "student_name",    "VARCHAR(100)");
        addColumnIfNotExists(con, "issue_books", "student_contact", "VARCHAR(100)");
        addColumnIfNotExists(con, "issue_books", "course",          "VARCHAR(50)");
        addColumnIfNotExists(con, "issue_books", "year",            "VARCHAR(20)");
        addColumnIfNotExists(con, "issue_books", "section",         "VARCHAR(20)");
        addColumnIfNotExists(con, "issue_books", "fine_paid",       "TINYINT(1) NOT NULL DEFAULT 0");
        addColumnIfNotExists(con, "issue_books", "renew_count",     "INT NOT NULL DEFAULT 0");

        // ── Book Requests ──────────────────────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS book_requests (
                    id           INT PRIMARY KEY AUTO_INCREMENT,
                    student_id   INT          NOT NULL,
                    student_name VARCHAR(100),
                    course       VARCHAR(50),
                    `year`       VARCHAR(20),
                    book_id      INT          NOT NULL,
                    book_title   VARCHAR(150),
                    request_date DATE         NOT NULL,
                    status       VARCHAR(20)  NOT NULL DEFAULT 'Pending',
                    CONSTRAINT fk_request_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
                    CONSTRAINT fk_request_book    FOREIGN KEY (book_id)    REFERENCES books(id)    ON DELETE CASCADE
                )""");

        addColumnIfNotExists(con, "book_requests", "student_name", "VARCHAR(100)");
        addColumnIfNotExists(con, "book_requests", "course",       "VARCHAR(50)");
        addColumnIfNotExists(con, "book_requests", "year",         "VARCHAR(20)");
        addColumnIfNotExists(con, "book_requests", "book_title",   "VARCHAR(150)");

        // ── Fine Settings ──────────────────────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS fine_settings (
                    id           INT PRIMARY KEY,
                    fine_per_day DECIMAL(10,2) NOT NULL DEFAULT 5.00
                )""");

        execute(con, "INSERT IGNORE INTO fine_settings (id, fine_per_day) VALUES (1, 5.00)");

        // ── Seed admin with BCrypt-hashed password ────────────────────────────
        seedAdmin(con);
    }

    /** Seeds the default admin if it does not exist yet, using a BCrypt hash. */
    private static void seedAdmin(Connection con) throws SQLException {
        String checkSql = "SELECT COUNT(*) FROM admin WHERE username = 'admin'";
        try (Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(checkSql)) {
            if (rs.next() && rs.getInt(1) == 0) {
                String hash = PasswordUtil.hash("admin123");
                String insertSql = "INSERT INTO admin (username, password) VALUES ('admin', '" + hash + "')";
                st.execute(insertSql);
                log.info("Default admin account created with BCrypt-hashed password.");
            }
        }
    }

    private static void addColumnIfNotExists(Connection con, String tableName, String columnName,
                                             String columnDefinition) throws SQLException {
        String sql = "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS " +
                     "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '" + tableName +
                     "' AND COLUMN_NAME = '" + columnName + "'";
        try (Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (!rs.next()) {
                st.execute("ALTER TABLE " + tableName + " ADD COLUMN " + columnName + " " + columnDefinition);
                log.info("Added column {}.{}", tableName, columnName);
            }
        }
    }

    private static void execute(Connection con, String sql) throws SQLException {
        try (Statement st = con.createStatement()) {
            st.execute(sql);
        }
    }
}
