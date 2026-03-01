package controller;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/AddItemServlet")
@MultipartConfig
public class AddItemServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String price = request.getParameter("price");

        Part filePart = request.getPart("image");
        String fileName = filePart.getSubmittedFileName();

        // ✅ SAVE INSIDE images FOLDER
        String uploadPath = getServletContext().getRealPath("/images");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        filePart.write(uploadPath + File.separator + fileName);

        try {
            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO items(name, description, price, image, owner_email) VALUES(?,?,?,?,?)"
            );

            ps.setString(1, name);
            ps.setString(2, description);
            ps.setString(3, price);
            ps.setString(4, fileName);
            ps.setString(5, (String) session.getAttribute("userEmail"));

            ps.executeUpdate();
            con.close();

            response.sendRedirect("myItems.jsp?msg=Item Added Successfully");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
