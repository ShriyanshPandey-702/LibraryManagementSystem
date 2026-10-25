package util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * Database connection manager using HikariCP connection pool.
 * Configuration can be overridden via environment variables or system properties.
 */
public final class DBConnection {

    private static final Logger log = LoggerFactory.getLogger(DBConnection.class);

    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/library_management" +
            "?createDatabaseIfNotExist=true" +
            "&useSSL=false" +
            "&allowPublicKeyRetrieval=true" +
            "&serverTimezone=UTC" +
            "&characterEncoding=UTF-8";
    private static final String DEFAULT_USER     = "root";
    private static final String DEFAULT_PASSWORD = "newmac000";

    private static volatile HikariDataSource dataSource;
    private static volatile boolean schemaReady = false;

    private DBConnection() {}

    /** Returns the HikariCP data source, initializing it lazily on first call. */
    private static HikariDataSource getDataSource() {
        if (dataSource == null) {
            synchronized (DBConnection.class) {
                if (dataSource == null) {
                    HikariConfig config = new HikariConfig();
                    config.setJdbcUrl(getEnvOrProp("DB_URL", "db.url", DEFAULT_URL));
                    config.setUsername(getEnvOrProp("DB_USER", "db.user", DEFAULT_USER));
                    config.setPassword(getEnvOrProp("DB_PASSWORD", "db.password", DEFAULT_PASSWORD));
                    config.setDriverClassName("com.mysql.cj.jdbc.Driver");

                    // Pool settings
                    config.setMaximumPoolSize(10);
                    config.setMinimumIdle(3);
                    config.setConnectionTimeout(30_000);
                    config.setIdleTimeout(600_000);
                    config.setMaxLifetime(1_800_000);
                    config.setLeakDetectionThreshold(60_000);
                    config.setPoolName("LibraryPool");
                    config.addDataSourceProperty("cachePrepStmts", "true");
                    config.addDataSourceProperty("prepStmtCacheSize", "250");
                    config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");

                    dataSource = new HikariDataSource(config);
                    log.info("HikariCP connection pool initialized successfully.");
                }
            }
        }
        return dataSource;
    }

    /**
     * Returns a connection from the pool. Run schema migration on very first call.
     * Caller MUST close the connection (use try-with-resources).
     */
    public static Connection getConnection() throws SQLException {
        Connection con = getDataSource().getConnection();

        if (!schemaReady) {
            synchronized (DBConnection.class) {
                if (!schemaReady) {
                    try {
                        DatabaseSchemaMigrator.migrate(con);
                        schemaReady = true;
                        log.info("Database schema migration completed.");
                    } catch (SQLException e) {
                        log.error("Schema migration failed", e);
                        throw e;
                    }
                }
            }
        }
        return con;
    }

    /** Closes the pool gracefully (call on application shutdown). */
    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            log.info("HikariCP pool closed.");
        }
    }

    private static String getEnvOrProp(String envKey, String propKey, String defaultValue) {
        String env = System.getenv(envKey);
        if (env != null && !env.isBlank()) return env;
        return System.getProperty(propKey, defaultValue);
    }
}