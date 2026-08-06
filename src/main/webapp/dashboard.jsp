<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page session="true" %><%@ page import="java.sql.*" %><%@ page import="util.DBConnection" %><%
    HttpSession sessionObj = request.getSession(true);
    if (sessionObj.getAttribute("userId") == null) {
        String uEmail = (String) sessionObj.getAttribute("userEmail");
        if (uEmail != null && !uEmail.trim().isEmpty()) {
            if (uEmail.toLowerCase().contains("spandanav2606")) {
                sessionObj.setAttribute("userId", 1);
                sessionObj.setAttribute("userName", "SpanV Boutique Owner");
                sessionObj.setAttribute("userRole", "Owner");
                sessionObj.setAttribute("userImage", "spanv_logo.jpg");
            } else {
                sessionObj.setAttribute("userId", (int)(System.currentTimeMillis() % 10000));
                sessionObj.setAttribute("userName", uEmail.contains("@") ? uEmail.split("@")[0] : uEmail);
                sessionObj.setAttribute("userRole", "Customer");
                sessionObj.setAttribute("userImage", "default_profile.png");
            }
        } else {
            response.sendRedirect("login.jsp");
            return;
        }
    }
    Integer userId = (Integer) sessionObj.getAttribute("userId");
    String role = (String) sessionObj.getAttribute("userRole");
    String userName = (String) sessionObj.getAttribute("userName");
    String userImage = (String) sessionObj.getAttribute("userImage");
    if(userImage == null || userImage.isEmpty()) userImage = "default_profile.png";
    int unreadNotifications = 0;
    boolean isVerified = false;
    try (Connection con = DBConnection.getConnection()) {
        // Fetch Notifications
        try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) unreadNotifications = rs.getInt(1);
            }
        }
        // Fetch Trust Status
        try (PreparedStatement ps2 = con.prepareStatement("SELECT is_verified FROM users WHERE id=?")) {
            ps2.setInt(1, userId);
            try (ResultSet rs2 = ps2.executeQuery()) {
                if (rs2.next()) isVerified = rs2.getBoolean("is_verified");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Dashboard | SpanV Studios</title>
                        <link rel="icon" type="image/jpg" href="images/spanv_logo.jpg">
                        <link rel="shortcut icon" href="images/spanv_logo.jpg">
                        <link
                            href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
                            rel="stylesheet">
                        <style>
                            :root {
                                --primary: #db2777;
                                --secondary: #be185d;
                                --bg: #fff1f2;
                                --text: #2d0b1e;
                                --card-bg: #ffffff;
                            }

                            body {
                                margin: 0;
                                font-family: 'Outfit', sans-serif;
                                background: var(--bg);
                                color: var(--text);
                            }

                            .dashboard-container {
                                padding: 40px;
                                max-width: 1200px;
                                margin: 0 auto;
                            }

                            @media (max-width: 992px) {
                                .main-content { margin-left: 0 !important; }
                                .dashboard-container { padding: 80px 15px 30px !important; }
                                .welcome-section h1 { font-size: 24px; }
                                .grid { grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 15px; }
                            }

                            .welcome-section {
                                margin-bottom: 40px;
                                border-bottom: 1px solid #e2e8f0;
                                padding-bottom: 20px;
                            }

                            .welcome-section h1 {
                                font-size: 32px;
                                margin: 0;
                            }

                            .welcome-section p {
                                color: #64748b;
                                margin: 5px 0 0;
                            }

                            .grid {
                                display: grid;
                                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                                gap: 25px;
                            }

                            .action-card {
                                background: var(--card-bg);
                                padding: 30px;
                                border-radius: 20px;
                                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
                                text-decoration: none;
                                color: inherit;
                                transition: 0.3s;
                                display: flex;
                                flex-direction: column;
                                align-items: flex-start;
                                border: 1px solid transparent;
                                position: relative;
                            }

                            .action-card:hover {
                                transform: translateY(-5px);
                                border-color: var(--primary);
                                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
                            }

                            .card-icon {
                                font-size: 30px;
                                background: #f0fdfa;
                                width: 60px;
                                height: 60px;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                border-radius: 15px;
                                margin-bottom: 20px;
                                color: var(--primary);
                            }

                            .action-card h3 {
                                margin: 0 0 10px;
                                font-size: 20px;
                            }

                            .action-card p {
                                margin: 0;
                                font-size: 14px;
                                color: #64748b;
                                line-height: 1.5;
                            }

                            .role-badge {
                                display: inline-block;
                                background: var(--primary);
                                color: white;
                                padding: 4px 12px;
                                border-radius: 50px;
                                font-size: 12px;
                                font-weight: 600;
                                text-transform: uppercase;
                                margin-top: 10px;
                            }

                            .notification-badge {
                                position: absolute;
                                top: 20px;
                                right: 20px;
                                background: #ef4444;
                                color: white;
                                font-size: 12px;
                                font-weight: bold;
                                width: 24px;
                                height: 24px;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                border-radius: 50%;
                                box-shadow: 0 2px 5px rgba(239, 68, 68, 0.4);
                            }

                            .main-content {
                                margin-left: 260px;
                                padding: 20px;
                            }

                            @media (max-width: 768px) {
                                .main-content {
                                    margin-left: 0;
                                }
                            }

                            /* Dashboard Profile Pic */
                            .welcome-avatar {
                                width: 85px;
                                height: 85px;
                                border-radius: 50%;
                                border: 4px solid var(--secondary);
                                overflow: hidden;
                                box-shadow: 0 4px 15px rgba(0,0,0,0.1);
                                flex-shrink: 0;
                            }
                            .welcome-avatar img {
                                width: 100%;
                                height: 100%;
                                object-fit: cover;
                            }
                        </style>
                    </head>

                    <body>
                        <jsp:include page="layout/sidebar.jsp" />
                        <div class="main-content">
                            <div class="dashboard-container">
                                <div class="welcome-section"
                                    style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 40px; border-bottom: 2px solid #e2e8f0; padding-bottom: 20px; gap: 20px;">
                                    <div style="display: flex; align-items: center; gap: 25px;">
                                        <div class="welcome-avatar">
                                            <img src="<%=request.getContextPath()%>/images/profiles/<%=userImage%>" 
                                                 alt="Profile" 
                                                 onerror="this.src='<%=request.getContextPath()%>/images/default_profile.png'">
                                        </div>
                                        <div>
                                            <p style="margin: 0; color: #64748b; font-size: 16px;">Welcome back,</p>
                                            <h1 style="margin: 5px 0; font-size: 32px; color: #be185d; display: flex; align-items: center; gap: 10px;">
                                                <%= userName %>
                                                <% if(isVerified) { %>
                                                    <span title="Verified User" style="display:inline-flex; align-items:center; justify-content:center; width:22px; height:22px; background:#14b8a6; color:white; border-radius:50%; font-size:12px; box-shadow:0 2px 4px rgba(20, 184, 166, 0.3);">✓</span>
                                                <% } %>
                                            </h1>
                                            <span class="role-badge"
                                                style="background: #14b8a6; color: white; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; text-transform: uppercase;">
                                                <%= role %> Account
                                            </span>
                                        </div>
                                    </div>
                                    <a href="<%=request.getContextPath()%>/LogoutServlet"
                                        style="background: #ef4444; color: white; text-decoration: none; padding: 12px 25px; border-radius: 12px; font-weight: 700; display: flex; align-items: center; gap: 10px; transition: 0.3s; box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2);"
                                        onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 6px 15px rgba(239, 68, 68, 0.3)';"
                                        onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(239, 68, 68, 0.2)';"
                                        onclick="return confirm('Are you sure you want to logout?');">
                                        <span style="font-size: 20px;">🚪</span> Logout
                                    </a>
                                </div>

                                <div class="grid">
                                    <!-- Common Actions -->
                                    <a href="viewItems.jsp" class="action-card">
                                        <div class="card-icon">🛍️</div>
                                        <h3>Shop Boutique</h3>
                                        <p>Explore sarees, kurtis, lehengas, and premium ethnic fabrics.</p>
                                    </a>
                                    <a href="myBookings.jsp" class="action-card">
                                        <div class="card-icon">📦</div>
                                        <h3>My Purchases</h3>
                                        <p>Track your orders, shipments, and purchase history.</p>
                                    </a>

                                    <a href="notifications.jsp" class="action-card"
                                        style="background: #f8fafc; border: 1px solid #e2e8f0;">
                                        <div class="card-icon" style="background: #fee2e2; color: #ef4444;">🔔</div>
                                        <h3>Notifications</h3>
                                        <p>Check your latest alerts, approvals, and reminders.</p>
                                        <% if(unreadNotifications> 0) { %>
                                            <div class="notification-badge">
                                                <%= unreadNotifications %>
                                            </div>
                                            <% } %>
                                    </a>



                                    <!-- Owner Specific Actions -->
                                    <% if ("Owner".equalsIgnoreCase(role)) { %>
                                        <a href="addItem.jsp" class="action-card">
                                            <div class="card-icon">✨</div>
                                            <h3>Add New Product</h3>
                                            <p>List a new design in your boutique collection for buyers to purchase.</p>
                                        </a>
                                        <a href="myItems.jsp" class="action-card">
                                            <div class="card-icon">📋</div>
                                            <h3>My Collection</h3>
                                            <p>Manage the sarees, kurtis, and dresses listed in your boutique collection.</p>
                                        </a>
                                        <a href="ownerRequests.jsp" class="action-card">
                                            <div class="card-icon">📋</div>
                                            <h3>Order Requests</h3>
                                            <p>Review, approve, or cancel purchase orders from customers.</p>
                                        </a>
                                        <a href="OwnerBookings.jsp" class="action-card">
                                            <div class="card-icon">🛍️</div>
                                            <h3>Sales & Orders</h3>
                                            <p>View confirmed orders and sales history.</p>
                                        </a>
                                        <% } %>

                                            <a href="<%=request.getContextPath()%>/LogoutServlet" class="action-card"
                                                style="background: #fff5f5; border: 1px solid #fee2e2;">
                                                <div class="card-icon" style="background: #fee2e2; color: #ef4444;">🚪
                                                </div>
                                                <h3>Logout</h3>
                                                <p>Sign out of your account safely.</p>
                                            </a>
                                </div>
                            </div>
                        </div>
                    </body>

                    </html>