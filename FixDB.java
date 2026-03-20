import java.sql.*;

public class FixDB {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
            Statement stmt = con.createStatement();
            
            System.out.println("Applying updates...");
            
            // 1. Reviews table
            try {
                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS reviews (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "item_id INT, " +
                    "reviewer_id INT, " +
                    "rating INT, " +
                    "comment TEXT, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
                System.out.println("Reviews table: OK");
            } catch (Exception e) { System.out.println("Reviews table error: " + e.getMessage()); }

            // 2. rating_id
            try {
                stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN rating_id INT NULL");
                System.out.println("rating_id: OK");
            } catch (Exception e) { System.out.println("rating_id notice: " + e.getMessage()); }

            // 3. condition_note
            try {
                stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN condition_note TEXT NULL");
                System.out.println("condition_note: OK");
            } catch (Exception e) { System.out.println("condition_note notice: " + e.getMessage()); }

            // 4. late_fee
            try {
                stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN late_fee DOUBLE DEFAULT 0.0");
                System.out.println("late_fee: OK");
            } catch (Exception e) { System.out.println("late_fee notice: " + e.getMessage()); }

            // 5. trust_score
            try {
                stmt.executeUpdate("ALTER TABLE users ADD COLUMN trust_score INT DEFAULT 0");
                System.out.println("trust_score: OK");
            } catch (Exception e) { System.out.println("trust_score notice: " + e.getMessage()); }

            // 6. is_verified
            try {
                stmt.executeUpdate("ALTER TABLE users ADD COLUMN is_verified BOOLEAN DEFAULT FALSE");
                System.out.println("is_verified: OK");
            } catch (Exception e) { System.out.println("is_verified notice: " + e.getMessage()); }

            System.out.println("Migration complete.");
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
