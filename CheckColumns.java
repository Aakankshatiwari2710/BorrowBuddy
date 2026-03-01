import java.sql.*;

public class CheckColumns {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
        Statement s = con.createStatement();
        ResultSet rs = s.executeQuery("SELECT * FROM bookings LIMIT 1");
        ResultSetMetaData rsmd = rs.getMetaData();
        for(int i=1; i<=rsmd.getColumnCount(); i++) {
             System.out.println(rsmd.getColumnName(i));
        }
        con.close();
    }
}
