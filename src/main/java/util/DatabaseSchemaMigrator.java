package util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
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
        addColumnIfNotExists(con, "issue_books", "fine_paid",           "TINYINT(1) NOT NULL DEFAULT 0");
        addColumnIfNotExists(con, "issue_books", "renew_count",         "INT NOT NULL DEFAULT 0");
        addColumnIfNotExists(con, "issue_books", "admin_issued_at",     "TIMESTAMP NULL");
        addColumnIfNotExists(con, "issue_books", "confirmed_at",        "TIMESTAMP NULL");
        addColumnIfNotExists(con, "issue_books", "rejection_reason",    "TEXT NULL");
        addColumnIfNotExists(con, "issue_books", "request_date",        "DATE NULL");

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

        // ── Books optional metadata columns ────────────────────────────────────
        addColumnIfNotExists(con, "books", "description",      "TEXT");
        addColumnIfNotExists(con, "books", "cover_image",      "VARCHAR(255)");
        addColumnIfNotExists(con, "books", "publisher",        "VARCHAR(150)");
        addColumnIfNotExists(con, "books", "publication_year", "INT");

        // ── System Settings ────────────────────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS system_settings (
                    setting_key   VARCHAR(50) PRIMARY KEY,
                    setting_value VARCHAR(100) NOT NULL
                )""");

        execute(con, "INSERT IGNORE INTO system_settings (setting_key, setting_value) VALUES ('fine_per_day', '5.00')");
        execute(con, "INSERT IGNORE INTO system_settings (setting_key, setting_value) VALUES ('renewal_days', '7')");
        execute(con, "INSERT IGNORE INTO system_settings (setting_key, setting_value) VALUES ('max_books_per_student', '3')");
        execute(con, "INSERT IGNORE INTO system_settings (setting_key, setting_value) VALUES ('reservation_pickup_days', '3')");
        // Widen status column to hold longer values like 'PendingConfirmation'
        try {
            execute(con, "ALTER TABLE issue_books MODIFY COLUMN status VARCHAR(30) NOT NULL DEFAULT 'Issued'");
        } catch (Exception ignored) { /* already wide enough */ }

        // ── Book Reviews & Ratings ─────────────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS book_reviews (
                    id          INT PRIMARY KEY AUTO_INCREMENT,
                    book_id     INT          NOT NULL,
                    student_id  INT          NOT NULL,
                    rating      INT          NOT NULL,
                    review_text TEXT,
                    is_hidden   TINYINT(1)   NOT NULL DEFAULT 0,
                    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    CONSTRAINT fk_review_book    FOREIGN KEY (book_id)    REFERENCES books(id)    ON DELETE CASCADE,
                    CONSTRAINT fk_review_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
                    CONSTRAINT uq_book_student_review UNIQUE (book_id, student_id)
                )""");

        // ── Lost or Damaged Book Reports ───────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS lost_damaged_reports (
                    id           INT PRIMARY KEY AUTO_INCREMENT,
                    issue_id     INT          NOT NULL,
                    book_id      INT          NOT NULL,
                    student_id   INT          NOT NULL,
                    copy_id      INT,
                    report_type  VARCHAR(20)  NOT NULL,
                    description  TEXT,
                    status       VARCHAR(20)  NOT NULL DEFAULT 'Pending',
                    admin_notes  TEXT,
                    fine_amount  DECIMAL(10,2) NOT NULL DEFAULT 0.00,
                    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    resolved_at  TIMESTAMP    NULL,
                    CONSTRAINT fk_ldr_issue   FOREIGN KEY (issue_id)   REFERENCES issue_books(id) ON DELETE CASCADE,
                    CONSTRAINT fk_ldr_book    FOREIGN KEY (book_id)    REFERENCES books(id)       ON DELETE CASCADE,
                    CONSTRAINT fk_ldr_student FOREIGN KEY (student_id) REFERENCES students(id)    ON DELETE CASCADE
                )""");

        // ── Book Reservations & Waiting Lists ──────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS book_reservations (
                    id               INT PRIMARY KEY AUTO_INCREMENT,
                    book_id          INT          NOT NULL,
                    student_id       INT          NOT NULL,
                    reservation_date TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    status           VARCHAR(20)  NOT NULL DEFAULT 'Waiting',
                    pickup_deadline  DATE,
                    notified         TINYINT(1)   NOT NULL DEFAULT 0,
                    CONSTRAINT fk_res_book    FOREIGN KEY (book_id)    REFERENCES books(id)    ON DELETE CASCADE,
                    CONSTRAINT fk_res_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
                )""");

        // ── Notifications ──────────────────────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS notifications (
                    id         INT PRIMARY KEY AUTO_INCREMENT,
                    user_id    INT          NOT NULL,
                    user_role  VARCHAR(20)  NOT NULL,
                    title      VARCHAR(150) NOT NULL,
                    message    TEXT         NOT NULL,
                    type       VARCHAR(50)  NOT NULL DEFAULT 'GENERAL',
                    link       VARCHAR(255),
                    is_read    TINYINT(1)   NOT NULL DEFAULT 0,
                    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
                )""");

        // ── Physical Book Copies & Barcodes ────────────────────────────────────
        execute(con, """
                CREATE TABLE IF NOT EXISTS book_copies (
                    id               INT PRIMARY KEY AUTO_INCREMENT,
                    book_id          INT          NOT NULL,
                    copy_number      INT          NOT NULL,
                    barcode_id       VARCHAR(50)  NOT NULL UNIQUE,
                    status           VARCHAR(20)  NOT NULL DEFAULT 'Available',
                    condition_notes  VARCHAR(255) DEFAULT 'Good condition',
                    acquisition_date DATE         NOT NULL DEFAULT (CURRENT_DATE),
                    CONSTRAINT fk_copy_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
                )""");

        addColumnIfNotExists(con, "issue_books", "copy_id", "INT NULL");

        // Backfill physical copies for existing books with quantity > 0
        backfillBookCopies(con);

        // ── Seed admin with BCrypt-hashed password ────────────────────────────
        seedAdmin(con);
    }

    /** Backfills book_copies for any existing books missing copy records. */
    private static void backfillBookCopies(Connection con) throws SQLException {
        String selectSql = "SELECT b.id, b.quantity FROM books b WHERE b.is_deleted = 0 AND b.quantity > 0 " +
                           "AND NOT EXISTS (SELECT 1 FROM book_copies bc WHERE bc.book_id = b.id)";
        String insertSql = "INSERT IGNORE INTO book_copies (book_id, copy_number, barcode_id, status) VALUES (?, ?, ?, 'Available')";

        try (Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(selectSql);
             PreparedStatement ps = con.prepareStatement(insertSql)) {
            while (rs.next()) {
                int bookId = rs.getInt("id");
                int qty = rs.getInt("quantity");
                for (int c = 1; c <= qty; c++) {
                    ps.setInt(1, bookId);
                    ps.setInt(2, c);
                    ps.setString(3, "BC-" + bookId + "-" + String.format("%03d", c));
                    ps.addBatch();
                }
            }
            ps.executeBatch();
        }
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
