package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/ProcessPaymentServlet")
public class ProcessPaymentServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        String amount = request.getParameter("amount");

        Connection con = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psQuery = null;
        PreparedStatement psNotify = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            // 1. Update Booking Payment Status
            psUpdate = con.prepareStatement(
                "UPDATE bookings SET payment_status = 'Paid' WHERE id = ?"
            );
            psUpdate.setInt(1, bookingId);
            psUpdate.executeUpdate();

            // 2. Query Owner ID to send notification
            psQuery = con.prepareStatement(
                "SELECT u.id, i.name, u.name as owner_name FROM bookings b " +
                "JOIN items i ON b.item_id = i.id " +
                "JOIN users u ON i.owner_email = u.email " +
                "WHERE b.id = ?"
            );
            psQuery.setInt(1, bookingId);
            rs = psQuery.executeQuery();

            if (rs.next()) {
                int ownerId = rs.getInt("id");
                String itemName = rs.getString("name");
                
                // 3. Notify Owner
                psNotify = con.prepareStatement(
                    "INSERT INTO notifications(user_id, message, type, is_read) VALUES (?, ?, 'PAYMENT', 0)"
                );
                psNotify.setInt(1, ownerId);
                psNotify.setString(2, "Payment of ₹" + amount + " received for " + itemName);
                psNotify.executeUpdate();
            }

            response.sendRedirect("myBookings.jsp?msg=paid");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("myBookings.jsp?error=payment_failed");
        } finally {
            try { if(rs!=null) rs.close(); } catch(Exception e){}
            try { if(psNotify!=null) psNotify.close(); } catch(Exception e){}
            try { if(psQuery!=null) psQuery.close(); } catch(Exception e){}
            try { if(psUpdate!=null) psUpdate.close(); } catch(Exception e){}
            try { if(con!=null) con.close(); } catch(Exception e){}
        }
    }
}
