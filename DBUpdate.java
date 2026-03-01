import java.sql.*;

public class DBUpdate {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
            Statement stmt = con.createStatement();
            
            // Alter start_date and end_date to DATETIME to support time slots
            stmt.executeUpdate("ALTER TABLE bookings MODIFY COLUMN start_date DATETIME");
            stmt.executeUpdate("ALTER TABLE bookings MODIFY COLUMN end_date DATETIME");
            
            System.out.println("Modified start_date and end_date to DATETIME.");
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
