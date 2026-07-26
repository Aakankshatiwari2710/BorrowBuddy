package util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.Statement;

@WebListener
public class DBInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("Starting ShareSphere DB Migration/Optimization...");
        
        try (Connection con = DBConnection.getConnection()) {
            if (con != null) {
                try (Statement stmt = con.createStatement()) {
                    // 1. Create Users Table
                    stmt.executeUpdate("CREATE TABLE IF NOT EXISTS users ("
                            + "id INT AUTO_INCREMENT PRIMARY KEY, "
                            + "name VARCHAR(100) NOT NULL, "
                            + "email VARCHAR(100) UNIQUE NOT NULL, "
                            + "password VARCHAR(255) NOT NULL, "
                            + "location VARCHAR(100), "
                            + "role VARCHAR(20) NOT NULL, "
                            + "trust_score INT DEFAULT 0, "
                            + "is_verified BOOLEAN DEFAULT FALSE, "
                            + "profile_image VARCHAR(255) DEFAULT 'default_profile.png', "
                            + "otp_code VARCHAR(10) NULL, "
                            + "email_verified BOOLEAN DEFAULT FALSE, "
                            + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

                    // 2. Create Items Table
                    stmt.executeUpdate("CREATE TABLE IF NOT EXISTS items ("
                            + "id INT AUTO_INCREMENT PRIMARY KEY, "
                            + "name VARCHAR(100) NOT NULL, "
                            + "description TEXT, "
                            + "price DOUBLE NOT NULL, "
                            + "category VARCHAR(50), "
                            + "image VARCHAR(255), "
                            + "owner_email VARCHAR(100) NOT NULL, "
                            + "offer_tag VARCHAR(100) DEFAULT '', "
                            + "stock_status VARCHAR(20) DEFAULT 'In Stock', "
                            + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

                    // 3. Create Bookings Table
                    stmt.executeUpdate("CREATE TABLE IF NOT EXISTS bookings ("
                            + "id INT AUTO_INCREMENT PRIMARY KEY, "
                            + "borrower_id INT NOT NULL, "
                            + "item_id INT NOT NULL, "
                            + "start_date DATE NOT NULL, "
                            + "end_date DATE NOT NULL, "
                            + "status VARCHAR(20) DEFAULT 'Pending', "
                            + "payment_status VARCHAR(20) DEFAULT 'Unpaid', "
                            + "rating_id INT NULL, "
                            + "condition_note TEXT NULL, "
                            + "late_fee DOUBLE DEFAULT 0.0, "
                            + "shipping_address TEXT NULL, "
                            + "shipping_city VARCHAR(100) NULL, "
                            + "shipping_pincode VARCHAR(20) NULL, "
                            + "shipping_phone VARCHAR(20) NULL, "
                            + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

                    // 4. Create Notifications Table
                    stmt.executeUpdate("CREATE TABLE IF NOT EXISTS notifications ("
                            + "id INT AUTO_INCREMENT PRIMARY KEY, "
                            + "user_id INT NOT NULL, "
                            + "message TEXT NOT NULL, "
                            + "type VARCHAR(20) DEFAULT 'GENERAL', "
                            + "is_read BOOLEAN DEFAULT FALSE, "
                            + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

                    // 5. Create Reviews Table
                    stmt.executeUpdate("CREATE TABLE IF NOT EXISTS reviews ("
                            + "id INT AUTO_INCREMENT PRIMARY KEY, "
                            + "item_id INT, "
                            + "reviewer_id INT, "
                            + "rating INT, "
                            + "comment TEXT, "
                            + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

                    System.out.println("✅ ShareSphere DB Schema Verified & Ready!");
                }
            } else {
                System.err.println("⚠️ DB Connection is null. Skipping startup DB initialization.");
            }
        } catch (Exception e) {
            System.err.println("❌ Error initializing ShareSphere DB: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
    }
}
