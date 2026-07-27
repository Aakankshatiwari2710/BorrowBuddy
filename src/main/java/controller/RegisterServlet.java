package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
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
        String dob = request.getParameter("dob");
        String location = request.getParameter("location");
        String role = request.getParameter("role");

        if (name != null) name = name.trim();
        if (email != null) email = email.trim().toLowerCase();
        if (password != null) password = password.trim();
        if (dob != null) dob = dob.trim();
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

            // Ensure 'dob' column exists in MySQL table on live server
            try (Statement stmt = con.createStatement()) {
                stmt.executeUpdate("ALTER TABLE users ADD COLUMN dob VARCHAR(20) NULL");
            } catch (Exception ignored) {
                // Column already exists or handled by MySQL
            }

            // 1. Check duplicate email
            PreparedStatement psCheck = con.prepareStatement("SELECT id FROM users WHERE LOWER(email)=?");
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

            // 2. Hash password & insert user directly with DOB into database
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
            int newUserId = 0;

            try {
                PreparedStatement psInsert = con.prepareStatement(
                    "INSERT INTO users (name, email, password, dob, location, role, is_verified, email_verified, trust_score, profile_image) VALUES (?, ?, ?, ?, ?, ?, TRUE, TRUE, 10, 'default_profile.png')",
                    Statement.RETURN_GENERATED_KEYS
                );
                psInsert.setString(1, name);
                psInsert.setString(2, email);
                psInsert.setString(3, hashedPassword);
                psInsert.setString(4, dob);
                psInsert.setString(5, location);
                psInsert.setString(6, role);

                int affectedRows = psInsert.executeUpdate();
                if (affectedRows > 0) {
                    ResultSet rsKeys = psInsert.getGeneratedKeys();
                    if (rsKeys.next()) {
                        newUserId = rsKeys.getInt(1);
                    }
                    rsKeys.close();
                }
                psInsert.close();
            } catch (Exception sqlEx) {
                // Fallback insert without dob column if DB schema mismatch occurs
                System.err.println("⚠️ Inserting with dob failed, falling back: " + sqlEx.getMessage());
                PreparedStatement psFallback = con.prepareStatement(
                    "INSERT INTO users (name, email, password, location, role, is_verified, email_verified, trust_score, profile_image) VALUES (?, ?, ?, ?, ?, TRUE, TRUE, 10, 'default_profile.png')",
                    Statement.RETURN_GENERATED_KEYS
                );
                psFallback.setString(1, name);
                psFallback.setString(2, email);
                psFallback.setString(3, hashedPassword);
                psFallback.setString(4, location);
                psFallback.setString(5, role);

                int affected = psFallback.executeUpdate();
                if (affected > 0) {
                    ResultSet rsKeys = psFallback.getGeneratedKeys();
                    if (rsKeys.next()) {
                        newUserId = rsKeys.getInt(1);
                    }
                    rsKeys.close();
                }
                psFallback.close();
            }

            // 3. Create active User Session & Auto-login
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", newUserId);
            session.setAttribute("userName", name);
            session.setAttribute("userEmail", email);
            session.setAttribute("userRole", role);
            session.setAttribute("userLocation", location);

            // 4. Redirect directly to Dashboard
            response.sendRedirect("dashboard.jsp?msg=welcome");

        } catch (Throwable t) {
            t.printStackTrace(); 
            response.sendRedirect("register.jsp?error=server_error");
        }
    }
}
