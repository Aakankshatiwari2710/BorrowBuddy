package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.DBConnection;

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
        
        // Handle Profile Image (Standard Part or Cropped Base64)
        String croppedData = request.getParameter("croppedImageData");
        String profileImagePath = (String) session.getAttribute("userImage");
        String uploadPath = getServletContext().getRealPath("/images/profiles");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        if (croppedData != null && !croppedData.isEmpty()) {
            // Logic for Cropped Base64 Image
            try {
                String base64Image = croppedData.split(",")[1];
                byte[] imageBytes = java.util.Base64.getDecoder().decode(base64Image);
                String fileName = userId + "_profile_" + System.currentTimeMillis() + ".jpg";
                
                File imageFile = new File(uploadPath + File.separator + fileName);
                try (java.io.FileOutputStream fos = new java.io.FileOutputStream(imageFile)) {
                    fos.write(imageBytes);
                }
                profileImagePath = fileName;
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            // Logic for standard file upload if no crop data or as fallback
            Part filePart = request.getPart("profileImage");
            String fileName = (filePart != null) ? filePart.getSubmittedFileName() : null;

            if (fileName != null && !fileName.isEmpty()) {
                fileName = userId + "_" + fileName;
                filePart.write(uploadPath + File.separator + fileName);
                profileImagePath = fileName;
            }
        }

        try {
            Connection con = DBConnection.getConnection();
            
            // Simplified query for testing, ensuring columns match
            PreparedStatement ps = con.prepareStatement(
                "UPDATE users SET name=?, email=?, password=?, profile_image=? WHERE id=?");

            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, profileImagePath);
            ps.setInt(5, userId);

            ps.executeUpdate();

            session.setAttribute("userName", name);
            session.setAttribute("userEmail", email);
            session.setAttribute("userImage", profileImagePath);

            response.sendRedirect("profile.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}