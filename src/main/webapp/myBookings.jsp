<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>
<% Integer userId=(Integer) session.getAttribute("userId"); if(userId==null){
    response.sendRedirect("login.jsp"); return; } String msg=request.getParameter("msg"); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders | SpanV Studios</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #db2777; --secondary: #be185d; --bg: #fff1f2; --text: #2d0b1e; }
        body { margin: 0; font-family: 'Outfit', sans-serif; background: var(--bg); color: var(--text); }
        .main-content { margin-left: 260px; padding: 40px; }
        .header { margin-bottom: 30px; }
        .header h1 { font-size: 28px; margin: 0; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(400px, 1fr)); gap: 20px; }
        .booking-card { background: white; border-radius: 20px; padding: 25px; display: flex; flex-direction: column; gap: 20px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); transition: 0.3s; position: relative; }
        .booking-card:hover { transform: translateY(-3px); box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08); }
        .card-main { display: flex; gap: 20px; align-items: start; }
        .booking-card img { width: 110px; height: 110px; border-radius: 15px; object-fit: cover; border: 1px solid #f1f5f9; }
        .booking-info { flex: 1; }
        .booking-info h3 { margin: 0 0 5px; font-size: 19px; color: var(--text); }
        .status-badge { display: inline-block; padding: 4px 12px; border-radius: 50px; font-size: 11px; font-weight: 700; text-transform: uppercase; margin-bottom: 12px; }
        .status-Pending { background: #fef3c7; color: #92400e; }
        .status-Approved { background: #dcfce7; color: #166534; }
        .status-Rejected { background: #fee2e2; color: #991b1b; }
        .payment-badge { position: absolute; top: 25px; right: 25px; font-size: 12px; font-weight: 800; padding: 5px 12px; border-radius: 10px; }
        .payment-Unpaid { background: #f1f5f9; color: #64748b; }
        .payment-Paid { background: #10b981; color: white; }
        .date-info { font-size: 13px; color: #64748b; margin-bottom: 12px; line-height: 1.5; }
        .price-info { font-size: 15px; font-weight: 700; color: var(--primary); margin-bottom: 15px; }
        .btn-chat { display: inline-block; padding: 10px 20px; background: #f1f5f9; color: #334155; text-decoration: none; border-radius: 10px; font-size: 13px; font-weight: 700; transition: 0.3s; border: 1px solid #e2e8f0; }
        .btn-chat:hover { background: #e2e8f0; transform: translateY(-1px); }
        .btn-pay { display: inline-block; padding: 10px 20px; background: var(--primary); color: white; text-decoration: none; border-radius: 10px; font-size: 13px; font-weight: 700; transition: 0.3s; border: none; cursor: pointer; }
        .btn-pay:hover { background: var(--secondary); transform: translateY(-1px); }
        .alert { padding: 15px 20px; background: #dcfce7; color: #166534; border-radius: 12px; margin-bottom: 25px; border-left: 5px solid #22c55e; }

        @media (max-width: 992px) {
            .main-content { margin-left: 0 !important; padding: 80px 15px 30px !important; }
            .grid { grid-template-columns: 1fr; }
            .header h1 { font-size: 24px; }
            .card-main { flex-direction: column; }
            .payment-badge { position: static; display: inline-block; margin-bottom: 10px; }
        }
    </style>
</head>
<body>
    <jsp:include page="layout/sidebar.jsp" />
    <div class="main-content">
        <div class="header">
            <h1>My Orders</h1>
            <p style="color: #64748b;">Manage your boutique purchases and chats with sellers.</p>
        </div>

        <% if ("paid".equals(msg)) { %><div class="alert" style="background:#fce7f3; color:#9d174d; border-color:#db2777;">✅ Payment successful! Your order is confirmed.</div><% } %>
        <% if ("payment_failed".equals(request.getParameter("error"))) { %><div class="alert" style="background: #fee2e2; color: #991b1b; border-color: #ef4444;">❌ Payment failed. Please try again.</div><% } %>

        <div class="grid">
            <% 
            String sql = "SELECT b.id, b.item_id, b.status, b.payment_status, b.start_date, b.end_date, b.rating_id, "
                       + "b.shipping_address, b.shipping_city, b.shipping_pincode, b.shipping_phone, "
                       + "i.name, i.image, i.price, u.id AS owner_id "
                       + "FROM bookings b JOIN items i ON b.item_id = i.id JOIN users u ON u.email = i.owner_email "
                       + "WHERE b.borrower_id=? ORDER BY b.id DESC";
            
            try (Connection con = DBConnection.getConnection(); 
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    boolean found = false;
                    while(rs.next()){
                        found = true;
                        String status = rs.getString("status");
                        String payStatus = rs.getString("payment_status") != null ? rs.getString("payment_status") : "Unpaid";
                        String imgName = rs.getString("image") != null && !rs.getString("image").isEmpty() ? rs.getString("image") : "default.png";
                        int owner_id = rs.getInt("owner_id");
                        int item_id = rs.getInt("item_id");
                        int booking_id = rs.getInt("id");
                        int ratingId = rs.getInt("rating_id");
                        String shipAddr = rs.getString("shipping_address");
                        String shipCity = rs.getString("shipping_city");
                        String shipPin = rs.getString("shipping_pincode");
                        String shipPhone = rs.getString("shipping_phone");
                        
                        double pph = rs.getDouble("price");
                        Timestamp st = rs.getTimestamp("start_date");
                        long totalCost = (long)pph;
            %>
                <div class="booking-card">
                    <div class="payment-badge payment-<%= payStatus %>"><%= payStatus.equals("Paid") ? "✓ PAID" : "UNPAID" %></div>
                    
                    <div class="card-main">
                        <img src="<%=request.getContextPath()%>/images/<%=imgName%>" onerror="this.src='<%=request.getContextPath()%>/images/default.png'">
                        <div class="booking-info">
                            <span class="status-badge status-<%=status%>"><%=status%></span>
                            <h3><%=rs.getString("name")%></h3>
                            <div class="date-info">
                                <% java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy"); %>
                                <strong>Order Date:</strong> <%= (st != null) ? sdf.format(st) : "" %>
                            </div>
                            <div class="price-info">Total Amount: ₹<%= totalCost %></div>
                            
                            <% if (shipAddr != null && !shipAddr.trim().isEmpty()) { %>
                                <div style="font-size:12px; color:#475569; background:#f8fafc; padding:8px 12px; border-radius:8px; border:1px solid #e2e8f0; margin-top:6px;">
                                    📦 <strong>Delivery To:</strong> <%= shipAddr %>, <%= shipCity != null ? shipCity : "" %> (<%= shipPin != null ? shipPin : "" %>) | 📞 <%= shipPhone != null ? shipPhone : "" %>
                                </div>
                            <% } %>
                            
                            <div style="display:flex; gap:10px; flex-wrap:wrap; margin-top:5px;">
                                
                                <% if ("Approved".equalsIgnoreCase(status) && ratingId == 0) { %>
                                    <button onclick="showRatingForm(<%= booking_id %>)" class="btn-pay" style="background:#f59e0b;">⭐ Rate Product</button>
                                <% } else if (ratingId > 0) { %>
                                    <span style="font-size:13px; color:#10b981; font-weight:700; padding:10px 0;">✓ Rated</span>
                                <% } %>

                                <% if ("Approved".equalsIgnoreCase(status) && !"Paid".equalsIgnoreCase(payStatus)) { %>
                                     <a href="payNow.jsp?bookingId=<%= booking_id %>" class="btn-pay">💳 Pay Now</a>
                                <% } %>

                                <% if (!"Cancelled".equalsIgnoreCase(status) && !"Returned".equalsIgnoreCase(status)) { %>
                                    <a href="CancelBookingServlet?id=<%= booking_id %>&redirect=myBookings.jsp" 
                                       class="btn-pay" 
                                       style="background:#ef4444; color:white; text-decoration:none;"
                                       onclick="return confirm('Are you sure you want to cancel this order?');">❌ Cancel Order</a>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Hidden Rating Form -->
                    <div id="rate-form-<%= booking_id %>" style="display:none; transition: 0.3s;">
                        <div style="background:#f8fafc; padding:20px; border-radius:15px; border:1px solid #e2e8f0; margin-top:10px;">
                            <h4 style="margin: 0 0 15px; font-size:16px;">Share your experience</h4>
                            <form action="SubmitReviewServlet" method="post">
                                <input type="hidden" name="bookingId" value="<%= booking_id %>">
                                <input type="hidden" name="itemId" value="<%= item_id %>">
                                <div style="margin-bottom:12px;">
                                    <label style="font-size:13px; font-weight:600; display:block; margin-bottom:5px;">Your Rating:</label>
                                    <select name="rating" required style="width:100%; padding:10px; border-radius:10px; border:1px solid #cbd5e1;">
                                        <option value="5">⭐⭐⭐⭐⭐ (Excellent)</option>
                                        <option value="4">⭐⭐⭐⭐ (Good)</option>
                                        <option value="3">⭐⭐⭐ (Average)</option>
                                        <option value="2">⭐⭐ (Poor)</option>
                                        <option value="1">⭐ (Terrible)</option>
                                    </select>
                                </div>
                                <div style="margin-bottom:15px;">
                                    <textarea name="comment" placeholder="How was the item? Was the owner helpful?" required style="width:100%; padding:12px; border-radius:10px; border:1px solid #cbd5e1; min-height:80px; font-family:inherit; font-size:14px; box-sizing:border-box;"></textarea>
                                </div>
                                <div style="display:flex; gap:12px;">
                                    <button type="submit" class="btn-pay" style="flex:1;">Submit Review</button>
                                    <button type="button" onclick="hideRatingForm(<%= booking_id %>)" style="flex:1; background:#94a3b8; border:none; color:white; border-radius:10px; font-weight:700; cursor:pointer;">Cancel</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            <% 
                    } 
                    if(!found){ 
            %>
                <div style="grid-column: 1/-1; text-align: center; padding: 60px; background: white; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
                    <p style="color: #64748b; font-size:16px; margin-bottom:20px;">You haven't borrowed anything yet.</p>
                    <a href="viewItems.jsp" class="btn-pay" style="text-decoration:none;">Browse Items Near You</a>
                </div>
            <% 
                    } 
                } 
            } catch(Exception e) { 
                e.printStackTrace(); 
            %>
                <div style="grid-column: 1/-1; color: #ef4444; background: #fee2e2; padding: 25px; border-radius:15px; text-align: center; font-weight:600;">
                    Error loading bookings: <%=e.getMessage()%>
                </div>
            <% } %>
        </div>
    </div>
    <script>
        function showRatingForm(id) { document.getElementById('rate-form-' + id).style.display = 'block'; }
        function hideRatingForm(id) { document.getElementById('rate-form-' + id).style.display = 'none'; }
    </script>
</body>
</html>