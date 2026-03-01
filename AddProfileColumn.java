import java.sql.*;

public class AddProfileColumn {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
            Statement stmt = con.createStatement();
            stmt.executeUpdate("ALTER TABLE users ADD COLUMN profile_image VARCHAR(255) DEFAULT 'default_profile.png'");
            System.out.println("Column added successfully.");
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
