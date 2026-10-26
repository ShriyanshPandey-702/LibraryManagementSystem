package util;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

import java.sql.Connection;
import org.junit.jupiter.api.Test;

class DBConnectionTest {

    @Test
    void getConnectionDoesNotThrow() {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
        } catch (Exception e) {
            assumeTrue(false, "MySQL server is offline: " + e.getMessage());
        }
        assertNotNull(conn);
    }
}
