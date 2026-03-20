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
                        <title>My Bookings | BorrowBuddy</title>
                        <link
                            href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
                            rel="stylesheet">
                        <style>
                            :root {
                                --primary: #0f766e;
                                --secondary: #14b8a6;
                                --bg: #f8fafc;
                                --text: #1e293b;
                            }

                            body {
                                margin: 0;
                                font-family: 'Outfit', sans-serif;
                                background: var(--bg);
                                color: var(--text);
                            }

                            .main-content {
                                margin-left: 260px;
                                padding: 40px;
                            }

                            .header {
                                margin-bottom: 30px;
                            }

                            .header h1 {
                                font-size: 28px;
                                margin: 0;
                            }

                            .grid {
                                display: grid;
                                grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
                                gap: 20px;
                            }

                            .booking-card {
                                background: white;
                                border-radius: 20px;
                                padding: 20px;
                                display: flex;
                                align-items: center;
                                gap: 20px;
                                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
                                transition: 0.3s;
                                position: relative;
                            }

                            .booking-card:hover {
                                transform: translateY(-3px);
                                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
                            }

                            .booking-card img {
                                width: 100px;
                                height: 100px;
                                border-radius: 12px;
                                object-fit: cover;
                            }

                            .booking-info {
                                flex: 1;
                            }

                            .booking-info h3 {
                                margin: 0 0 5px;
                                font-size: 18px;
                            }

                            .status-badge {
                                display: inline-block;
                                padding: 4px 10px;
                                border-radius: 50px;
                                font-size: 11px;
                                font-weight: 700;
                                text-transform: uppercase;
                                margin-bottom: 10px;
                            }

                            .status-Pending {
                                background: #fef3c7;
                                color: #92400e;
                            }

                            .status-Approved {
                                background: #dcfce7;
                                color: #166534;
                            }

                            .status-Rejected {
                                background: #fee2e2;
                                color: #991b1b;
                            }

                            .payment-badge {
                                position: absolute;
                                top: 20px;
                                right: 20px;
                                font-size: 12px;
                                font-weight: bold;
                                padding: 4px 10px;
                                border-radius: 12px;
                            }

                            .payment-Unpaid {
                                background: #f1f5f9;
                                color: #64748b;
                            }

                            .payment-Paid {
                                background: #10b981;
                                color: white;
                            }

                            .date-info {
                                font-size: 13px;
                                color: #64748b;
                                margin-bottom: 10px;
                                line-height: 1.4;
                            }

                            .price-info {
                                font-size: 14px;
                                font-weight: 600;
                                color: var(--primary);
                                margin-bottom: 10px;
                            }

                            .btn-chat {
                                display: inline-block;
                                padding: 8px 18px;
                                background: #e2e8f0;
                                color: #334155;
                                text-decoration: none;
                                border-radius: 8px;
                                font-size: 13px;
                                font-weight: 600;
                                transition: 0.3s;
                            }

                            .btn-pay {
                                display: inline-block;
                                padding: 8px 18px;
                                background: var(--primary);
                                color: white;
                                text-decoration: none;
                                border-radius: 8px;
                                font-size: 13px;
                                font-weight: 600;
                                transition: 0.3s;
                                box-shadow: 0 2px 10px rgba(15, 118, 110, 0.2);
                            }

                            .btn-chat:hover {
                                background: #cbd5e1;
                            }

                            .btn-pay:hover {
                                background: var(--secondary);
                                transform: translateY(-1px);
                            }

                            .alert {
                                padding: 15px 20px;
                                background: #dcfce7;
                                color: #166534;
                                border-radius: 12px;
                                margin-bottom: 20px;
                                font-weight: 500;
                            }

                            @media (max-width: 600px) {
                                .booking-card {
                                    flex-direction: column;
                                    text-align: center;
                                }

                                .payment-badge {
                                    position: relative;
                                    top: 0;
                                    right: 0;
                                    display: inline-block;
                                    margin-bottom: 15px;
                                }
                            }
                        </style>
                    </head>

                    <body>
                        <jsp:include page="layout/sidebar.jsp" />
                        <div class="main-content">
                            <div class="header">
                                <h1>My Bookings</h1>
                                <p style="color: #64748b;">Manage items you've requested to borrow and complete
                                    payments.</p>
                            </div>

                            <% if ("paid".equals(msg)) { %>
                                <div class="alert">✅ Payment successful! Your booking is now confirmed and paid.</div>
                                <% } %>

                                    <% String error=request.getParameter("error"); if ("payment_failed".equals(error)) {
                                        %>
                                        <div class="alert" style="background: #fee2e2; color: #991b1b;">❌ Payment
                                            failed. Please try again or contact support.</div>
                                        <% } %>

                                            <div class="grid">
                                                <% String
                                                    sql="SELECT b.id, b.item_id, b.status, b.payment_status, b.start_date, b.end_date, b.rating_id, "
                                                    + "i.name, i.image, i.price, u.id AS owner_id "
                                                    + "FROM bookings b JOIN items i ON b.item_id = i.id JOIN users u ON u.email = i.owner_email "
                                                    + "WHERE b.borrower_id=? ORDER BY b.id DESC" ; try (Connection
                                                    con=DBConnection.getConnection(); PreparedStatement
                                                    ps=con.prepareStatement(sql)) { ps.setInt(1, userId); try (ResultSet
                                                    rs=ps.executeQuery()) { boolean found=false; while(rs.next()){
                                                    found=true; String status=rs.getString("status"); String
                                                    payStatus=rs.getString("payment_status"); if (payStatus==null)
                                                    payStatus="Unpaid" ; String imgName=rs.getString("image");
                                                    if(imgName==null || imgName.isEmpty()) imgName="default.png" ; int
                                                    owner_id=rs.getInt("owner_id"); int item_id=rs.getInt("item_id");
                                                    int booking_id=rs.getInt("id"); 
                                                    int ratingId = rs.getInt("rating_id");
                                                    /* Calculate cost per hour */ double
                                                    pricePerHour=rs.getDouble("price"); Timestamp
                                                    st=rs.getTimestamp("start_date"); Timestamp
                                                    ed=rs.getTimestamp("end_date"); long hours=1; if(st !=null && ed
                                                    !=null) { long diff=ed.getTime() - st.getTime();
                                                    hours=java.util.concurrent.TimeUnit.MILLISECONDS.toHours(diff);
                                                    if(hours==0) hours=1; } long totalCost=hours * (long)pricePerHour;
                                                    %>
                                                    <div class="booking-card">
                                                        <div class="payment-badge payment-<%= payStatus %>">
                                                            <%= payStatus.equals("Paid") ? "✓ PAID" : "UNPAID" %>
                                                        </div>
                                                        <img src="<%=request.getContextPath()%>/images/<%=imgName%>"
                                                            onerror="this.src='<%=request.getContextPath()%>/images/default.png'">
                                                        <div class="booking-info">
                                                            <span class="status-badge status-<%=status%>">
                                                                <%=status%>
                                                            </span>
                                                            <h3>
                                                                <%=rs.getString("name")%>
                                                            </h3>
                                                            <div class="date-info">
                                                                <% java.text.SimpleDateFormat sdf=new
                                                                    java.text.SimpleDateFormat("MMM dd, yyyy HH:mm"); %>
                                                                    <strong>Dates:</strong>
                                                                    <%= (st !=null) ? sdf.format(st) : "" %> <br>
                                                                        <strong>To:</strong>
                                                                        <%= (ed !=null) ? sdf.format(ed) : "" %>
                                                            </div>
                                                            <div class="price-info">Amount: ₹<%= totalCost %> (<%= hours
                                                                        %>
                                                                        <%= hours> 1 ? "hours" : "hour" %>)</div>

                                                                 <% if ("Approved".equalsIgnoreCase(status) && ratingId == 0) { %>
                                                                    <button onclick="showRatingForm(<%= booking_id %>, <%= item_id %>)" 
                                                                            class="btn-pay" style="background:#f59e0b;">⭐ Rate Item</button>
                                                                 <% } else if (ratingId > 0) { %>
                                                                    <span style="font-size:12px; color:#10b981; font-weight:600;">✓ Rated</span>
                                                                 <% } %>
                                                            </div>
                                                            <!-- Hidden Rating Form -->
                                                            <div id="rate-form-<%= booking_id %>" style="display:none; margin-top:15px; background:#f8fafc; padding:15px; border-radius:12px; border:1px solid #e2e8f0;">
                                                                <form action="SubmitReviewServlet" method="post">
                                                                    <input type="hidden" name="bookingId" value="<%= booking_id %>">
                                                                    <input type="hidden" name="itemId" value="<%= item_id %>">
                                                                    <div style="margin-bottom:10px;">
                                                                        <label style="font-size:12px; font-weight:600; display:block; margin-bottom:5px;">Rating:</label>
                                                                        <select name="rating" required style="width:100%; padding:8px; border-radius:8px; border:1px solid #cbd5e1;">
                                                                            <option value="5">⭐⭐⭐⭐⭐ (Excellent)</option>
                                                                            <option value="4">⭐⭐⭐⭐ (Good)</option>
                                                                            <option value="3">⭐⭐⭐ (Average)</option>
                                                                            <option value="2">⭐⭐ (Poor)</option>
                                                                            <option value="1">⭐ (Terrible)</option>
                                                                        </select>
                                                                    </div>
                                                                    <div style="margin-bottom:10px;">
                                                                        <textarea name="comment" placeholder="Write a short review..." required style="width:100%; padding:8px; border-radius:8px; border:1px solid #cbd5e1; min-height:60px; font-family:inherit;"></textarea>
                                                                    </div>
                                                                    <div style="display:flex; gap:10px;">
                                                                        <button type="submit" class="btn-pay" style="flex:1;">Submit</button>
                                                                        <button type="button" onclick="hideRatingForm(<%= booking_id %>)" style="flex:1; background:#94a3b8; border:none; color:white; border-radius:8px; font-weight:600; cursor:pointer;">Cancel</button>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <% } if(!found){ %>
                                                        <div
                                                            style="grid-column: 1/-1; text-align: center; padding: 60px; background: white; border-radius: 20px;">
                                                            <p style="color: #94a3b8;">You haven't borrowed anything
                                                                yet.</p>
                                                            <a href="viewItems.jsp"
                                                                style="color: var(--primary); font-weight: 600; text-decoration: none;">Browse
                                                                items near you →</a>
                                                        </div>
                                                        <% } } } catch(Exception e) { %>
                                                            <div
                                                                style="grid-column: 1/-1; color: #ef4444; background: white; padding: 20px; border-radius:12px; text-align: center;">
                                                                Error loading bookings: <%=e.getMessage()%>
                                                            </div>
                                                            <% } %>
                                            </div>
                        </div>
                        <script>
                            function showRatingForm(bookingId, itemId) {
                                document.getElementById('rate-form-' + bookingId).style.display = 'block';
                            }
                            function hideRatingForm(bookingId) {
                                document.getElementById('rate-form-' + bookingId).style.display = 'none';
                            }
                        </script>
                    </body>

                    </html>