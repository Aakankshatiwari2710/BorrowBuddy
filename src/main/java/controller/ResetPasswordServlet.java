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

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("resetEmail") == null) {
            response.sendRedirect("forgotPassword.jsp");
            return;
        }

        String email = (String) session.getAttribute("resetEmail");
        String enteredOtp = request.getParameter("otp");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (enteredOtp != null) enteredOtp = enteredOtp.trim();
        if (newPassword != null) newPassword = newPassword.trim();
        if (confirmPassword != null) confirmPassword = confirmPassword.trim();

        if (enteredOtp == null || enteredOtp.isEmpty() || newPassword == null || newPassword.isEmpty()) {
            response.sendRedirect("resetPassword.jsp?error=Please+fill+in+all+required+fields.");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect("resetPassword.jsp?error=Passwords+do+not+match.+Please+try+again.");
            return;
        }

        if (newPassword.length() < 6) {
            response.sendRedirect("resetPassword.jsp?error=Password+must+be+at+least+6+characters+long.");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("resetPassword.jsp?error=Database+connection+failed.");
                return;
            }

            PreparedStatement ps = con.prepareStatement("SELECT otp_code FROM users WHERE email=?");
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String dbOtp = rs.getString("otp_code");
                rs.close();
                ps.close();

                if (dbOtp != null && dbOtp.trim().equalsIgnoreCase(enteredOtp)) {
                    // 🔒 Hash the new password using BCrypt
                    String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

                    PreparedStatement psUpdate = con.prepareStatement(
                        "UPDATE users SET password=?, otp_code=NULL, email_verified=TRUE WHERE email=?"
                    );
                    psUpdate.setString(1, hashedPassword);
                    psUpdate.setString(2, email);
                    psUpdate.executeUpdate();
                    psUpdate.close();

                    session.invalidate();

                    response.sendRedirect("login.jsp?msg=Password+Reset+Successfully!+Please+log+in+with+your+new+password.");
                    return;

                } else {
                    response.sendRedirect("resetPassword.jsp?error=Invalid+OTP+code.+Please+check+and+try+again.");
                    return;
                }
            } else {
                rs.close();
                ps.close();
                response.sendRedirect("forgotPassword.jsp?error=User+account+not+found.");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("resetPassword.jsp?error=Password+reset+failed:+" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}
