package util;

import java.sql.Connection;
import java.sql.Statement;

public class AddCategoryColumn {
    public static void main(String[] args) {
        try (Connection con = DBConnection.getConnection();
             Statement stmt = con.createStatement()) {
            
            // Add category column if it doesn't exist
            String sql = "ALTER TABLE items ADD COLUMN IF NOT EXISTS category VARCHAR(50) DEFAULT 'Others'";
            stmt.executeUpdate(sql);
            
            System.out.println("Category column added successfully to items table.");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
