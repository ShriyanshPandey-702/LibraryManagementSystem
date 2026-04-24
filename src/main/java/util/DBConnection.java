package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String url = "jdbc:mysql://localhost:3306/library_management";
    private static final String USER = "root";
    private static final String PASSWORD = "newmac000";
    private static volatile boolean schemaReady = false;

    public static Connection getConnection() {
        Connection con = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            con = DriverManager.getConnection(url, USER, PASSWORD);

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