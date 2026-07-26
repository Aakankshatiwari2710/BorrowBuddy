package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/UpdateItemServlet")
public class UpdateItemServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("userEmail") == null ||
            !"Owner".equalsIgnoreCase((String) session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        if (description == null) description = "";
        String price = request.getParameter("price");
        String category = request.getParameter("category");
        String offerTag = request.getParameter("offer_tag");
        if (offerTag == null) offerTag = "";
        String stockStatus = request.getParameter("stock_status");
        if (stockStatus == null || stockStatus.isEmpty()) stockStatus = "In Stock";

        try {
            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "UPDATE items SET name=?, description=?, price=?, category=?, offer_tag=?, stock_status=? WHERE id=? AND owner_email=?"
            );

            ps.setString(1, name);
            ps.setString(2, description);
            ps.setDouble(3, Double.parseDouble(price));
            ps.setString(4, category);
            ps.setString(5, offerTag);
            ps.setString(6, stockStatus);
            ps.setInt(7, Integer.parseInt(id));
            ps.setString(8, (String) session.getAttribute("userEmail"));

            ps.executeUpdate();
            con.close();

            response.sendRedirect("myItems.jsp?msg=Item Updated Successfully");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("myItems.jsp?msg=Update Failed");
        }
    }
}
