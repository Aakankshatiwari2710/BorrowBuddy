package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import util.DBConnection;
import util.EmailUtil;

@WebServlet("/ResendOtpServlet")
public class ResendOtpServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String email = (String) session.getAttribute("userEmail");
        String userName = (String) session.getAttribute("userName");

        // 🔐 GENERATE NEW 6-DIGIT RANDOM OTP
        String newOtpCode = String.format("%06d", new java.util.Random().nextInt(900000) + 100000);

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("verifyOtp.jsp?error=Database+connection+failed.");
                return;
            }

            PreparedStatement ps = con.prepareStatement("UPDATE users SET otp_code=? WHERE email=?");
            ps.setString(1, newOtpCode);
            ps.setString(2, email);
            ps.executeUpdate();
            ps.close();

            // 📧 Send fresh 6-Digit OTP Email via JavaMail
            EmailUtil.sendEmailAsync(
                email, 
                "SpanV Studios - Resent Email OTP (Code: " + newOtpCode + ")", 
                EmailUtil.buildOtpEmailTemplate(userName != null ? userName : "Customer", newOtpCode)
            );

            response.sendRedirect("verifyOtp.jsp?msg=A+new+6-digit+OTP+code+has+been+sent+to+your+email!");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("verifyOtp.jsp?error=Resend+failed:+" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}
