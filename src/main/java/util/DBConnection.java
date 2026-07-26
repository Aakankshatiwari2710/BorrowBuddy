package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    public static Connection getConnection() {
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Environment Variables check for Render, Railway, Aiven, etc.
            String dbUrl = System.getenv("DB_URL");
            if (dbUrl == null || dbUrl.isEmpty()) dbUrl = System.getenv("MYSQL_URL");
            if (dbUrl == null || dbUrl.isEmpty()) dbUrl = System.getenv("MYSQL_PUBLIC_URL");
            
            String dbUser = System.getenv("DB_USER");
            if (dbUser == null || dbUser.isEmpty()) dbUser = System.getenv("MYSQL_USER");
            if (dbUser == null || dbUser.isEmpty()) dbUser = System.getenv("MYSQLUSER");
            if (dbUser == null) dbUser = "root";

            String dbPassword = System.getenv("DB_PASSWORD");
            if (dbPassword == null || dbPassword.isEmpty()) dbPassword = System.getenv("MYSQL_PASSWORD");
            if (dbPassword == null || dbPassword.isEmpty()) dbPassword = System.getenv("MYSQLPASSWORD");
            if (dbPassword == null) dbPassword = "";

            String dbHost = System.getenv("MYSQL_HOST");
            if (dbHost == null || dbHost.isEmpty()) dbHost = System.getenv("MYSQLHOST");

            String dbPort = System.getenv("MYSQL_PORT");
            if (dbPort == null || dbPort.isEmpty()) dbPort = System.getenv("MYSQLPORT");
            if (dbPort == null || dbPort.isEmpty()) dbPort = "3306";

            String dbName = System.getenv("MYSQL_DATABASE");
            if (dbName == null || dbName.isEmpty()) dbName = System.getenv("MYSQLDATABASE");
            if (dbName == null || dbName.isEmpty()) dbName = "sharesphere";

            if ((dbUrl == null || dbUrl.trim().isEmpty()) && dbHost != null && !dbHost.trim().isEmpty()) {
                dbUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName + "?useSSL=false&allowPublicKeyRetrieval=true";
            }

            // Fallback for local development
            if (dbUrl == null || dbUrl.trim().isEmpty()) {
                dbUrl = "jdbc:mysql://localhost:3306/sharesphere";
            }
            
            con = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
            System.out.println("✅ Database Connected Successfully to: " + dbUrl);
        } catch (Exception e) {
            System.err.println("❌ Database Connection Failed! Error: " + e.getMessage());
            e.printStackTrace();
        }
        return con;
    }
}
