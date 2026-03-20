package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.DBConnection;

@WebServlet("/SubmitReviewServlet")
public class SubmitReviewServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        int itemId = Integer.parseInt(request.getParameter("itemId"));
        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        String comment = request.getParameter("comment");

        try (Connection con = DBConnection.getConnection()) {
            // 1. Insert into reviews table
            String q1 = "INSERT INTO reviews (item_id, reviewer_id, rating, comment) VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps1 = con.prepareStatement(q1, Statement.RETURN_GENERATED_KEYS)) {
                ps1.setInt(1, itemId);
                ps1.setInt(2, userId);
                ps1.setInt(3, rating);
                ps1.setString(4, comment);
                ps1.executeUpdate();
                
                int reviewId = 0;
                try (ResultSet rs = ps1.getGeneratedKeys()) {
                    if (rs.next()) reviewId = rs.getInt(1);
                }
                
                // 2. Update booking with rating_id
                String q2 = "UPDATE bookings SET rating_id = ? WHERE id = ?";
                try (PreparedStatement ps2 = con.prepareStatement(q2)) {
                    ps2.setInt(1, reviewId);
                    ps2.setInt(2, bookingId);
                    ps2.executeUpdate();
                }
                
                // 3. Update trust score of the owner (mock logic)
                // Fetch item owner first
                String ownerQuery = "SELECT u.id FROM users u JOIN items i ON u.email = i.owner_email WHERE i.id = ?";
                int ownerId = 0;
                try (PreparedStatement ps3 = con.prepareStatement(ownerQuery)) {
                    ps3.setInt(1, itemId);
                    try (ResultSet rs3 = ps3.executeQuery()) {
                        if (rs3.next()) ownerId = rs3.getInt(1);
                    }
                }
                
                if (ownerId > 0) {
                    // Update trust score: +2 for 5 stars, +1 for 4 stars, -1 for 1 or 2 stars
                    int scoreChange = 0;
                    if (rating == 5) scoreChange = 2;
                    else if (rating == 4) scoreChange = 1;
                    else if (rating <= 2) scoreChange = -2;
                    
                    if (scoreChange != 0) {
                        String trustQuery = "UPDATE users SET trust_score = trust_score + ? WHERE id = ?";
                        try (PreparedStatement ps4 = con.prepareStatement(trustQuery)) {
                            ps4.setInt(1, scoreChange);
                            ps4.setInt(2, ownerId);
                            ps4.executeUpdate();
                        }
                    }
                }
            }
            
            response.sendRedirect("myBookings.jsp?msg=rated");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("myBookings.jsp?error=review_failed");
        }
    }
}
