package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/ApproveServlet")
public class ApproveServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int bookingId = Integer.parseInt(request.getParameter("id"));
        String action = request.getParameter("action"); // Approved / Rejected

        Connection con = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        PreparedStatement psNotify = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            // 1️⃣ Get borrower_id and end_date from booking
            ps1 = con.prepareStatement(
                "SELECT borrower_id, end_date FROM bookings WHERE id=?"
            );
            ps1.setInt(1, bookingId);
            rs = ps1.executeQuery();

            int borrowerId = 0;
            Timestamp endDate = null;
            if (rs.next()) {
                borrowerId = rs.getInt("borrower_id");
                endDate = rs.getTimestamp("end_date");
            }

            // 2️⃣ Update booking status and late fee if returned
            double lateFee = 0.0;
            if ("Returned".equalsIgnoreCase(action) && endDate != null) {
                long now = System.currentTimeMillis();
                long end = endDate.getTime();
                if (now > end) {
                    long diffMs = now - end;
                    long diffHours = (long) Math.ceil(diffMs / (1000.0 * 60 * 60));
                    lateFee = diffHours * 50.0; // ₹50 per hour
                }
                
                ps2 = con.prepareStatement(
                    "UPDATE bookings SET status=?, late_fee=? WHERE id=?"
                );
                ps2.setString(1, action);
                ps2.setDouble(2, lateFee);
                ps2.setInt(3, bookingId);
            } else {
                ps2 = con.prepareStatement(
                    "UPDATE bookings SET status=? WHERE id=?"
                );
                ps2.setString(1, action);
                ps2.setInt(2, bookingId);
            }
            ps2.executeUpdate();

            // 3️⃣ Send notification to customer
            String message = "";

            if ("Approved".equalsIgnoreCase(action)) {
                message = "Your booking has been APPROVED";
            } else if ("Rejected".equalsIgnoreCase(action)) {
                message = "Your booking has been REJECTED";
            } else if ("Returned".equalsIgnoreCase(action)) {
                message = "Item returned. Late fee: ₹" + lateFee;
            }

            psNotify = con.prepareStatement(
                "INSERT INTO notifications (user_id, message, type, is_read, created_at) VALUES (?, ?, ?, 0, NOW())"
            );
            psNotify.setInt(1, borrowerId);
            psNotify.setString(2, message);
            psNotify.setString(3, "BOOKING");
            psNotify.executeUpdate();

            response.sendRedirect("OwnerBookings.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if(rs!=null) rs.close(); } catch(Exception e){}
            try { if(psNotify!=null) psNotify.close(); } catch(Exception e){}
            try { if(ps2!=null) ps2.close(); } catch(Exception e){}
            try { if(ps1!=null) ps1.close(); } catch(Exception e){}
            try { if(con!=null) con.close(); } catch(Exception e){}
        }
    }
}