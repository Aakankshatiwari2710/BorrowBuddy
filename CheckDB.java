import java.sql.*;
import java.io.*;

public class CheckDB {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT id, name, image FROM items");
            while(rs.next()) {
                System.out.println("ID: " + rs.getInt("id") + " Name: " + rs.getString("name") + " Image: " + rs.getString("image"));
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
