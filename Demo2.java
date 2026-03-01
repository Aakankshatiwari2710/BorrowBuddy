import java.sql.*;
import java.io.*;

public class Demo2 {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
        Statement s = con.createStatement();
        ResultSet rs = s.executeQuery("SELECT b.id, i.name as item, b.status, b.start_date, b.end_date FROM bookings b JOIN items i ON b.item_id=i.id ORDER BY b.id DESC LIMIT 5");
        FileWriter fw = new FileWriter("output2.txt");
        PrintWriter pw = new PrintWriter(fw);
        while(rs.next()) {
             pw.println(rs.getInt("id") + " | " + rs.getString("item") + " | " + rs.getString("status") + " | " + rs.getString("start_date") + " | " + rs.getString("end_date"));
        }
        pw.close();
        con.close();
    }
}
