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
        
        try {
            Connection con = DBConnection.getConnection();
            if (con != null) {
                try (Statement stmt = con.createStatement()) {
                    // 1. Create Reviews table
                    stmt.executeUpdate("CREATE TABLE IF NOT EXISTS reviews (id INT AUTO_INCREMENT PRIMARY KEY, item_id INT, reviewer_id INT, rating INT, comment TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
                    
                    // 2. Bookings updates (Columns add logic)
                    try { stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN rating_id INT NULL"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN condition_note TEXT NULL"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN late_fee DOUBLE DEFAULT 0.0"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN shipping_address TEXT NULL"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN shipping_city VARCHAR(100) NULL"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN shipping_pincode VARCHAR(20) NULL"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN shipping_phone VARCHAR(20) NULL"); } catch(Exception e){}
                    
                    // 3. User updates
                    try { stmt.executeUpdate("ALTER TABLE users ADD COLUMN trust_score INT DEFAULT 0"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE users ADD COLUMN is_verified BOOLEAN DEFAULT FALSE"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE users ADD COLUMN profile_image VARCHAR(255) DEFAULT 'default_profile.png'"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE users ADD COLUMN otp_code VARCHAR(10) NULL"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT FALSE"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE items ADD COLUMN offer_tag VARCHAR(100) DEFAULT ''"); } catch(Exception e){}
                    try { stmt.executeUpdate("ALTER TABLE items ADD COLUMN stock_status VARCHAR(20) DEFAULT 'In Stock'"); } catch(Exception e){}
                    
                    // 4. Schema verification complete
                    System.out.println("✅ ShareSphere DB Schema Verified & Ready!");
                } finally {
                    try { con.close(); } catch(Exception e) {}
                }
            } else {
                System.err.println("⚠️ DB Connection is null. Skipping startup DB initialization.");
            }
        } catch (Throwable t) {
            System.err.println("❌ DBInitializer caught an exception: " + t.getMessage());
            t.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup if needed
    }
}
