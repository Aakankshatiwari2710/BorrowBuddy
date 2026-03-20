import java.sql.*;

public class UpdateDatabase {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/sharesphere";
        String user = "root";
        String password = "";

        try (Connection con = DriverManager.getConnection(url, user, password)) {
            Statement stmt = con.createStatement();
            
            System.out.println("Updating users table...");
            try { stmt.executeUpdate("ALTER TABLE users ADD COLUMN is_verified BOOLEAN DEFAULT FALSE"); } catch(Exception e) { System.out.println("is_verified already exists or error: " + e.getMessage()); }
            try { stmt.executeUpdate("ALTER TABLE users ADD COLUMN trust_score INT DEFAULT 100"); } catch(Exception e) { System.out.println("trust_score already exists or error: " + e.getMessage()); }
            
            System.out.println("Creating reviews table...");
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS reviews (" +
                             "id INT AUTO_INCREMENT PRIMARY KEY, " +
                             "item_id INT, " +
                             "reviewer_id INT, " +
                             "rating INT, " +
                             "comment TEXT, " +
                             "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
            
            System.out.println("Updating bookings table...");
            try { stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN rating_id INT NULL"); } catch(Exception e) { System.out.println("rating_id already exists or error: " + e.getMessage()); }
            
            System.out.println("Database updates completed successfully!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
