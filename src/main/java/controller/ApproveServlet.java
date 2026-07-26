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

            // 1. Get borrower_id, customer email, name, item details, shipping address from booking
            ps1 = con.prepareStatement(
                "SELECT b.borrower_id, u.email AS cust_email, u.name AS cust_name, i.name AS item_name, i.price AS item_price, " +
                "b.shipping_address, b.shipping_city, b.shipping_pincode, b.shipping_phone, b.condition_note " +
                "FROM bookings b JOIN users u ON b.borrower_id = u.id JOIN items i ON b.item_id = i.id WHERE b.id=?"
            );
            ps1.setInt(1, bookingId);
            rs = ps1.executeQuery();

            int borrowerId = 0;
            String custEmail = "";
            String custName = "";
            String itemName = "Product";
            double itemPrice = 0.0;
            String addr = "", city = "", pin = "", phone = "", note = "";

            if (rs.next()) {
                borrowerId = rs.getInt("borrower_id");
                custEmail = rs.getString("cust_email");
                custName = rs.getString("cust_name");
                itemName = rs.getString("item_name");
                itemPrice = rs.getDouble("item_price");
                addr = rs.getString("shipping_address");
                city = rs.getString("shipping_city");
                pin = rs.getString("shipping_pincode");
                phone = rs.getString("shipping_phone");
                note = rs.getString("condition_note");
            }

            // 2. Update booking status & payment status upon owner approval
            String payStatusUpdate = "Approved".equalsIgnoreCase(action) ? "Paid" : "Unpaid";
            ps2 = con.prepareStatement(
                "UPDATE bookings SET status=?, payment_status=?, late_fee=0.0 WHERE id=?"
            );
            ps2.setString(1, action);
            ps2.setString(2, payStatusUpdate);
            ps2.setInt(3, bookingId);
            ps2.executeUpdate();

            // 3. Send notification & JavaMail to customer with complete booking info
            String message = "";

            if ("Approved".equalsIgnoreCase(action)) {
                message = "Your order #" + bookingId + " for '" + itemName + "' and payment have been CONFIRMED by SpanV Studios!";
                if (custEmail != null && !custEmail.isEmpty()) {
                    util.EmailUtil.sendEmailAsync(custEmail, "SpanV Studios - Order #" + bookingId + " Confirmed! 🎉", 
                        util.EmailUtil.buildOrderConfirmedTemplate(bookingId, custName, itemName, itemPrice, addr, city, pin, phone, note));
                }
            } else if ("Rejected".equalsIgnoreCase(action)) {
                message = "Your order has been CANCELLED by owner.";
            } else {
                message = "Your order status: " + action;
            }

            psNotify = con.prepareStatement(
                "INSERT INTO notifications (user_id, message, type, is_read, created_at) VALUES (?, ?, ?, 0, NOW())"
            );
            psNotify.setInt(1, borrowerId);
            psNotify.setString(2, message);
            psNotify.setString(3, "ORDER");
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