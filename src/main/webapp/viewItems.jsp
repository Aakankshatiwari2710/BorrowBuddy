<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*" %>
        <%@ page import="util.DBConnection" %>
            <%@ page session="true" %>
                <% Integer userId=(Integer) session.getAttribute("userId"); if(userId==null){
                    response.sendRedirect("login.jsp"); return; } String success=request.getParameter("success"); %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Browse Items | BorrowBuddy</title>
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
                                margin-bottom: 35px;
                            }

                            .header h1 {
                                font-size: 32px;
                                margin: 0;
                                color: var(--primary);
                            }

                            .grid {
                                display: grid;
                                grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
                                gap: 30px;
                            }

                            .card {
                                background: #fff;
                                border-radius: 20px;
                                overflow: hidden;
                                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
                                transition: 0.3s;
                                position: relative;
                                display: flex;
                                flex-direction: column;
                            }

                            .card:hover {
                                transform: translateY(-5px);
                                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
                            }

                            .card img {
                                width: 100%;
                                height: 200px;
                                object-fit: cover;
                            }

                            .card-body {
                                padding: 20px;
                                flex-grow: 1;
                                display: flex;
                                flex-direction: column;
                            }

                            .card-body h3 {
                                margin: 0 0 10px;
                                font-size: 20px;
                            }

                            .price {
                                font-size: 20px;
                                font-weight: 700;
                                color: var(--primary);
                                margin-bottom: 15px;
                            }

                            .description {
                                font-size: 14px;
                                color: #64748b;
                                margin-bottom: 20px;
                                line-height: 1.5;
                                flex-grow: 1;
                            }

                            .time-slots {
                                margin-bottom: 15px;
                                background: #f8fafc;
                                padding: 12px;
                                border-radius: 12px;
                                border: 1px solid #f1f5f9;
                            }

                            .time-group {
                                margin-bottom: 10px;
                            }

                            .time-group:last-child {
                                margin-bottom: 0;
                            }

                            .time-group label {
                                display: block;
                                font-size: 11px;
                                font-weight: 700;
                                color: #64748b;
                                text-transform: uppercase;
                                margin-bottom: 4px;
                            }

                            .time-group input {
                                width: 100%;
                                border: 1px solid #e2e8f0;
                                border-radius: 8px;
                                padding: 8px;
                                font-family: inherit;
                                font-size: 13px;
                                box-sizing: border-box;
                            }

                            .btn-book {
                                width: 100%;
                                padding: 12px;
                                background: var(--primary);
                                color: #fff;
                                border: none;
                                border-radius: 12px;
                                cursor: pointer;
                                font-weight: 600;
                                transition: 0.3s;
                            }

                            .btn-book:hover {
                                background: var(--secondary);
                            }

                            .btn-disabled {
                                background: #e2e8f0;
                                color: #94a3b8;
                                cursor: not-allowed;
                            }

                            .badge {
                                position: absolute;
                                top: 15px;
                                right: 15px;
                                padding: 6px 12px;
                                border-radius: 50px;
                                font-size: 12px;
                                background: rgba(255, 255, 255, 0.9);
                                backdrop-filter: blur(5px);
                                font-weight: 700;
                                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
                                color: var(--primary);
                            }

                            .alert-success {
                                background: #dcfce7;
                                color: #166534;
                                padding: 15px;
                                border-radius: 12px;
                                margin-bottom: 25px;
                            }
                        </style>
                    </head>

                    <body>
                        <jsp:include page="layout/sidebar.jsp" />
                        <div class="main-content">
                            <div class="header">
                                <h1>Available Items</h1>
                                <p style="color: #64748b;">Select your time slots and rent items from your neighborhood.
                                </p>
                            </div>
                            <% if("booked".equals(success)){ %>
                                <div class="alert-success">✅ Booking request sent successfully! Check "My Bookings" for
                                    status.</div>
                                <% } %>
                                    <div class="grid">
                                        <% String userEmail=(String) session.getAttribute("userEmail"); try (Connection
                                            con=DBConnection.getConnection()) { String
                                            q="SELECT i.*, b.status as b_status, b.payment_status FROM items i "
                                            + "LEFT JOIN bookings b ON i.id=b.item_id AND b.borrower_id=? AND (b.status='Pending' OR b.status='Approved') "
                                            + "WHERE i.owner_email != ? " + "ORDER BY i.id DESC" ; try
                                            (PreparedStatement ps=con.prepareStatement(q)) { ps.setInt(1, userId);
                                            ps.setString(2, userEmail); try (ResultSet rs=ps.executeQuery()) { boolean
                                            found=false; while(rs.next()){ found=true; String
                                            status=rs.getString("b_status"); String
                                            payStatus=rs.getString("payment_status"); String img=rs.getString("image");
                                            if(img==null || img.isEmpty()) img="default.png" ; int
                                            itemId=rs.getInt("id"); %>
                                            <div class="card">
                                                <% if(status !=null) { %>
                                                    <div class="badge">
                                                        <%= status %>
                                                    </div>
                                                    <% } %>
                                                        <img src="<%=request.getContextPath()%>/images/<%=img%>"
                                                            onerror="this.src='<%=request.getContextPath()%>/images/default.png'">
                                                        <div class="card-body">
                                                            <h3>
                                                                <%= rs.getString("name") %>
                                                            </h3>
                                                            <p class="price">₹ <%= (int)rs.getDouble("price") %>/hour
                                                            </p>
                                                            <p class="description">
                                                                <%= rs.getString("description") %>
                                                            </p>

                                                            <% if(status==null) { %>
                                                                <form action="BookItemServlet" method="post">
                                                                    <input type="hidden" name="itemId"
                                                                        value="<%=itemId%>">
                                                                    <div class="time-slots">
                                                                        <div class="time-group">
                                                                            <label>Start Date & Time</label>
                                                                            <input type="datetime-local"
                                                                                name="startDate" required>
                                                                        </div>
                                                                        <div class="time-group">
                                                                            <label>End Date & Time</label>
                                                                            <input type="datetime-local" name="endDate"
                                                                                required>
                                                                        </div>
                                                                    </div>
                                                                    <button class="btn-book">Rent Now</button>
                                                                </form>
                                                                <% } else if("Pending".equalsIgnoreCase(status)) { %>
                                                                    <button class="btn-book btn-disabled" disabled>Req.
                                                                        Pending</button>
                                                                    <% } else if("Approved".equalsIgnoreCase(status)
                                                                        && "Paid" .equalsIgnoreCase(payStatus)) { %>
                                                                        <button class="btn-book btn-disabled"
                                                                            style="background:#10b981; color:#fff;"
                                                                            disabled>Paid & Confirmed</button>
                                                                        <% } else
                                                                            if("Approved".equalsIgnoreCase(status)) { %>
                                                                            <a href="myBookings.jsp" class="btn-book"
                                                                                style="display:block; text-align:center; text-decoration:none; background:#0ea5e9; box-sizing:border-box;">Pay
                                                                                in Bookings</a>
                                                                            <% } %>
                                                        </div>
                                            </div>
                                            <% } if(!found){ %>
                                                <div
                                                    style="grid-column: 1/-1; text-align: center; padding: 60px; background: white; border-radius: 20px;">
                                                    <p style="color: #94a3b8;">No items available right now. Check back
                                                        later!</p>
                                                </div>
                                                <% } } } } catch(Exception e) { %>
                                                    <div
                                                        style="grid-column: 1/-1; color: #ef4444; background: #fee2e2; padding: 20px; border-radius: 12px;">
                                                        Error loading items: <%= e.getMessage() %>
                                                    </div>
                                                    <% } %>
                                    </div>
                        </div>
                    </body>

                    </html>