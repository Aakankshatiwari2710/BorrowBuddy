import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestDB {
    public static void main(String[] args) {
        try {
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("DESCRIBE messages");
            while(rs.next()) {
                System.out.println(rs.getString("Field") + " | Default: " + rs.getString("Default") + " | Extra: " + rs.getString("Extra"));
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
