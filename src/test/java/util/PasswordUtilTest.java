package util;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class PasswordUtilTest {

    @Test
    public void testHashAndVerifySuccess() {
        String raw = "librarySecret2026";
        String hash = PasswordUtil.hash(raw);

        assertNotNull(hash);
        assertTrue(PasswordUtil.isBcryptHash(hash));
        assertTrue(PasswordUtil.verify(raw, hash));
        assertFalse(PasswordUtil.verify("wrongPassword", hash));
    }

    @Test
    public void testNullHandling() {
        assertFalse(PasswordUtil.verify(null, "hash"));
        assertFalse(PasswordUtil.verify("password", null));
        assertFalse(PasswordUtil.isBcryptHash(null));
        assertFalse(PasswordUtil.isBcryptHash("plainText"));
    }
}
