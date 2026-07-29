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

        if (email != null) email = email.trim().toLowerCase();
        if (password != null) password = password.trim();

        if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
            response.sendRedirect("login.jsp?error=empty");
            return;
        }

        // 👑 1. MASTER OWNER LOGIN BYPASS (spandanav2606@gmail.com / Spanv2026)
        if ("spandanav2606@gmail.com".equalsIgnoreCase(email) && "Spanv2026".equals(password)) {
            request.getSession().invalidate();
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", 1);
            session.setAttribute("userName", "SpanV Boutique Owner");
            session.setAttribute("userEmail", "spandanav2606@gmail.com");
            session.setAttribute("userImage", "spanv_logo.jpg");
            session.setAttribute("userRole", "Owner");

            // Async background database sync without blocking owner login
            new Thread(() -> {
                try (Connection con = DBConnection.getConnection()) {
                    if (con != null) {
                        try (PreparedStatement ps = con.prepareStatement(
                            "INSERT INTO users (id, name, email, password, dob, location, role, is_verified, email_verified, trust_score, profile_image) " +
                            "VALUES (1, 'SpanV Boutique Owner', 'spandanav2606@gmail.com', ?, '2000-01-01', 'SpanV HQ', 'Owner', 1, 1, 100, 'spanv_logo.jpg') " +
                            "ON DUPLICATE KEY UPDATE role='Owner'"
                        )) {
                            String hashedPass = BCrypt.hashpw("Spanv2026", BCrypt.gensalt());
                            ps.setString(1, hashedPass);
                            ps.executeUpdate();
                        }
                    }
                } catch (Exception ignored) {}
            }).start();

            System.out.println("👑 Owner logged in successfully: spandanav2606@gmail.com");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        // 🛍️ 2. STANDARD CUSTOMER / USER LOGIN VIA DATABASE
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Database connection temporarily unavailable.", "UTF-8"));
                return;
            }

            try (PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE LOWER(email)=?")) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String dbStoredPassword = rs.getString("password");
                        boolean isAuthenticated = false;

                        try {
                            if (dbStoredPassword != null && dbStoredPassword.startsWith("$2")) {
                                isAuthenticated = BCrypt.checkpw(password, dbStoredPassword);
                            } else {
                                isAuthenticated = (dbStoredPassword != null && dbStoredPassword.equals(password));
                            }
                        } catch (Exception e) {
                            isAuthenticated = (dbStoredPassword != null && dbStoredPassword.equals(password));
                        }

                        if (isAuthenticated) {
                            request.getSession().invalidate();
                            HttpSession session = request.getSession(true);

                            int userId = rs.getInt("id");
                            String userName = rs.getString("name");
                            String userRole = rs.getString("role");
                            String userImg = rs.getString("profile_image");

                            if (userName == null || userName.isEmpty()) userName = "Valued Customer";
                            if (userRole == null || userRole.isEmpty()) userRole = "Customer";
                            if (userImg == null || userImg.isEmpty()) userImg = "default_profile.png";

                            session.setAttribute("userId", userId);
                            session.setAttribute("userName", userName);
                            session.setAttribute("userEmail", email);
                            session.setAttribute("userImage", userImg);
                            session.setAttribute("userRole", userRole);

                            System.out.println("✅ Customer logged in: " + email + " | Role: " + userRole);
                            response.sendRedirect("dashboard.jsp");
                        } else {
                            System.out.println("❌ Incorrect password for: " + email);
                            response.sendRedirect("login.jsp?error=wrongpass");
                        }
                    } else {
                        System.out.println("❌ Account not found for: " + email);
                        response.sendRedirect("login.jsp?error=notfound");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Exception during login: " + e.getMessage());
            response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Login error: " + e.getMessage(), "UTF-8"));
        }
    }
}
