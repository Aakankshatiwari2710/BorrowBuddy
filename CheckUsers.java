import java.sql.*;

public class CheckUsers {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
            ResultSet rs = con.getMetaData().getColumns(null, null, "users", null);
            System.out.println("--- USERS TABLE COLUMNS ---");
            while(rs.next()) {
                System.out.println(rs.getString("COLUMN_NAME") + " (" + rs.getString("TYPE_NAME") + ")");
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
