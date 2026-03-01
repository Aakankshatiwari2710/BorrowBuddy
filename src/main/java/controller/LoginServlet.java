package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

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

        if (email == null || password == null || 
            email.isEmpty() || password.isEmpty()) {

            response.sendRedirect("login.jsp?error=empty");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {

            con = DBConnection.getConnection();

            ps = con.prepareStatement(
                "SELECT id, name, email, password, role, profile_image FROM users WHERE email=?"
            );

            ps.setString(1, email);
            rs = ps.executeQuery();

            if (rs.next()) {

                String dbPassword = rs.getString("password");

                if (dbPassword != null && dbPassword.equals(password)) {

                    // 🔒 fresh session
                    request.getSession().invalidate();
                    HttpSession session = request.getSession(true);

                    session.setAttribute("userId", rs.getInt("id"));
                    session.setAttribute("userName", rs.getString("name"));
                    session.setAttribute("userEmail", rs.getString("email"));
                    session.setAttribute("userImage", rs.getString("profile_image"));

                    String role = rs.getString("role");
                    if (role != null) role = role.trim();

                    session.setAttribute("userRole", role);

                    System.out.println("Login Success. Role = " + role);

                    // ✅ REDIRECT TO DASHBOARD PAGE ALWAYS INSTEAD OF SEPARATE ONES
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
        }
        finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
