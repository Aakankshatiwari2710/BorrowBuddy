<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, util.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Database Migration</title>
    <style>
        body { font-family: sans-serif; padding: 20px; line-height: 1.6; }
        .success { color: green; font-weight: bold; }
        .error { color: red; }
        .log { background: #f4f4f4; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>ShareSphere Database Migration: Phase 1</h1>
    <div class="log">
    <%
        try (Connection con = DBConnection.getConnection()) {
            Statement stmt = con.createStatement();
            
            out.println("<p>Updating <code>users</code> table...</p>");
            try { 
                stmt.executeUpdate("ALTER TABLE users ADD COLUMN is_verified BOOLEAN DEFAULT FALSE"); 
                out.println("<p class='success'>Added is_verified column.</p>");
            } catch(Exception e) { 
                out.println("<p class='error'>is_verified: " + e.getMessage() + "</p>"); 
            }
            
            try { 
                stmt.executeUpdate("ALTER TABLE users ADD COLUMN trust_score INT DEFAULT 100"); 
                out.println("<p class='success'>Added trust_score column.</p>");
            } catch(Exception e) { 
                out.println("<p class='error'>trust_score: " + e.getMessage() + "</p>"); 
            }
            
            out.println("<p>Creating <code>reviews</code> table...</p>");
            try {
                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS reviews (" +
                                 "id INT AUTO_INCREMENT PRIMARY KEY, " +
                                 "item_id INT, " +
                                 "reviewer_id INT, " +
                                 "rating INT, " +
                                 "comment TEXT, " +
                                 "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
                out.println("<p class='success'>Reviews table ready.</p>");
            } catch(Exception e) {
                out.println("<p class='error'>reviews table: " + e.getMessage() + "</p>");
            }
            
            out.println("<p>Updating <code>bookings</code> table...</p>");
            try { 
                stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN rating_id INT NULL"); 
                out.println("<p class='success'>Added rating_id column.</p>");
            } catch(Exception e) { 
                out.println("<p class='error'>rating_id: " + e.getMessage() + "</p>"); 
            }
            
            out.println("<h2>Migration Completed!</h2>");
        } catch (Exception e) {
            out.println("<h2 class='error'>Connection Error: " + e.getMessage() + "</h2>");
        }
    %>
    </div>
    <p><a href="dashboard.jsp">Return to Dashboard</a></p>
</body>
</html>