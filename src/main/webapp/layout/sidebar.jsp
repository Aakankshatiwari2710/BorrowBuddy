<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <style>
        :root {
            --sidebar-bg: #1e293b;
            --sidebar-hover: #334155;
            --accent: #14b8a6;
        }

        .sidebar {
            width: 260px;
            height: 100vh;
            background: var(--sidebar-bg);
            position: fixed;
            left: 0;
            top: 0;
            padding-top: 30px;
            color: white;
            box-shadow: 4px 0 10px rgba(0, 0, 0, 0.1);
            z-index: 1000;
            font-family: 'Outfit', sans-serif;
        }

        .sidebar h2 {
            text-align: center;
            font-size: 26px;
            font-weight: 700;
            color: var(--accent);
            margin-bottom: 40px;
        }

        .sidebar ul {
            list-style: none;
            padding: 0;
        }

        .sidebar ul li {
            margin-bottom: 5px;
        }

        .sidebar ul li a {
            color: #94a3b8;
            text-decoration: none;
            display: flex;
            align-items: center;
            padding: 15px 30px;
            font-weight: 500;
            transition: 0.3s;
        }

        .sidebar ul li a:hover {
            background: var(--sidebar-hover);
            color: white;
            padding-left: 35px;
        }

        .sidebar ul li a.active {
            background: var(--sidebar-hover);
            color: var(--accent);
            border-right: 4px solid var(--accent);
        }

        .logout-btn {
            margin-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            padding-top: 20px;
        }
    </style>

    <% Integer sidebarUserId=(Integer) session.getAttribute("userId"); String sidebarRole=(String)
        session.getAttribute("userRole"); if(sidebarUserId==null){ response.sendRedirect("login.jsp"); return; } %>

        <div class="sidebar">
            <h2>BorrowBuddy</h2>
            <ul>
                <li><a href="home.jsp">🏠 Home</a></li>
                <li><a href="dashboard.jsp">📊 Dashboard</a></li>
                <li><a href="profile.jsp">👤 My Profile</a></li>
                <li><a href="notifications.jsp">🔔 Notifications</a></li>

                <% if("Owner".equalsIgnoreCase(sidebarRole)){ %>
                    <div style="padding: 20px 30px 10px; font-size: 11px; color: #64748b; letter-spacing: 1px;">OWNER
                        PANEL</div>
                    <li><a href="myItems.jsp">📦 My Items</a></li>
                    <li><a href="ownerRequests.jsp">🔔 Requests</a></li>
                    <li><a href="OwnerBookings.jsp">💬 Bookings & Chats</a></li>
                    <li><a href="addItem.jsp">➕ Add New Item</a></li>
                    <% } %>

                        <div style="padding: 20px 30px 10px; font-size: 11px; color: #64748b; letter-spacing: 1px;">
                            BROWSER PANEL</div>
                        <li><a href="viewItems.jsp">🔍 Browse Items</a></li>
                        <li><a href="myBookings.jsp">📅 My Bookings</a></li>

                        <div class="logout-btn">
                            <li><a href="LogoutServlet" style="color: #ef4444;">🚪 Logout</a></li>
                        </div>
            </ul>
        </div>