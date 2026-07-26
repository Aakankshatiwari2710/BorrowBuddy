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

@WebServlet("/VerifyOtpServlet")
public class VerifyOtpServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("register.jsp");
            return;
        }

        // Combine 6 digit inputs if passed separately or as single string
        String enteredOtp = request.getParameter("otp");
        if (enteredOtp == null || enteredOtp.trim().isEmpty()) {
            String d1 = request.getParameter("otp1");
            String d2 = request.getParameter("otp2");
            String d3 = request.getParameter("otp3");
            String d4 = request.getParameter("otp4");
            String d5 = request.getParameter("otp5");
            String d6 = request.getParameter("otp6");
            if (d1 != null && d2 != null && d3 != null && d4 != null && d5 != null && d6 != null) {
                enteredOtp = d1.trim() + d2.trim() + d3.trim() + d4.trim() + d5.trim() + d6.trim();
            }
        }

        if (enteredOtp == null || enteredOtp.trim().length() < 6) {
            response.sendRedirect("verifyOtp.jsp?error=Please+enter+the+full+6-digit+OTP+code.");
            return;
        }

        String pendingEmail = (String) session.getAttribute("pending_email");
        String pendingOtp = (String) session.getAttribute("pending_otp");

        // 🌟 CASE 1: PRE-VERIFICATION REGISTRATION FLOW (Insert to DB ONLY when OTP matches)
        if (pendingEmail != null && pendingOtp != null) {
            if (enteredOtp.trim().equalsIgnoreCase(pendingOtp.trim())) {
                String pendingName = (String) session.getAttribute("pending_name");
                String pendingPassword = (String) session.getAttribute("pending_password");
                String pendingLocation = (String) session.getAttribute("pending_location");
                String pendingRole = (String) session.getAttribute("pending_role");

                try (Connection con = DBConnection.getConnection()) {
                    if (con == null) {
                        response.sendRedirect("verifyOtp.jsp?error=Database+connection+failed.");
                        return;
                    }

                    // 🔒 INSERT USER INTO DATABASE NOW ONLY AFTER SUCCESSFUL EMAIL OTP VERIFICATION
                    PreparedStatement psInsert = con.prepareStatement(
                        "INSERT INTO users(name, email, password, location, role, email_verified, profile_image) VALUES(?, ?, ?, ?, ?, TRUE, 'default_profile.png')",
                        java.sql.Statement.RETURN_GENERATED_KEYS
                    );
                    psInsert.setString(1, pendingName);
                    psInsert.setString(2, pendingEmail);
                    psInsert.setString(3, pendingPassword);
                    psInsert.setString(4, pendingLocation);
                    psInsert.setString(5, pendingRole);

                    psInsert.executeUpdate();

                    ResultSet rsKeys = psInsert.getGeneratedKeys();
                    int newUserId = 0;
                    if (rsKeys.next()) {
                        newUserId = rsKeys.getInt(1);
                    }
                    rsKeys.close();
                    psInsert.close();

                    // Set logged-in session state
                    session.setAttribute("userId", newUserId);
                    session.setAttribute("userName", pendingName);
                    session.setAttribute("userEmail", pendingEmail);
                    session.setAttribute("userRole", pendingRole);
                    session.setAttribute("userImage", "default_profile.png");

                    // Clear pending session variables
                    session.removeAttribute("pending_name");
                    session.removeAttribute("pending_email");
                    session.removeAttribute("pending_password");
                    session.removeAttribute("pending_location");
                    session.removeAttribute("pending_role");
                    session.removeAttribute("pending_otp");

                    // Send Welcome Email
                    EmailUtil.sendEmailAsync(
                        pendingEmail, 
                        "Welcome to SpanV Studios! ✨", 
                        EmailUtil.buildWelcomeTemplate(pendingName != null ? pendingName : "Customer")
                    );

                    response.sendRedirect("dashboard.jsp?msg=Email+Verified+and+Account+Registered+Successfully!+Welcome+to+SpanV+Studios.");
                    return;

                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect("verifyOtp.jsp?error=Registration+failed:+" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
                    return;
                }

            } else {
                response.sendRedirect("verifyOtp.jsp?error=Invalid+OTP+code.+Please+check+your+email+inbox+and+try+again.");
                return;
            }
        }

        // 🌟 CASE 2: EXISTING USER DB VERIFICATION FLOW
        String userEmail = (String) session.getAttribute("userEmail");
        if (userEmail == null) {
            response.sendRedirect("register.jsp");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("verifyOtp.jsp?error=Database+connection+failed.");
                return;
            }

            PreparedStatement ps = con.prepareStatement("SELECT otp_code, name, role FROM users WHERE email=?");
            ps.setString(1, userEmail);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String dbOtp = rs.getString("otp_code");
                String name = rs.getString("name");
                rs.close();
                ps.close();

                if (dbOtp != null && dbOtp.trim().equalsIgnoreCase(enteredOtp.trim())) {
                    PreparedStatement psUpdate = con.prepareStatement("UPDATE users SET email_verified=TRUE, otp_code=NULL WHERE email=?");
                    psUpdate.setString(1, userEmail);
                    psUpdate.executeUpdate();
                    psUpdate.close();

                    PreparedStatement psUser = con.prepareStatement("SELECT id, name, email, role, profile_image FROM users WHERE email=?");
                    psUser.setString(1, userEmail);
                    ResultSet rsUser = psUser.executeQuery();
                    if (rsUser.next()) {
                        session.setAttribute("userId", rsUser.getInt("id"));
                        session.setAttribute("userName", rsUser.getString("name"));
                        session.setAttribute("userEmail", rsUser.getString("email"));
                        session.setAttribute("userRole", rsUser.getString("role"));
                        String pImg = rsUser.getString("profile_image");
                        session.setAttribute("userImage", pImg != null && !pImg.isEmpty() ? pImg : "default_profile.png");
                    }
                    rsUser.close();
                    psUser.close();

                    EmailUtil.sendEmailAsync(userEmail, "Welcome to SpanV Studios! ✨", EmailUtil.buildWelcomeTemplate(name != null ? name : "Customer"));

                    response.sendRedirect("dashboard.jsp?msg=Account+Email+Verified+Successfully!+Welcome+to+SpanV+Studios");
                    return;
                } else {
                    response.sendRedirect("verifyOtp.jsp?error=Invalid+OTP+code.+Please+check+your+email+inbox+and+try+again.");
                    return;
                }
            } else {
                rs.close();
                ps.close();
                response.sendRedirect("register.jsp");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("verifyOtp.jsp?error=Verification+failed:+" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}
