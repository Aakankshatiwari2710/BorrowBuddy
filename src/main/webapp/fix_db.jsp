<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<!DOCTYPE html>
<html>
<head><title>DB Fix</title></head>
<body>
<%
    out.println("<h3>Starting Database Fix...</h3>");
    try (Connection con = DBConnection.getConnection()) {
        if (con == null) {
            out.println("<p style='color:red;'>Failed to get connection!</p>");
        } else {
            out.println("<p style='color:green;'>Connection successful!</p>");
            Statement stmt = con.createStatement();
            
            // 1. Reviews table
            try {
                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS reviews (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "item_id INT, " +
                    "reviewer_id INT, " +
                    "rating INT, " +
                    "comment TEXT, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
                out.println("<p style='color:green;'>1. Reviews table check/create: SUCCESS</p>");
            } catch (Exception e) {
                out.println("<p style='color:red;'>1. Reviews table: " + e.getMessage() + "</p>");
            }

            // 2. Bookings: rating_id
            try {
                stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN rating_id INT NULL");
                out.println("<p style='color:green;'>2. rating_id added: SUCCESS</p>");
            } catch (Exception e) {
                out.println("<p>2. rating_id (might already exist): " + e.getMessage() + "</p>");
            }

            // 3. Bookings: condition_note
            try {
                stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN condition_note TEXT NULL");
                out.println("<p style='color:green;'>3. condition_note added: SUCCESS</p>");
            } catch (Exception e) {
                out.println("<p>3. condition_note (might already exist): " + e.getMessage() + "</p>");
            }

            // 4. Bookings: late_fee
            try {
                stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN late_fee DOUBLE DEFAULT 0.0");
                out.println("<p style='color:green;'>4. late_fee added: SUCCESS</p>");
            } catch (Exception e) {
                out.println("<p>4. late_fee (might already exist): " + e.getMessage() + "</p>");
            }

            // 5. Users: trust_score
            try {
                stmt.executeUpdate("ALTER TABLE users ADD COLUMN trust_score INT DEFAULT 0");
                out.println("<p style='color:green;'>5. trust_score added: SUCCESS</p>");
            } catch (Exception e) {
                out.println("<p>5. trust_score (might already exist): " + e.getMessage() + "</p>");
            }

            // 6. Users: is_verified
            try {
                stmt.executeUpdate("ALTER TABLE users ADD COLUMN is_verified BOOLEAN DEFAULT FALSE");
                out.println("<p style='color:green;'>6. is_verified added: SUCCESS</p>");
            } catch (Exception e) {
                out.println("<p>6. is_verified (might already exist): " + e.getMessage() + "</p>");
            }
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Global Error: " + e.getMessage() + "</p>");
    }
%>
<hr>
<a href="dashboard.jsp">Go to Dashboard</a>
</body>
</html>
