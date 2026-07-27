package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import org.mindrot.jbcrypt.BCrypt;
import util.DBConnection;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String dob = request.getParameter("dob");
        String newPassword = request.getParameter("newPassword");

        if (email != null) email = email.trim().toLowerCase();
        if (dob != null) dob = dob.trim();
        if (newPassword != null) newPassword = newPassword.trim();

        if (email == null || email.isEmpty() || dob == null || dob.isEmpty() || newPassword == null || newPassword.isEmpty()) {
            response.sendRedirect("forgotPassword.jsp?error=Please+fill+in+all+required+fields.");
            return;
        }

        if (newPassword.length() < 6) {
            response.sendRedirect("forgotPassword.jsp?error=Password+must+be+at+least+6+characters+long.");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("forgotPassword.jsp?error=Database+connection+failed.");
                return;
            }

            // Verify email and date of birth (DOB) match in users table
            PreparedStatement ps = con.prepareStatement("SELECT id, name FROM users WHERE LOWER(email)=? AND dob=?");
            ps.setString(1, email);
            ps.setString(2, dob);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                int userId = rs.getInt("id");
                rs.close();
                ps.close();

                // Hash new password using BCrypt
                String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

                // Update password in DB
                PreparedStatement psUpdate = con.prepareStatement("UPDATE users SET password=? WHERE id=?");
                psUpdate.setString(1, hashedPassword);
                psUpdate.setInt(2, userId);
                psUpdate.executeUpdate();
                psUpdate.close();

                response.sendRedirect("login.jsp?msg=Password+updated+successfully!+Please+login+with+your+new+password.");
            } else {
                rs.close();
                ps.close();
                response.sendRedirect("forgotPassword.jsp?error=Invalid+Email+Address+or+Date+of+Birth+(DOB).");
            }

        } catch (Throwable t) {
            t.printStackTrace();
            response.sendRedirect("forgotPassword.jsp?error=Server+error+occurred.+Please+try+again.");
        }
    }
}
