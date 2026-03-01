import java.sql.*;

public class UpdateOwner {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
        Statement s = con.createStatement();
        s.executeUpdate("UPDATE users SET role='Owner' WHERE email='abc@gmail.com'");
        System.out.println("Updated abc@gmail.com to Owner");
        con.close();
    }
}
