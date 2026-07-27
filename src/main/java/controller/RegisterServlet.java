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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String location = request.getParameter("location");
        String role = request.getParameter("role");

        if (name != null) name = name.trim();
        if (email != null) email = email.trim().toLowerCase();
        if (password != null) password = password.trim();
        if (location != null) location = location.trim();

        if (name == null || email == null || password == null || role == null ||
            name.isEmpty() || email.isEmpty() || password.isEmpty() || role.isEmpty()) {
            response.sendRedirect("register.jsp?error=empty");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("register.jsp?error=db_connection_failed");
                return;
            }

            // 1. Check if email already exists in users table
            PreparedStatement psCheck = con.prepareStatement("SELECT id FROM users WHERE email=?");
            psCheck.setString(1, email);
            ResultSet rsCheck = psCheck.executeQuery();

            if (rsCheck.next()) {
                rsCheck.close();
                psCheck.close();
                response.sendRedirect("register.jsp?error=duplicate_email");
                return;
            }
            rsCheck.close();
            psCheck.close();

            // 2. Hash password & generate 6-digit random OTP
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
            String otpCode = String.format("%06d", new java.util.Random().nextInt(900000) + 100000);

            // 3. Save pending registration data in Session (Requires OTP verification to insert into DB)
            HttpSession session = request.getSession(true);
            session.setAttribute("pending_name", name);
            session.setAttribute("pending_email", email);
            session.setAttribute("pending_password", hashedPassword);
            session.setAttribute("pending_location", location);
            session.setAttribute("pending_role", role);
            session.setAttribute("pending_otp", otpCode);

            // 4. Send 6-Digit OTP Email via JavaMail to user's inbox
            util.EmailUtil.sendEmailAsync(
                email, 
                "SpanV Studios - Verify Your Email OTP (Code: " + otpCode + ")", 
                util.EmailUtil.buildOtpEmailTemplate(name, otpCode)
            );

            // 5. Redirect to OTP verification page
            response.sendRedirect("verifyOtp.jsp?msg=Please+enter+the+6-digit+OTP+sent+to+your+email+to+complete+registration.");

        } catch (Throwable t) {
            t.printStackTrace(); 
            response.sendRedirect("register.jsp?error=server_error");
        }
    }
}
