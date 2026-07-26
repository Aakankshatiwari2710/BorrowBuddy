package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/CancelBookingServlet")
public class CancelBookingServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int currentUserId = (Integer) session.getAttribute("userId");
        String bIdStr = request.getParameter("id");
        if (bIdStr == null || bIdStr.isEmpty()) {
            response.sendRedirect("myBookings.jsp");
            return;
        }
        int bookingId = Integer.parseInt(bIdStr);
        String redirectPage = request.getParameter("redirect");
        if (redirectPage == null || redirectPage.isEmpty()) {
            redirectPage = "myBookings.jsp";
        }

        Connection con = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psQuery = null;
        PreparedStatement psNotify = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            // 1. Fetch details to send notification
            psQuery = con.prepareStatement(
                "SELECT b.borrower_id, u_owner.id AS owner_id, i.name AS item_name " +
                "FROM bookings b " +
                "JOIN items i ON b.item_id = i.id " +
                "LEFT JOIN users u_owner ON i.owner_email = u_owner.email " +
                "WHERE b.id = ?"
            );
            psQuery.setInt(1, bookingId);
            rs = psQuery.executeQuery();

            int borrowerId = 0;
            int ownerId = 0;
            String itemName = "Product";
            if (rs.next()) {
                borrowerId = rs.getInt("borrower_id");
                ownerId = rs.getInt("owner_id");
                itemName = rs.getString("item_name");
            }

            // 2. Update booking status to Cancelled
            psUpdate = con.prepareStatement(
                "UPDATE bookings SET status='Cancelled' WHERE id=?"
            );
            psUpdate.setInt(1, bookingId);
            psUpdate.executeUpdate();

            // 3. Notify the other party
            int notifyRecipient = (currentUserId == borrowerId) ? ownerId : borrowerId;
            String cancellerRole = (currentUserId == borrowerId) ? "Customer" : "Owner";

            if (notifyRecipient > 0) {
                psNotify = con.prepareStatement(
                    "INSERT INTO notifications (user_id, message, type, is_read, created_at) VALUES (?, ?, 'ORDER', 0, NOW())"
                );
                psNotify.setInt(1, notifyRecipient);
                psNotify.setString(2, "Order #" + bookingId + " for " + itemName + " has been CANCELLED by " + cancellerRole + ".");
                psNotify.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if(rs!=null) rs.close(); } catch(Exception e){}
            try { if(psNotify!=null) psNotify.close(); } catch(Exception e){}
            try { if(psQuery!=null) psQuery.close(); } catch(Exception e){}
            try { if(psUpdate!=null) psUpdate.close(); } catch(Exception e){}
            try { if(con!=null) con.close(); } catch(Exception e){}
        }

        response.sendRedirect(redirectPage + "?msg=order_cancelled");
    }
}
