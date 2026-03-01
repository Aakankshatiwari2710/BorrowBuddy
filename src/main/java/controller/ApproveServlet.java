package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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

            // 1️⃣ Get borrower_id from booking
            ps1 = con.prepareStatement(
                "SELECT borrower_id FROM bookings WHERE id=?"
            );
            ps1.setInt(1, bookingId);
            rs = ps1.executeQuery();

            int borrowerId = 0;
            if (rs.next()) {
                borrowerId = rs.getInt("borrower_id");
            }

            // 2️⃣ Update booking status
            ps2 = con.prepareStatement(
                "UPDATE bookings SET status=? WHERE id=?"
            );
            ps2.setString(1, action);
            ps2.setInt(2, bookingId);
            ps2.executeUpdate();

            // 3️⃣ Send notification to customer
            String message = "";

            if ("Approved".equalsIgnoreCase(action)) {
                message = "Your booking has been APPROVED";
            } else if ("Rejected".equalsIgnoreCase(action)) {
                message = "Your booking has been REJECTED";
            }

            psNotify = con.prepareStatement(
                "INSERT INTO notifications (user_id, message, status, created_at) VALUES (?, ?, 'Unread', NOW())"
            );
            psNotify.setInt(1, borrowerId);
            psNotify.setString(2, message);
            psNotify.executeUpdate();

            response.sendRedirect("ownerRequests.jsp");

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