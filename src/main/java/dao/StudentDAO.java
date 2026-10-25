package dao;

import model.Student;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import util.DBConnection;
import util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for student operations.
 * All passwords are stored as BCrypt hashes.
 */
public class StudentDAO {

    private static final Logger log = LoggerFactory.getLogger(StudentDAO.class);

    public boolean registerStudent(String name, String email, String mobile, String password,
                                   String course, String year, String section, String address) {
        String sql = "INSERT INTO students(name, email, mobile, password, course, `year`, section, address) " +
                     "VALUES(?,?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name.trim());
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, mobile != null ? mobile.trim() : "");
            ps.setString(4, PasswordUtil.hash(password));   // BCrypt hash
            ps.setString(5, course != null ? course.trim() : "");
            ps.setString(6, year != null ? year.trim() : "");
            ps.setString(7, section != null ? section.trim() : "");
            ps.setString(8, address != null ? address.trim() : "");

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            log.error("Error registering student", e);
            return false;
        }
    }

    /**
     * Validates student login with BCrypt verification.
     * Also migrates legacy plain-text passwords transparently.
     */
    public boolean validateStudent(String email, String password) {
        String sql = "SELECT id, password FROM students WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String stored = rs.getString("password");
                    int id = rs.getInt("id");
                    if (PasswordUtil.isBcryptHash(stored)) {
                        return PasswordUtil.verify(password, stored);
                    } else {
                        // Legacy plain-text migration
                        if (stored.equals(password)) {
                            upgradePlainTextPassword(id, password);
                            return true;
                        }
                        return false;
                    }
                }
            }
        } catch (SQLException e) {
            log.error("Error validating student credentials", e);
        }
        return false;
    }

    public boolean studentExistsByEmail(String email) {
        String sql = "SELECT 1 FROM students WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            log.error("Error checking student by email", e);
            return false;
        }
    }

    public boolean updateStudentPassword(String email, String newPassword) {
        String sql = "UPDATE students SET password = ? WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hash(newPassword));
            ps.setString(2, email.trim().toLowerCase());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            log.error("Error updating student password", e);
            return false;
        }
    }

    public List<Student> getAllStudents() {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT * FROM students ORDER BY name";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                students.add(mapRow(rs));
            }
        } catch (SQLException e) {
            log.error("Error fetching all students", e);
        }
        return students;
    }

    public Student getStudentById(int id) {
        String sql = "SELECT * FROM students WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            log.error("Error fetching student by id={}", id, e);
        }
        return null;
    }

    public Student getStudentByEmail(String email) {
        String sql = "SELECT * FROM students WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            log.error("Error fetching student by email", e);
        }
        return null;
    }

    public int countStudents() {
        String sql = "SELECT COUNT(*) FROM students";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            log.error("Error counting students", e);
        }
        return 0;
    }

    // ── private helpers ────────────────────────────────────────────────────────

    private Student mapRow(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setId(rs.getInt("id"));
        s.setName(rs.getString("name"));
        s.setEmail(rs.getString("email"));
        s.setMobile(rs.getString("mobile"));
        s.setCourse(rs.getString("course"));
        s.setYear(rs.getString("year"));
        s.setSection(rs.getString("section"));
        s.setAddress(rs.getString("address"));
        return s;
    }

    private void upgradePlainTextPassword(int studentId, String plainPassword) {
        String sql = "UPDATE students SET password = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hash(plainPassword));
            ps.setInt(2, studentId);
            ps.executeUpdate();
            log.info("Upgraded student id={} password to BCrypt hash.", studentId);
        } catch (SQLException e) {
            log.error("Failed to upgrade student password to BCrypt", e);
        }
    }
}
