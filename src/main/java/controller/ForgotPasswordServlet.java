package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import util.DBConnection;
import util.EmailUtil;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        if (email != null) email = email.trim();

        if (email == null || email.isEmpty()) {
            response.sendRedirect("forgotPassword.jsp?error=Please+enter+your+email+address.");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("forgotPassword.jsp?error=Database+connection+failed.");
                return;
            }

            PreparedStatement ps = con.prepareStatement("SELECT name FROM users WHERE email=?");
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String userName = rs.getString("name");
                rs.close();
                ps.close();

                // 🔐 Generate 6-Digit Password Reset OTP
                String resetOtp = String.format("%06d", new java.util.Random().nextInt(900000) + 100000);

                PreparedStatement psUpdate = con.prepareStatement("UPDATE users SET otp_code=? WHERE email=?");
                psUpdate.setString(1, resetOtp);
                psUpdate.setString(2, email);
                psUpdate.executeUpdate();
                psUpdate.close();

                HttpSession session = request.getSession(true);
                session.setAttribute("resetEmail", email);

                // 📧 Send Password Reset OTP Email
                EmailUtil.sendEmailAsync(
                    email, 
                    "SpanV Studios - Password Reset OTP (Code: " + resetOtp + ")",
                    EmailUtil.buildOtpEmailTemplate(userName != null ? userName : "Customer", resetOtp)
                );

                response.sendRedirect("resetPassword.jsp?msg=Password+reset+OTP+code+sent+to+your+email!");
                return;

            } else {
                rs.close();
                ps.close();
                response.sendRedirect("forgotPassword.jsp?error=No+account+found+with+this+email+address.");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("forgotPassword.jsp?error=Server+error:+" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}
