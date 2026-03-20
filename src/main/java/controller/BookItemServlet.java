package controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/BookItemServlet")
public class BookItemServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int borrowerId = (Integer) session.getAttribute("userId");
        int itemId = Integer.parseInt(request.getParameter("itemId"));
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String conditionNote = request.getParameter("conditionNote");

        Connection con = null;
        PreparedStatement psBooking = null;
        PreparedStatement psOwner = null;
        PreparedStatement psNotify = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            // Convert 'YYYY-MM-DDTHH:MM' to 'YYYY-MM-DD HH:MM:00'
            if (startDateStr != null) startDateStr = startDateStr.replace("T", " ") + ":00";
            if (endDateStr != null) endDateStr = endDateStr.replace("T", " ") + ":00";

            // ✅ 1. INSERT BOOKING
            psBooking = con.prepareStatement(
                "INSERT INTO bookings (item_id, borrower_id, start_date, end_date, status, payment_status, agreement_accepted, condition_note) " +
                "VALUES (?, ?, ?, ?, 'Pending', 'Unpaid', 0, ?)"
            );
            psBooking.setInt(1, itemId);
            psBooking.setInt(2, borrowerId);
            psBooking.setString(3, startDateStr);
            psBooking.setString(4, endDateStr);
            psBooking.setString(5, conditionNote);
            psBooking.executeUpdate();

            // ✅ 2. GET OWNER ID
            psOwner = con.prepareStatement(
                "SELECT u.id, i.name FROM users u " +
                "JOIN items i ON u.email = i.owner_email " +
                "WHERE i.id=?"
            );
            psOwner.setInt(1, itemId);
            rs = psOwner.executeQuery();

            if(rs.next()){
                int ownerId = rs.getInt("id");
                String itemName = rs.getString("name");

                // ✅ 3. INSERT NOTIFICATION FOR OWNER
                psNotify = con.prepareStatement(
                    "INSERT INTO notifications(user_id, message, type, is_read, created_at) VALUES (?, ?, ?, 0, NOW())"
                );
                psNotify.setInt(1, ownerId);
                psNotify.setString(2, "New booking request for item: " + itemName);
                psNotify.setString(3, "BOOKING");
                psNotify.executeUpdate();
            }

            response.sendRedirect("viewItems.jsp?success=booked");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("viewItems.jsp?error=failed");
        }
        finally {
            try{ if(rs!=null)rs.close(); }catch(Exception e){}
            try{ if(psNotify!=null)psNotify.close(); }catch(Exception e){}
            try{ if(psOwner!=null)psOwner.close(); }catch(Exception e){}
            try{ if(psBooking!=null)psBooking.close(); }catch(Exception e){}
            try{ if(con!=null)con.close(); }catch(Exception e){}
        }
    }
}