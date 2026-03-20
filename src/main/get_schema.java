import java.sql.*;

public class CheckSchema {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/sharesphere";
        String user = "root";
        String password = "";

        try (Connection con = DriverManager.getConnection(url, user, password)) {
            DatabaseMetaData meta = con.getMetaData();
            ResultSet tables = meta.getTables(null, null, "%", new String[] { "TABLE" });
            while (tables.next()) {
                String tableName = tables.getString("TABLE_NAME");
                System.out.println("\nTable: " + tableName);
                ResultSet columns = meta.getColumns(null, null, tableName, "%");
                while (columns.next()) {
                    System.out.println("  - " + columns.getString("COLUMN_NAME") + " (" + columns.getString("TYPE_NAME") + ")");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
