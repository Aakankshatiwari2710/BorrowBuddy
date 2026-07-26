package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.annotation.MultipartConfig;
import java.io.File;

@WebServlet("/UpdateProfileServlet")
@MultipartConfig
public class UpdateProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
                          throws ServletException, IOException {

        HttpSession session = request.getSession();
        int userId = (int) session.getAttribute("userId");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // Use password from session/db if not updated (check logic)
        // However, usually if it's sent from a form and is a plain text, we hash it.
        // If the user didn't change the password, the form might send the old hashed one or stay empty.
        // Let's assume the form sends a value only if it's new.

        String profileImagePath = (String) session.getAttribute("userImage");
        String uploadPath = getServletContext().getRealPath("/images/profiles");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        // [Image handling code remains the same]
        String croppedData = request.getParameter("croppedImageData");
        if (croppedData != null && !croppedData.isEmpty()) {
            try {
                String base64Image = croppedData.split(",")[1];
                byte[] imageBytes = java.util.Base64.getDecoder().decode(base64Image);
                String fileName = userId + "_profile_" + System.currentTimeMillis() + ".jpg";
                File imageFile = new File(uploadPath + File.separator + fileName);
                try (java.io.FileOutputStream fos = new java.io.FileOutputStream(imageFile)) {
                    fos.write(imageBytes);
                }
                profileImagePath = fileName;
            } catch (Exception e) { e.printStackTrace(); }
        } else {
            Part filePart = request.getPart("profileImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = userId + "_" + filePart.getSubmittedFileName();
                filePart.write(uploadPath + File.separator + fileName);
                profileImagePath = fileName;
            }
        }

        try (Connection con = DBConnection.getConnection()) {
            
            String query;
            boolean updatePass = password != null && !password.isEmpty();
            
            if (updatePass) {
                query = "UPDATE users SET name=?, email=?, password=?, profile_image=? WHERE id=?";
            } else {
                query = "UPDATE users SET name=?, email=?, profile_image=? WHERE id=?";
            }

            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, name);
            ps.setString(2, email);
            
            if (updatePass) {
                String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
                ps.setString(3, hashed);
                ps.setString(4, profileImagePath);
                ps.setInt(5, userId);
            } else {
                ps.setString(3, profileImagePath);
                ps.setInt(4, userId);
            }

            ps.executeUpdate();

            session.setAttribute("userName", name);
            session.setAttribute("userEmail", email);
            session.setAttribute("userImage", profileImagePath);

            response.sendRedirect("profile.jsp?update=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?update=error");
        }
    }
}