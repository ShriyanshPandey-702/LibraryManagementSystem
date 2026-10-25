package util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility class for secure password hashing and verification using BCrypt.
 */
public final class PasswordUtil {

    private static final int BCRYPT_ROUNDS = 12;

    private PasswordUtil() {}

    /**
     * Hashes a plain-text password using BCrypt.
     * @param plainPassword the raw password
     * @return the BCrypt hash string
     */
    public static String hash(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_ROUNDS));
    }

    /**
     * Verifies a plain-text password against a stored BCrypt hash.
     * @param plainPassword the raw password to check
     * @param hashedPassword the stored BCrypt hash
     * @return true if the password matches
     */
    public static boolean verify(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) return false;
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            // Not a valid BCrypt hash (e.g. plain-text legacy password)
            return false;
        }
    }

    /**
     * Determines if a stored password string is a BCrypt hash.
     * Used to migrate legacy plain-text passwords on first login.
     * @param password the stored password string
     * @return true if it looks like a BCrypt hash
     */
    public static boolean isBcryptHash(String password) {
        return password != null && password.startsWith("$2a$") || 
               (password != null && password.startsWith("$2b$")) ||
               (password != null && password.startsWith("$2y$"));
    }
}
