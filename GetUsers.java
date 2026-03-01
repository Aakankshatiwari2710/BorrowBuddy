import java.sql.*;

public class GetUsers {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
        Statement s = con.createStatement();
        ResultSet rs = s.executeQuery("SELECT email, password, role FROM users");
        System.out.println("Email | Password | Role");
        while(rs.next()) {
             System.out.println(rs.getString("email") + " | " + rs.getString("password") + " | " + rs.getString("role"));
        }
        con.close();
    }
}
