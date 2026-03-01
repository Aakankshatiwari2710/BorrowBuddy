import java.sql.*;

public class CheckDB2 {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM items");
            System.out.println("--- ITEMS ---");
            while(rs.next()) {
                System.out.println("ID: " + rs.getInt("id") + " Name: " + rs.getString("name") + " Owner: " + rs.getString("owner_email") + " Image: " + rs.getString("image"));
            }
            
            rs = stmt.executeQuery("SELECT * FROM bookings");
            System.out.println("--- BOOKINGS ---");
            while(rs.next()) {
                System.out.println("ID: " + rs.getInt("id") + " Item_ID: " + rs.getInt("item_id") + " Borrower_ID: " + rs.getInt("borrower_id") + " Status: " + rs.getString("status"));
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
