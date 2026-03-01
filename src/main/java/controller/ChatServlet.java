package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/ChatServlet")
public class ChatServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int senderId = (Integer) session.getAttribute("userId");
        int receiverId = Integer.parseInt(request.getParameter("receiverId"));
        int itemId = Integer.parseInt(request.getParameter("itemId"));
        String message = request.getParameter("message");

        if (message == null || message.trim().isEmpty()) {
            response.sendRedirect("chat.jsp?user=" + receiverId + "&item=" + itemId);
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO messages (sender_id, receiver_id, item_id, message) VALUES (?, ?, ?, ?)"
            );

            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.setInt(3, itemId);
            ps.setString(4, message.trim());

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("chat.jsp?user=" + receiverId + "&item=" + itemId);
    }
}