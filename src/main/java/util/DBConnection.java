package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/library_management?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "newmac000";

    private static volatile boolean schemaReady = false;

    private static String getJdbcUrl() {
        String env = System.getenv("DB_URL");
        if (env != null && !env.trim().isEmpty()) return env;
        return System.getProperty("db.url", DEFAULT_URL);
    }

    private static String getJdbcUser() {
        String env = System.getenv("DB_USER");
        if (env != null && !env.trim().isEmpty()) return env;
        return System.getProperty("db.user", DEFAULT_USER);
    }

    private static String getJdbcPassword() {
        String env = System.getenv("DB_PASSWORD");
        if (env != null) return env;
        return System.getProperty("db.password", DEFAULT_PASSWORD);
    }

    public static Connection getConnection() {
        Connection con = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            con = DriverManager.getConnection(getJdbcUrl(), getJdbcUser(), getJdbcPassword());

            if (!schemaReady) {
                synchronized (DBConnection.class) {
                    if (!schemaReady) {
                        DatabaseSchemaMigrator.migrate(con);
                        schemaReady = true;
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return con;
    }
}