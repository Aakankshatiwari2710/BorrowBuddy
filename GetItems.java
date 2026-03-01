import java.sql.*;

public class GetItems {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
        Statement s = con.createStatement();
        ResultSet rs = s.executeQuery("SELECT id, name, owner_email FROM items");
        System.out.println("ID | Item Name | Owner Email");
        while(rs.next()) {
             System.out.println(rs.getInt("id") + " | " + rs.getString("name") + " | " + rs.getString("owner_email"));
        }
        con.close();
    }
}
