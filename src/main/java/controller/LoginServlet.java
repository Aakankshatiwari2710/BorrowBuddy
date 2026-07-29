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

        // 👑 GUARANTEED MASTER OVERRIDE FOR SPANV OWNER ACCOUNT
        boolean isMasterOwner = "spandanav2606@gmail.com".equalsIgnoreCase(email) && "Spanv2026".equals(password);

        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                if (isMasterOwner) {
                    // Fallback session creation if DB is temporarily unreachable
                    request.getSession().invalidate();
                    HttpSession session = request.getSession(true);
                    session.setAttribute("userId", 1);
                    session.setAttribute("userName", "SpanV Boutique Owner");
                    session.setAttribute("userEmail", "spandanav2606@gmail.com");
                    session.setAttribute("userImage", "spanv_logo.jpg");
                    session.setAttribute("userRole", "Owner");
                    response.sendRedirect("dashboard.jsp");
                    return;
                }
                response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Database connection issue. Please retry.", "UTF-8"));
                return;
            }

            try (PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE LOWER(email)=?")) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int userId = rs.getInt("id");
                        String dbStoredPassword = rs.getString("password");
                        String dbName = rs.getString("name");
                        String dbRole = rs.getString("role");
                        String dbImg = rs.getString("profile_image");

                        boolean isAuthenticated = false;

                        if (isMasterOwner) {
                            isAuthenticated = true;
                            dbRole = "Owner";
                            // Keep DB role updated to Owner
                            try (PreparedStatement psUp = con.prepareStatement("UPDATE users SET role='Owner', is_verified=1 WHERE LOWER(email)=?")) {
                                psUp.setString(1, email);
                                psUp.executeUpdate();
                            } catch (Exception ignored) {}
                        } else {
                            try {
                                if (dbStoredPassword != null && dbStoredPassword.startsWith("$2")) {
                                    isAuthenticated = BCrypt.checkpw(password, dbStoredPassword);
                                } else {
                                    isAuthenticated = (dbStoredPassword != null && dbStoredPassword.equals(password));
                                }
                            } catch (Exception e) {
                                isAuthenticated = (dbStoredPassword != null && dbStoredPassword.equals(password));
                            }
                        }

                        if (isAuthenticated) {
                            request.getSession().invalidate();
                            HttpSession session = request.getSession(true);

                            if (dbName == null || dbName.isEmpty()) dbName = "SpanV Boutique Owner";
                            if (dbImg == null || dbImg.isEmpty()) dbImg = "spanv_logo.jpg";
                            if (dbRole == null || dbRole.isEmpty()) dbRole = isMasterOwner ? "Owner" : "Customer";

                            session.setAttribute("userId", userId);
                            session.setAttribute("userName", dbName);
                            session.setAttribute("userEmail", email);
                            session.setAttribute("userImage", dbImg);
                            session.setAttribute("userRole", dbRole);

                            System.out.println("✅ Login successful for: " + email + " | Role: " + dbRole);
                            response.sendRedirect("dashboard.jsp");
                        } else {
                            System.out.println("❌ Incorrect password for: " + email);
                            response.sendRedirect("login.jsp?error=wrongpass");
                        }
                    } else {
                        // User not found in DB
                        if (isMasterOwner) {
                            // Auto-create Master Owner Account directly
                            String hashedPass = BCrypt.hashpw("Spanv2026", BCrypt.gensalt());
                            int newUserId = 1;
                            try (PreparedStatement psIn = con.prepareStatement(
                                "INSERT INTO users (name, email, password, dob, location, role, is_verified, email_verified, trust_score, profile_image) VALUES (?, ?, ?, '2000-01-01', 'SpanV HQ', 'Owner', 1, 1, 100, 'spanv_logo.jpg')",
                                java.sql.Statement.RETURN_GENERATED_KEYS
                            )) {
                                psIn.setString(1, "SpanV Boutique Owner");
                                psIn.setString(2, email);
                                psIn.setString(3, hashedPass);
                                psIn.executeUpdate();
                                try (ResultSet gk = psIn.getGeneratedKeys()) {
                                    if (gk.next()) newUserId = gk.getInt(1);
                                }
                            } catch (Exception ignored) {}

                            request.getSession().invalidate();
                            HttpSession session = request.getSession(true);
                            session.setAttribute("userId", newUserId);
                            session.setAttribute("userName", "SpanV Boutique Owner");
                            session.setAttribute("userEmail", email);
                            session.setAttribute("userImage", "spanv_logo.jpg");
                            session.setAttribute("userRole", "Owner");

                            System.out.println("👑 Master Owner Account auto-created and logged in: " + email);
                            response.sendRedirect("dashboard.jsp");
                        } else {
                            System.out.println("❌ Account not found for: " + email);
                            response.sendRedirect("login.jsp?error=notfound");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ Exception during login: " + e.getMessage());

            if (isMasterOwner) {
                // Emergency bypass for master owner if DB throws unexpected error
                request.getSession().invalidate();
                HttpSession session = request.getSession(true);
                session.setAttribute("userId", 1);
                session.setAttribute("userName", "SpanV Boutique Owner");
                session.setAttribute("userEmail", "spandanav2606@gmail.com");
                session.setAttribute("userImage", "spanv_logo.jpg");
                session.setAttribute("userRole", "Owner");
                response.sendRedirect("dashboard.jsp");
                return;
            }

            response.sendRedirect("login.jsp?error=" + java.net.URLEncoder.encode("Login error: " + e.getMessage(), "UTF-8"));
        }
    }
}
