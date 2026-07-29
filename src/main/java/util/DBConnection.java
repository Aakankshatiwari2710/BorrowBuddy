package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.net.URI;

public class DBConnection {

    public static Connection getConnection() {
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Environment Variables check for Render, Railway, Aiven, PlanetScale, CleverCloud, etc.
            String dbUrl = System.getenv("DB_URL");
            if (dbUrl == null || dbUrl.isEmpty()) dbUrl = System.getenv("MYSQL_URL");
            if (dbUrl == null || dbUrl.isEmpty()) dbUrl = System.getenv("MYSQL_PUBLIC_URL");
            if (dbUrl == null || dbUrl.isEmpty()) dbUrl = System.getenv("DATABASE_URL");
            if (dbUrl == null || dbUrl.isEmpty()) dbUrl = System.getenv("JAWSDB_URL");
            if (dbUrl == null || dbUrl.isEmpty()) dbUrl = System.getenv("CLEARDB_DATABASE_URL");
            
            String dbUser = System.getenv("DB_USER");
            if (dbUser == null || dbUser.isEmpty()) dbUser = System.getenv("MYSQL_USER");
            if (dbUser == null || dbUser.isEmpty()) dbUser = System.getenv("MYSQLUSER");

            String dbPassword = System.getenv("DB_PASSWORD");
            if (dbPassword == null || dbPassword.isEmpty()) dbPassword = System.getenv("MYSQL_PASSWORD");
            if (dbPassword == null || dbPassword.isEmpty()) dbPassword = System.getenv("MYSQLPASSWORD");

            String dbHost = System.getenv("MYSQL_HOST");
            if (dbHost == null || dbHost.isEmpty()) dbHost = System.getenv("MYSQLHOST");

            String dbPort = System.getenv("MYSQL_PORT");
            if (dbPort == null || dbPort.isEmpty()) dbPort = System.getenv("MYSQLPORT");
            if (dbPort == null || dbPort.isEmpty()) dbPort = "3306";

            String dbName = System.getenv("MYSQL_DATABASE");
            if (dbName == null || dbName.isEmpty()) dbName = System.getenv("MYSQLDATABASE");
            if (dbName == null || dbName.isEmpty()) dbName = "sharesphere";

            // Parse mysql:// URLs into valid JDBC format
            if (dbUrl != null && !dbUrl.trim().isEmpty()) {
                if (dbUrl.startsWith("mysql://") || dbUrl.startsWith("mariadb://")) {
                    try {
                        URI uri = new URI(dbUrl);
                        if (uri.getUserInfo() != null && uri.getUserInfo().contains(":")) {
                            String[] userInfo = uri.getUserInfo().split(":", 2);
                            if (dbUser == null || dbUser.isEmpty()) dbUser = userInfo[0];
                            if (dbPassword == null || dbPassword.isEmpty()) dbPassword = userInfo[1];
                        }
                        String host = uri.getHost();
                        int port = uri.getPort() > 0 ? uri.getPort() : 3306;
                        String path = uri.getPath();
                        if (path != null && path.startsWith("/")) path = path.substring(1);
                        if (path == null || path.isEmpty()) path = dbName;

                        dbUrl = "jdbc:mysql://" + host + ":" + port + "/" + path + "?useSSL=false&allowPublicKeyRetrieval=true&autoReconnect=true";
                    } catch (Exception e) {
                        dbUrl = "jdbc:" + dbUrl;
                    }
                } else if (!dbUrl.startsWith("jdbc:")) {
                    dbUrl = "jdbc:mysql://" + dbUrl;
                }
            } else if (dbHost != null && !dbHost.trim().isEmpty()) {
                dbUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + "?useSSL=false&allowPublicKeyRetrieval=true&autoReconnect=true";
            } else {
                dbUrl = "jdbc:mysql://localhost:3306/" + dbName + "?useSSL=false&allowPublicKeyRetrieval=true&autoReconnect=true";
            }

            if (!dbUrl.contains("autoReconnect=true")) {
                dbUrl += (dbUrl.contains("?") ? "&" : "?") + "autoReconnect=true&allowPublicKeyRetrieval=true";
            }
            
            if (dbUser == null) dbUser = "root";
            if (dbPassword == null) dbPassword = "";

            con = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
            System.out.println("✅ Database Connected Successfully to: " + dbUrl);
        } catch (ClassNotFoundException e) {
            System.err.println("❌ MySQL JDBC Driver Class Not Found: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("❌ Database Connection Failed! Reason: " + e.getMessage() + " (ErrorCode: " + e.getErrorCode() + ")");
        } catch (Exception e) {
            System.err.println("❌ Unexpected DB Error: " + e.getMessage());
        }
        return con;
    }
}
