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

            // Handle direct purchases where dates are empty from frontend
            if (startDateStr == null || startDateStr.trim().isEmpty() || endDateStr == null || endDateStr.trim().isEmpty()) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                String nowStr = sdf.format(new java.util.Date());
                startDateStr = nowStr;
                endDateStr = nowStr;
            } else {
                startDateStr = startDateStr.replace("T", " ");
                if (!startDateStr.contains(":")) {
                    startDateStr += " 00:00:00";
                } else if (startDateStr.split(":").length == 2) {
                    startDateStr += ":00";
                }
                
                endDateStr = endDateStr.replace("T", " ");
                if (!endDateStr.contains(":")) {
                    endDateStr += " 00:00:00";
                } else if (endDateStr.split(":").length == 2) {
                    endDateStr += ":00";
                }
            }

            // ✅ 1. INSERT BOOKING & GET GENERATED ID
            psBooking = con.prepareStatement(
                "INSERT INTO bookings (item_id, borrower_id, start_date, end_date, status, payment_status, condition_note) " +
                "VALUES (?, ?, ?, ?, 'Pending', 'Unpaid', ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            psBooking.setInt(1, itemId);
            psBooking.setInt(2, borrowerId);
            psBooking.setString(3, startDateStr);
            psBooking.setString(4, endDateStr);
            psBooking.setString(5, conditionNote);
            psBooking.executeUpdate();

            int newBookingId = 0;
            try (ResultSet rsKeys = psBooking.getGeneratedKeys()) {
                if (rsKeys.next()) {
                    newBookingId = rsKeys.getInt(1);
                }
            }

            // ✅ 2. GET OWNER ID & NOTIFY
            psOwner = con.prepareStatement(
                "SELECT u.id, i.name FROM items i " +
                "LEFT JOIN users u ON u.email = i.owner_email " +
                "WHERE i.id=?"
            );
            psOwner.setInt(1, itemId);
            rs = psOwner.executeQuery();

            if(rs.next() && rs.getObject("id") != null){
                int ownerId = rs.getInt("id");
                String itemName = rs.getString("name");

                psNotify = con.prepareStatement(
                    "INSERT INTO notifications(user_id, message, type, is_read, created_at) VALUES (?, ?, ?, 0, NOW())"
                );
                psNotify.setInt(1, ownerId);
                psNotify.setString(2, "New purchase order initiated for: " + itemName);
                psNotify.setString(3, "ORDER");
                psNotify.executeUpdate();
            }

            if (newBookingId > 0) {
                response.sendRedirect("payNow.jsp?bookingId=" + newBookingId);
            } else {
                response.sendRedirect("myBookings.jsp");
            }

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