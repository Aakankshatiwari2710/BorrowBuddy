import java.sql.*;

public class FixPaymentOption {
    public static void main(String[] args) {
        String dbUrl = "jdbc:mysql://localhost:3306/sharesphere";
        String dbUser = "root";
        String dbPass = "";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            Statement stmt = con.createStatement();

            System.out.println("Checking and updating database schema...");

            // 1. Add payment_status to bookings if missing
            try {
                stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN payment_status VARCHAR(20) DEFAULT 'Unpaid'");
                System.out.println("Added payment_status column to bookings table.");
            } catch (SQLException e) {
                if (e.getErrorCode() == 1060) { // Duplicate column name
                    System.out.println("payment_status column already exists.");
                } else {
                    e.printStackTrace();
                }
            }

            // 2. Add agreement_accepted to bookings if missing
            try {
                stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN agreement_accepted TINYINT(1) DEFAULT 0");
                System.out.println("Added agreement_accepted column to bookings table.");
            } catch (SQLException e) {
                if (e.getErrorCode() == 1060) {
                    System.out.println("agreement_accepted column already exists.");
                } else {
                    e.printStackTrace();
                }
            }

            // 3. Add type to notifications if missing
            try {
                stmt.executeUpdate("ALTER TABLE notifications ADD COLUMN type VARCHAR(50) DEFAULT 'GENERAL'");
                System.out.println("Added type column to notifications table.");
            } catch (SQLException e) {
                if (e.getErrorCode() == 1060) {
                    System.out.println("type column already exists in notifications.");
                } else {
                    e.printStackTrace();
                }
            }
            
            // 4. Update any null payment_status to 'Unpaid'
            stmt.executeUpdate("UPDATE bookings SET payment_status = 'Unpaid' WHERE payment_status IS NULL");

            System.out.println("Database schema fix completed.");
            con.close();
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
