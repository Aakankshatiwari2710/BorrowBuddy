<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, util.DBConnection" %>
<%
    try (Connection con = DBConnection.getConnection()) {
        Statement stmt = con.createStatement();
        try { stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN condition_note TEXT NULL"); } catch(Exception e) {}
        try { stmt.executeUpdate("ALTER TABLE bookings ADD COLUMN late_fee DOUBLE DEFAULT 0.0"); } catch(Exception e) {}
        out.println("Phase 3 Database updates (Condition Note & Late Fee) ready!");
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
