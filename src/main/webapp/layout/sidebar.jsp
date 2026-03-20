<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><jsp:include page="global_scripts.jsp" /><%
    Integer sidebarUserId = (Integer) session.getAttribute("userId");
    String sidebarRole = (String) session.getAttribute("userRole");
    if (sidebarUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

    <!-- Sidebar specific styles -->
        <style>
        /* ===== SIDEBAR STYLES ===== */
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
            color: white;
            box-shadow: 4px 0 10px rgba(0, 0, 0, 0.15);
            z-index: 1000;
            font-family: 'Outfit', sans-serif;
            display: flex;
            flex-direction: column;
        }

        .sidebar-header {
            padding: 25px 20px 15px;
            flex-shrink: 0;
            text-align: center;
        }

        .sidebar-header h2 {
            margin: 0;
            font-size: 24px;
            font-weight: 700;
            color: var(--accent);
        }

        .sidebar-nav {
            flex: 1;
            overflow-y: auto;
            padding-bottom: 10px;
        }

        .sidebar-nav::-webkit-scrollbar {
            width: 4px;
        }

        .sidebar-nav::-webkit-scrollbar-thumb {
            background: #334155;
            border-radius: 4px;
        }

        .sidebar ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .sidebar ul li a {
            color: #94a3b8;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 13px 30px;
            font-weight: 500;
            font-size: 15px;
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

        .section-label {
            padding: 15px 30px 6px;
            font-size: 10px;
            color: #64748b;
            letter-spacing: 1.5px;
            font-weight: 700;
            text-transform: uppercase;
        }

        .sidebar-logout {
            flex-shrink: 0;
            padding: 15px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
        }

        .sidebar-logout a {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            background: #ef4444;
            color: white;
            text-decoration: none;
            padding: 13px 20px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 15px;
            transition: all 0.3s;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.25);
        }

        .sidebar-logout a:hover {
            background: #dc2626;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(239, 68, 68, 0.4);
        }
    </style>



        <div class="sidebar">
            <div class="sidebar-header">
                <h2>BorrowBuddy</h2>
            </div>

            <div class="sidebar-nav">
                <ul>
                    <li><a href="home.jsp">🏠 Home</a></li>
                    <li><a href="dashboard.jsp">📊 Dashboard</a></li>
                    <li><a href="profile.jsp">👤 My Profile</a></li>
                    <li><a href="notifications.jsp">🔔 Notifications</a></li>
                    <li><a href="<%= request.getContextPath() %>/mySettings.jsp">⚙️ Settings</a></li>

                    <% if ("Owner".equalsIgnoreCase(sidebarRole)) { %>
                        <div class="section-label">Owner Panel</div>
                        <li><a href="myItems.jsp">📦 My Items</a></li>
                        <li><a href="ownerRequests.jsp">📋 Requests</a></li>
                        <li><a href="OwnerBookings.jsp">💬 Bookings &amp; Chats</a></li>
                        <li><a href="addItem.jsp">➕ Add New Item</a></li>
                        <% } %>

                            <div class="section-label">Browse</div>
                            <li><a href="viewItems.jsp">🔍 Search Items</a></li>
                            <li><a href="myBookings.jsp">📅 My Bookings</a></li>
                </ul>
            </div>

            <div class="sidebar-logout">
                <a href="<%= request.getContextPath() %>/LogoutServlet">
                    🚪 Logout
                </a>
            </div>
        </div>