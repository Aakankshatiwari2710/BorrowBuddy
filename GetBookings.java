import java.sql.*;

public class GetBookings {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
        Statement s = con.createStatement();
        ResultSet rs = s.executeQuery("SELECT b.id, i.name as item, u.name as borrower, b.status, b.start_date, b.end_date FROM bookings b JOIN items i ON b.item_id=i.id JOIN users u ON b.borrower_id=u.id");
        System.out.println("ID | Item | Borrower | Status | Start | End");
        while(rs.next()) {
             System.out.println(rs.getInt("id") + " | " + rs.getString("item") + " | " + rs.getString("borrower") + " | " + rs.getString("status") + " | " + rs.getString("start_date") + " | " + rs.getString("end_date"));
        }
        con.close();
    }
}
