package util;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

import org.junit.jupiter.api.Test;

class DBConnectionTest {

    @Test
    void getConnectionDoesNotThrow() {
        assertDoesNotThrow(DBConnection::getConnection);
    }
}
