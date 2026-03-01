<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*" %>
        <%@ page import="util.DBConnection" %>
            <%@ page session="true" %>
                <% Integer userId=(Integer) session.getAttribute("userId"); if(userId==null){
                    response.sendRedirect("login.jsp"); return; } String otherUserParam=request.getParameter("user");
                    String itemParam=request.getParameter("item"); if(otherUserParam==null || itemParam==null) {
                    response.sendRedirect("dashboard.jsp"); return; } int otherUser=Integer.parseInt(otherUserParam);
                    int itemId=Integer.parseInt(itemParam); %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Chat | BorrowBuddy</title>
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
                                height: 100vh;
                                display: flex;
                                flex-direction: column;
                                box-sizing: border-box;
                            }

                            .chat-container {
                                background: white;
                                border-radius: 25px;
                                flex-grow: 1;
                                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.05);
                                display: flex;
                                flex-direction: column;
                                overflow: hidden;
                                max-width: 900px;
                                margin: 0 auto;
                                width: 100%;
                            }

                            .chat-header {
                                padding: 20px 30px;
                                background: white;
                                border-bottom: 1px solid #f1f5f9;
                                display: flex;
                                align-items: center;
                                justify-content: space-between;
                            }

                            .chat-header h3 {
                                margin: 0;
                                font-size: 20px;
                            }

                            .messages-area {
                                flex-grow: 1;
                                padding: 30px;
                                overflow-y: auto;
                                background: #f8fafc;
                                display: flex;
                                flex-direction: column;
                                gap: 15px;
                            }

                            .msg {
                                max-width: 70%;
                                padding: 12px 18px;
                                border-radius: 18px;
                                font-size: 15px;
                                line-height: 1.5;
                                position: relative;
                            }

                            .me {
                                align-self: flex-end;
                                background: var(--primary);
                                color: white;
                                border-bottom-right-radius: 4px;
                            }

                            .other {
                                align-self: flex-start;
                                background: white;
                                color: var(--text);
                                border-bottom-left-radius: 4px;
                                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
                            }

                            .chat-input-area {
                                padding: 20px 30px;
                                background: white;
                                border-top: 1px solid #f1f5f9;
                            }

                            .input-form {
                                display: flex;
                                gap: 15px;
                            }

                            .input-form input {
                                flex-grow: 1;
                                padding: 14px 20px;
                                border-radius: 15px;
                                border: 1px solid #e2e8f0;
                                outline: none;
                                font-family: inherit;
                                transition: 0.3s;
                            }

                            .input-form input:focus {
                                border-color: var(--primary);
                                box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.1);
                            }

                            .btn-send {
                                padding: 0 25px;
                                background: var(--primary);
                                color: white;
                                border: none;
                                border-radius: 12px;
                                font-size: 15px;
                                font-weight: 600;
                                cursor: pointer;
                                transition: 0.3s;
                            }

                            .btn-send:hover {
                                background: var(--secondary);
                                transform: translateY(-2px);
                            }
                        </style>
                    </head>

                    <body>
                        <jsp:include page="layout/sidebar.jsp" />

                        <div class="main-content">
                            <div class="chat-container">
                                <% String otherUserName="User" ; String otherUserRole="" ; String otherUserLocation="" ;
                                    try (Connection con=DBConnection.getConnection()) { String
                                    uq="SELECT name, role, location FROM users WHERE id=?" ; try (PreparedStatement
                                    ups=con.prepareStatement(uq)) { ups.setInt(1, otherUser); try (ResultSet
                                    urs=ups.executeQuery()) { if (urs.next()) { otherUserName=urs.getString("name");
                                    otherUserRole=urs.getString("role"); otherUserLocation=urs.getString("location"); }
                                    } } } catch(Exception e) { e.printStackTrace(); } %>
                                    <div class="chat-header">
                                        <div style="display: flex; align-items: center; gap: 15px;">
                                            <div
                                                style="width: 45px; height: 45px; background: var(--primary); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: bold;">
                                                <%= otherUserName !=null && !otherUserName.trim().isEmpty() ?
                                                    otherUserName.trim().substring(0, 1).toUpperCase() : "U" %>
                                            </div>
                                            <div>
                                                <h3>
                                                    <%= otherUserName !=null && !otherUserName.trim().isEmpty() ?
                                                        otherUserName : "Unknown User" %> <span
                                                            style="font-size: 13px; font-weight: 500; color: #fff; background: var(--secondary); padding: 2px 8px; border-radius: 12px; margin-left: 8px; vertical-align: middle;">
                                                            <%= otherUserRole %>
                                                        </span>
                                                </h3>
                                                <p style="margin: 5px 0 0; font-size: 13px; color: #64748b;">📍 <%=
                                                        otherUserLocation !=null && !otherUserLocation.isEmpty() ?
                                                        otherUserLocation : "Location unknown" %>
                                                </p>
                                            </div>
                                        </div>
                                        <a href="dashboard.jsp"
                                            style="text-decoration: none; font-size: 14px; color: var(--primary); font-weight: 600;">←
                                            Back</a>
                                    </div>

                                    <div class="messages-area" id="msgArea">
                                        <% try (Connection con=DBConnection.getConnection()) { String
                                            q="SELECT * FROM messages WHERE item_id=? AND "
                                            + "((sender_id=? AND receiver_id=?) OR (sender_id=? AND receiver_id=?)) "
                                            + "ORDER BY sent_at ASC" ; try (PreparedStatement
                                            ps=con.prepareStatement(q)) { ps.setInt(1, itemId); ps.setInt(2, userId);
                                            ps.setInt(3, otherUser); ps.setInt(4, otherUser); ps.setInt(5, userId); try
                                            (ResultSet rs=ps.executeQuery()) { while(rs.next()){ String
                                            cssClass=(rs.getInt("sender_id")==userId) ? "me" : "other" ; %>
                                            <div class="msg <%= cssClass %>">
                                                <%= rs.getString("message") %>
                                            </div>
                                            <% } } } } catch(Exception e) { %>
                                                <div style="text-align: center; color: #ef4444;">Error: <%=
                                                        e.getMessage() %>
                                                </div>
                                                <% } %>
                                    </div>

                                    <div class="chat-input-area">
                                        <form action="ChatServlet" method="post" class="input-form">
                                            <input type="hidden" name="receiverId" value="<%= otherUser %>">
                                            <input type="hidden" name="itemId" value="<%= itemId %>">
                                            <input type="text" name="message" placeholder="Type your message here..."
                                                required autocomplete="off">
                                            <button type="submit" class="btn-send">Send ✈</button>
                                        </form>
                                    </div>
                            </div>
                        </div>

                        <script>
                            // Scroll to bottom of chat
                            const msgArea = document.getElementById('msgArea');
                            msgArea.scrollTop = msgArea.scrollHeight;
                        </script>
                    </body>

                    </html>