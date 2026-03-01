package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import util.DBConnection;

@WebServlet("/DeleteItemServlet")
public class DeleteItemServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("userEmail") == null ||
            !"Owner".equalsIgnoreCase((String) session.getAttribute("userRole"))) {

            response.sendRedirect("login.jsp");
            return;
        }

        String id = request.getParameter("id");

        if (id == null || id.trim().isEmpty()) {
            response.sendRedirect("myItems.jsp?msg=Invalid Item ID");
            return;
        }

        Connection con = null;
        PreparedStatement deleteBookings = null;
        PreparedStatement deleteItem = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // transaction start

            // 🔥 Step 1: delete related bookings first
            deleteBookings = con.prepareStatement(
                "DELETE FROM bookings WHERE item_id=?"
            );
            deleteBookings.setInt(1, Integer.parseInt(id));
            deleteBookings.executeUpdate();

            // 🔥 Step 2: delete item
            deleteItem = con.prepareStatement(
                "DELETE FROM items WHERE id=? AND owner_email=?"
            );
            deleteItem.setInt(1, Integer.parseInt(id));
            deleteItem.setString(2, (String) session.getAttribute("userEmail"));

            int rows = deleteItem.executeUpdate();

            if (rows > 0) {
                con.commit();
                response.sendRedirect("myItems.jsp?msg=Item Deleted Successfully");
            } else {
                con.rollback();
                response.sendRedirect("myItems.jsp?msg=Delete Failed");
            }

        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect("myItems.jsp?msg=Error Occurred");
        } finally {
            try { if (deleteBookings != null) deleteBookings.close(); } catch (Exception e) {}
            try { if (deleteItem != null) deleteItem.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
