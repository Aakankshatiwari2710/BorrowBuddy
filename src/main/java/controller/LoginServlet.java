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

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                System.err.println("❌ DB Connection is null during login for: " + email);
                response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Database connection failed. Please try again.", "UTF-8"));
                return;
            }

            try (PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM users WHERE LOWER(email)=?"
            )) {
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

                            session.setAttribute("userId", rs.getInt("id"));
                            session.setAttribute("userName", rs.getString("name"));
                            session.setAttribute("userEmail", rs.getString("email"));
                            
                            String img = "default_profile.png";
                            try { img = rs.getString("profile_image"); } catch (Exception ignored) {}
                            if (img == null || img.isEmpty()) img = "default_profile.png";
                            session.setAttribute("userImage", img);

                            String role = "Customer";
                            try { role = rs.getString("role"); } catch (Exception ignored) {}
                            if (role != null) role = role.trim();
                            session.setAttribute("userRole", role);

                            System.out.println("✅ User logged in successfully: " + email + " | Role: " + role);
                            response.sendRedirect("dashboard.jsp");
                        } else {
                            System.out.println("❌ Incorrect password for: " + email);
                            response.sendRedirect("login.jsp?error=wrongpass");
                        }
                    } else {
                        System.out.println("❌ User not found for email: " + email);
                        response.sendRedirect("login.jsp?error=notfound");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Exception during login: " + e.getMessage());
            response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Error: " + e.getMessage(), "UTF-8"));
        }
    }
}
