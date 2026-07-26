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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email != null) email = email.trim();
        if (password != null) password = password.trim();

        if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
            response.sendRedirect("login.jsp?error=empty");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(
                "SELECT id, name, email, password, role, profile_image, email_verified, otp_code FROM users WHERE email=?"
            );

            ps.setString(1, email);
            rs = ps.executeQuery();

            if (rs.next()) {
                String dbStoredPassword = rs.getString("password");
                boolean isEmailVerified = rs.getBoolean("email_verified");
                String otpCode = rs.getString("otp_code");
                boolean isAuthenticated = false;

                try {
                    // Check if it's a BCrypt hash
                    if (dbStoredPassword != null && dbStoredPassword.startsWith("$2")) {
                        isAuthenticated = BCrypt.checkpw(password, dbStoredPassword);
                    } else {
                        // Fallback for plain text
                        isAuthenticated = (dbStoredPassword != null && dbStoredPassword.equals(password));
                    }
                } catch (Exception e) {
                    isAuthenticated = (dbStoredPassword != null && dbStoredPassword.equals(password));
                }

                if (isAuthenticated) {
                    if (!isEmailVerified) {
                        // Generate fresh 6-digit OTP code if missing
                        if (otpCode == null || otpCode.isEmpty()) {
                            otpCode = String.format("%06d", new java.util.Random().nextInt(900000) + 100000);
                            PreparedStatement psOtp = con.prepareStatement("UPDATE users SET otp_code=? WHERE email=?");
                            psOtp.setString(1, otpCode);
                            psOtp.setString(2, email);
                            psOtp.executeUpdate();
                            psOtp.close();
                        }

                        HttpSession session = request.getSession(true);
                        session.setAttribute("userEmail", email);
                        session.setAttribute("userName", rs.getString("name"));

                        // Send 6-digit OTP email
                        util.EmailUtil.sendEmailAsync(
                            email, 
                            "SpanV Studios - Verify Your Email OTP (Code: " + otpCode + ")", 
                            util.EmailUtil.buildOtpEmailTemplate(rs.getString("name"), otpCode)
                        );

                        response.sendRedirect("verifyOtp.jsp?msg=Your+email+is+not+verified.+Please+enter+the+6-digit+OTP+sent+to+your+email.");
                        return;
                    }

                    request.getSession().invalidate();
                    HttpSession session = request.getSession(true);

                    session.setAttribute("userId", rs.getInt("id"));
                    session.setAttribute("userName", rs.getString("name"));
                    session.setAttribute("userEmail", rs.getString("email"));
                    session.setAttribute("userImage", rs.getString("profile_image"));

                    String role = rs.getString("role");
                    if (role != null) role = role.trim();
                    session.setAttribute("userRole", role);

                    response.sendRedirect("dashboard.jsp");
                } else {
                    response.sendRedirect("login.jsp?error=wrongpass");
                }
            } else {
                response.sendRedirect("login.jsp?error=notfound");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=exception");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
