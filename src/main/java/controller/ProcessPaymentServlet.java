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

        String bIdStr = request.getParameter("bookingId");
        if (bIdStr == null || bIdStr.isEmpty()) bIdStr = request.getParameter("booking_id");
        int bookingId = Integer.parseInt(bIdStr);

        String amount = request.getParameter("amount");
        String paymentRef = request.getParameter("payment_ref");
        if (paymentRef == null) paymentRef = "UPI Transaction";

        String shipPhone = request.getParameter("shipping_phone");
        String shipAddress = request.getParameter("shipping_address");
        String shipCity = request.getParameter("shipping_city");
        String shipPincode = request.getParameter("shipping_pincode");

        Connection con = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psQuery = null;
        PreparedStatement psNotify = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            // 1. Update Booking Payment Status & Shipping Details
            psUpdate = con.prepareStatement(
                "UPDATE bookings SET payment_status = 'Pending Verification', condition_note = ?, " +
                "shipping_address = ?, shipping_city = ?, shipping_pincode = ?, shipping_phone = ? WHERE id = ?"
            );
            psUpdate.setString(1, "UTR: " + paymentRef);
            psUpdate.setString(2, shipAddress);
            psUpdate.setString(3, shipCity);
            psUpdate.setString(4, shipPincode);
            psUpdate.setString(5, shipPhone);
            psUpdate.setInt(6, bookingId);
            psUpdate.executeUpdate();

            // 2. Query Owner ID to send notification & Customer Email
            psQuery = con.prepareStatement(
                "SELECT u.id AS owner_id, u_cust.email AS cust_email, i.name, i.price FROM bookings b " +
                "JOIN items i ON b.item_id = i.id " +
                "LEFT JOIN users u ON i.owner_email = u.email " +
                "LEFT JOIN users u_cust ON b.borrower_id = u_cust.id " +
                "WHERE b.id = ?"
            );
            psQuery.setInt(1, bookingId);
            rs = psQuery.executeQuery();

            if (rs.next()) {
                int ownerId = rs.getInt("owner_id");
                String custEmail = rs.getString("cust_email");
                String itemName = rs.getString("name");
                double itemPrice = rs.getDouble("price");
                if (amount == null || amount.isEmpty()) {
                    amount = String.valueOf((int)itemPrice);
                }
                
                // 3. Notify Owner
                if (ownerId > 0) {
                    psNotify = con.prepareStatement(
                        "INSERT INTO notifications(user_id, message, type, is_read) VALUES (?, ?, 'PAYMENT', 0)"
                    );
                    psNotify.setInt(1, ownerId);
                    psNotify.setString(2, "Customer submitted UPI UTR: " + paymentRef + " for ₹" + amount + " (" + itemName + "). Please verify & confirm.");
                    psNotify.executeUpdate();
                }

                // 📧 Send Email Receipt to Customer
                if (custEmail != null && !custEmail.isEmpty()) {
                    String fullAddress = (shipAddress != null ? shipAddress : "") + ", " + (shipCity != null ? shipCity : "") + " - " + (shipPincode != null ? shipPincode : "");
                    util.EmailUtil.sendEmailAsync(custEmail, "SpanV Studios - Order Receipt & Delivery Details", 
                        util.EmailUtil.buildOrderReceiptTemplate(itemName, itemPrice, "UTR: " + paymentRef, fullAddress));
                }
            }

            response.sendRedirect("myBookings.jsp?msg=payment_submitted");

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
