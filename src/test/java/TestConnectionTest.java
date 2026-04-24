import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;

import org.junit.jupiter.api.Test;

class TestConnectionTest {

    @Test
    void mainDoesNotThrow() {
        assertDoesNotThrow(() -> TestConnection.main(new String[0]));
    }
}
