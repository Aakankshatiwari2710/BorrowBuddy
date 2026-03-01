<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*" %>
        <%@ page import="util.DBConnection" %>
            <%@ page session="true" %>
                <% Integer userId=(Integer) session.getAttribute("userId"); if(userId==null){
                    response.sendRedirect("login.jsp"); return; } %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>My Notifications | BorrowBuddy</title>
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

                            .notification-list {
                                background: white;
                                border-radius: 20px;
                                overflow: hidden;
                                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
                            }

                            .notification-item {
                                padding: 20px 25px;
                                border-bottom: 1px solid #f1f5f9;
                                display: flex;
                                align-items: center;
                                gap: 20px;
                                transition: 0.2s;
                            }

                            .notification-item:hover {
                                background: #f8fafc;
                            }

                            .notification-item:last-child {
                                border-bottom: none;
                            }

                            .icon {
                                width: 45px;
                                height: 45px;
                                background: #f0fdfa;
                                border-radius: 12px;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                color: var(--primary);
                                font-size: 20px;
                                flex-shrink: 0;
                            }

                            .content {
                                flex-grow: 1;
                            }

                            .message {
                                font-size: 15px;
                                margin: 0 0 5px;
                                font-weight: 500;
                            }

                            .timestamp {
                                font-size: 13px;
                                color: #64748b;
                            }

                            .empty-state {
                                text-align: center;
                                padding: 60px;
                                color: #94a3b8;
                            }
                        </style>
                    </head>

                    <body>
                        <jsp:include page="layout/sidebar.jsp" />
                        <div class="main-content">
                            <div class="header">
                                <h1>Notifications</h1>
                                <p style="color: #64748b;">Stay updated with your booking requests and community alerts.
                                </p>
                            </div>
                            <div class="notification-list">
                                <% String updateSql="UPDATE notifications SET is_read=1 WHERE user_id=? AND is_read=0" ;
                                    String
                                    selectSql="SELECT message, created_at FROM notifications WHERE user_id=? ORDER BY id DESC"
                                    ; try (Connection con=DBConnection.getConnection()) { try (PreparedStatement
                                    psUpdate=con.prepareStatement(updateSql)) { psUpdate.setInt(1, userId);
                                    psUpdate.executeUpdate(); } try (PreparedStatement
                                    psSelect=con.prepareStatement(selectSql)) { psSelect.setInt(1, userId); try
                                    (ResultSet rs=psSelect.executeQuery()) { boolean found=false; while(rs.next()){
                                    found=true; Timestamp ts=rs.getTimestamp("created_at"); java.text.SimpleDateFormat
                                    sdf=new java.text.SimpleDateFormat("MMM dd, yyyy • hh:mm a"); %>
                                    <div class="notification-item">
                                        <div class="icon">🔔</div>
                                        <div class="content">
                                            <p class="message">
                                                <%= rs.getString("message") %>
                                            </p>
                                            <p class="timestamp">
                                                <%= (ts !=null) ? sdf.format(ts) : "" %>
                                            </p>
                                        </div>
                                    </div>
                                    <% } if(!found){ %>
                                        <div class="empty-state">
                                            <p>No notifications yet. We'll alert you here when something happens!</p>
                                        </div>
                                        <% } } } } catch(Exception e) { %>
                                            <div style="padding: 20px; color: #ef4444;">Error loading notifications: <%=
                                                    e.getMessage() %>
                                            </div>
                                            <% } %>
                            </div>
                        </div>
                    </body>

                    </html>