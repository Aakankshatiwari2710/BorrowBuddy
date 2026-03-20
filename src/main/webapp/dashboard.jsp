<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page session="true" %><%@ page import="java.sql.*" %><%@ page import="util.DBConnection" %><%
    Connection conMig = null; Statement stmtMig = null;
    try {
        conMig = DBConnection.getConnection(); stmtMig = conMig.createStatement();
        // 1. Reviews table
        stmtMig.executeUpdate("CREATE TABLE IF NOT EXISTS reviews (id INT AUTO_INCREMENT PRIMARY KEY, item_id INT, reviewer_id INT, rating INT, comment TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
        // 2. Bookings updates
        try { stmtMig.executeUpdate("ALTER TABLE bookings ADD COLUMN rating_id INT NULL"); } catch(Exception e){}
        try { stmtMig.executeUpdate("ALTER TABLE bookings ADD COLUMN condition_note TEXT NULL"); } catch(Exception e){}
        try { stmtMig.executeUpdate("ALTER TABLE bookings ADD COLUMN late_fee DOUBLE DEFAULT 0.0"); } catch(Exception e){}
        // 3. User updates
        try { stmtMig.executeUpdate("ALTER TABLE users ADD COLUMN trust_score INT DEFAULT 0"); } catch(Exception e){}
        try { stmtMig.executeUpdate("ALTER TABLE users ADD COLUMN is_verified BOOLEAN DEFAULT FALSE"); } catch(Exception e){}
    } catch (Exception e) { e.printStackTrace(); } finally { if(stmtMig!=null)stmtMig.close(); if(conMig!=null)conMig.close(); }
    
    HttpSession sessionObj = request.getSession(false);
    if (sessionObj == null || sessionObj.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
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
                        <title>Dashboard | BorrowBuddy</title>
                        <link
                            href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
                            rel="stylesheet">
                        <style>
                            :root {
                                --primary: #0f766e;
                                --secondary: #14b8a6;
                                --bg: #f1f5f9;
                                --text: #1e293b;
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
                                            <h1 style="margin: 5px 0; font-size: 32px; color: #0f766e; display: flex; align-items: center; gap: 10px;">
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
                                        <div class="card-icon">🔍</div>
                                        <h3>Browse Items</h3>
                                        <p>Explore tools, gadgets, and more available for rent in your community.</p>
                                    </a>
                                    <a href="myBookings.jsp" class="action-card">
                                        <div class="card-icon">📦</div>
                                        <h3>My Bookings</h3>
                                        <p>Track your rental requests and active items you are borrowing.</p>
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

                                    <!-- Community Leaderboard -->
                                    <div class="action-card" style="grid-column: span 1; background: linear-gradient(135deg, #0f766e, #14b8a6); color: white;">
                                        <div class="card-icon" style="background: rgba(255,255,255,0.2); color: white;">🏆</div>
                                        <h3>Top Neighbors</h3>
                                        <div style="width: 100%; margin-top: 10px;">
                                            <% 
                                                try (Connection conLeader = DBConnection.getConnection();
                                                     Statement stmtLeader = conLeader.createStatement();
                                                     ResultSet rsLeader = stmtLeader.executeQuery("SELECT name, trust_score FROM users ORDER BY trust_score DESC LIMIT 3")) {
                                                    while(rsLeader.next()) { %>
                                                        <div style="display: flex; justify-content: space-between; padding: 5px 0; border-bottom: 1px solid rgba(255,255,255,0.1); font-size: 13px;">
                                                            <span>👤 <%= rsLeader.getString("name") %></span>
                                                            <span style="font-weight: 700;"><%= rsLeader.getInt("trust_score") %> pts</span>
                                                        </div>
                                                <% } } catch(Exception e) {} %>
                                        </div>
                                    </div>

                                    <!-- Owner Specific Actions -->
                                    <% if ("Owner".equalsIgnoreCase(role)) { %>
                                        <a href="addItem.jsp" class="action-card">
                                            <div class="card-icon">➕</div>
                                            <h3>Add New Item</h3>
                                            <p>List a new item from your storage to start earning through sharing.</p>
                                        </a>
                                        <a href="myItems.jsp" class="action-card">
                                            <div class="card-icon">📋</div>
                                            <h3>My Listed Items</h3>
                                            <p>Manage the items you've shared with others in the neighborhood.</p>
                                        </a>
                                        <a href="ownerRequests.jsp" class="action-card">
                                            <div class="card-icon">📋</div>
                                            <h3>Manage Requests</h3>
                                            <p>Review, approve, or decline borrowing requests from neighbors.</p>
                                        </a>
                                        <a href="OwnerBookings.jsp" class="action-card">
                                            <div class="card-icon">💬</div>
                                            <h3>Bookings & Chats</h3>
                                            <p>View confirmed bookings and chat with your borrowers.</p>
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