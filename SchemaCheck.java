import java.sql.*;

public class SchemaCheck {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/sharesphere", "root", "");
            DatabaseMetaData dbmd = con.getMetaData();
            
            String[] tables = {"users", "items", "bookings", "messages", "notifications"};
            for(String table : tables) {
                System.out.println("\n--- Table: " + table + " ---");
                ResultSet columns = dbmd.getColumns(null, null, table, null);
                while(columns.next()) {
                    String columnName = columns.getString("COLUMN_NAME");
                    String columnType = columns.getString("TYPE_NAME");
                    System.out.println(columnName + " (" + columnType + ")");
                }
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
