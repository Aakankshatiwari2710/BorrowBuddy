import java.sql.*;

public class FixDB {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
            Statement stmt = con.createStatement();
            
            // Fix Drill Machine (ID 2)
            stmt.executeUpdate("UPDATE items SET image='drill machine.jpg' WHERE id=2");
            
            // Fix other missing items
            stmt.executeUpdate("UPDATE items SET image='default.png' WHERE image='Screenshot 2025-07-30 200638.png' OR image LIKE 'WhatsApp%'");

            System.out.println("DB Updated.");
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
