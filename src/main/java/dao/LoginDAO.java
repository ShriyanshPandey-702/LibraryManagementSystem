package dao;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import util.DBConnection;
import util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * DAO for admin authentication operations.
 * Passwords are stored as BCrypt hashes.
 * Legacy plain-text passwords are migrated transparently on first successful login.
 */
public class LoginDAO {

    private static final Logger log = LoggerFactory.getLogger(LoginDAO.class);

    /**
     * Validates admin credentials.
     * Handles transparent migration from plain-text to BCrypt on first login.
     */
    public boolean validateAdmin(String username, String password) {
        String sql = "SELECT password FROM admin WHERE username = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String stored = rs.getString("password");
                    if (PasswordUtil.isBcryptHash(stored)) {
                        return PasswordUtil.verify(password, stored);
                    } else {
                        // Legacy plain-text — verify then upgrade
                        if (stored.equals(password)) {
                            upgradePlainTextPassword(username, password);
                            return true;
                        }
                        return false;
                    }
                }
            }
        } catch (SQLException e) {
            log.error("Error validating admin credentials", e);
        }
        return false;
    }

    public boolean adminExists(String username) {
        String sql = "SELECT 1 FROM admin WHERE username = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            log.error("Error checking admin existence", e);
            return false;
        }
    }

    /**
     * Updates admin password stored as a BCrypt hash.
     */
    public boolean updateAdminPassword(String username, String newPassword) {
        String sql = "UPDATE admin SET password = ? WHERE username = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hash(newPassword));
            ps.setString(2, username);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            log.error("Error updating admin password", e);
            return false;
        }
    }

    /** Migrates a plain-text password to a BCrypt hash in the database. */
    private void upgradePlainTextPassword(String username, String plainPassword) {
        String sql = "UPDATE admin SET password = ? WHERE username = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hash(plainPassword));
            ps.setString(2, username);
            ps.executeUpdate();
            log.info("Upgraded admin '{}' password to BCrypt hash.", username);
        } catch (SQLException e) {
            log.error("Failed to upgrade admin password to BCrypt", e);
        }
    }
}
