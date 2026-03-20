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

                            .btn-send:hover {
                                background: var(--secondary);
                                transform: translateY(-2px);
                            }

                            /* Message Avatar Styles */
                            .msg-row {
                                display: flex;
                                gap: 12px;
                                margin-bottom: 15px;
                                width: 100%;
                            }

                            .msg-row.me {
                                flex-direction: row-reverse;
                                align-self: flex-end;
                            }

                            .msg-row.other {
                                align-self: flex-start;
                            }

                            .msg-avatar {
                                width: 35px;
                                height: 35px;
                                border-radius: 50%;
                                overflow: hidden;
                                flex-shrink: 0;
                                border: 2px solid #fff;
                                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
                            }

                            .msg-avatar img {
                                width: 100%;
                                height: 100%;
                                object-fit: cover;
                            }

                            .msg {
                                max-width: 70%;
                                padding: 12px 18px;
                                border-radius: 18px;
                                font-size: 15px;
                                line-height: 1.5;
                                position: relative;
                            }

                            .me .msg {
                                background: var(--primary);
                                color: white;
                                border-bottom-right-radius: 4px;
                            }

                            .other .msg {
                                background: white;
                                color: var(--text);
                                border-bottom-left-radius: 4px;
                                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
                            }

                            .chat-input-area {
                                padding: 15px 25px 25px;
                                border-top: 1px solid var(--border);
                                background: white;
                            }

                            .quick-replies {
                                display: flex;
                                gap: 10px;
                                margin-bottom: 12px;
                                overflow-x: auto;
                                padding-bottom: 5px;
                                scrollbar-width: none;
                            }
                            .quick-replies::-webkit-scrollbar { display: none; }
                            .quick-chip {
                                padding: 6px 15px;
                                background: #f1f5f9;
                                border: 1px solid #e2e8f0;
                                border-radius: 50px;
                                font-size: 12px;
                                font-weight: 600;
                                color: #475569;
                                cursor: pointer;
                                white-space: nowrap;
                                transition: 0.2s;
                            }
                            .quick-chip:hover {
                                background: var(--primary);
                                color: white;
                                border-color: var(--primary);
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
                        </style>
                    </head>

                    <body>
                        <jsp:include page="layout/sidebar.jsp" />

                        <div class="main-content">
                            <div class="chat-container">
                                <% 
                                    String currentUserImage = (String) session.getAttribute("userImage");
                                    if(currentUserImage == null || currentUserImage.isEmpty()) currentUserImage = "default_profile.png";
                                    
                                    String otherUserName="User" ; String otherUserRole="" ; String otherUserLocation="" ; String otherUserImage="default_profile.png";
                                    try (Connection con=DBConnection.getConnection()) { String
                                    uq="SELECT name, role, location, image FROM users WHERE id=?" ; try (PreparedStatement
                                    ups=con.prepareStatement(uq)) { ups.setInt(1, otherUser); try (ResultSet
                                    urs=ups.executeQuery()) { if (urs.next()) { otherUserName=urs.getString("name");
                                    otherUserRole=urs.getString("role"); otherUserLocation=urs.getString("location"); 
                                    String img = urs.getString("image");
                                    if(img != null && !img.isEmpty()) otherUserImage = img;
                                    }
                                    } } } catch(Exception e) { e.printStackTrace(); } %>
                                    <div class="chat-header">
                                        <div style="display: flex; align-items: center; gap: 15px;">
                                            <div
                                                style="width: 45px; height: 45px; background: var(--primary); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; overflow: hidden;">
                                                <img src="<%=request.getContextPath()%>/images/profiles/<%=otherUserImage%>" 
                                                     alt="Profile" 
                                                     style="width: 100%; height: 100%; object-fit: cover;"
                                                     onerror="this.src='<%=request.getContextPath()%>/images/default_profile.png'">
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
                                            (ResultSet rs=ps.executeQuery()) { while(rs.next()){ 
                                                int senderId = rs.getInt("sender_id");
                                                String cssClass = (senderId == userId) ? "me" : "other" ; 
                                                String displayImg = (senderId == userId) ? currentUserImage : otherUserImage;
                                            %>
                                            <div class="msg-row <%= cssClass %>">
                                                <div class="msg-avatar">
                                                    <img src="<%=request.getContextPath()%>/images/profiles/<%= displayImg %>" 
                                                         onerror="this.src='<%=request.getContextPath()%>/images/default_profile.png'">
                                                </div>
                                                <div class="msg">
                                                    <%= rs.getString("message") %>
                                                </div>
                                            </div>
                                            <% } } } } catch(Exception e) { %>
                                                <div style="text-align: center; color: #ef4444;">Error: <%=
                                                        e.getMessage() %>
                                                </div>
                                                <% } %>
                                    </div>

                                    <div class="chat-input-area">
                                        <div class="quick-replies">
                                            <div class="quick-chip" onclick="setQuickMsg('Is this still available?')">Is it available?</div>
                                            <div class="quick-chip" onclick="setQuickMsg('Where can I pick this up?')">Where to pick up?</div>
                                            <div class="quick-chip" onclick="setQuickMsg('When is the best time to meet?')">When to meet?</div>
                                            <div class="quick-chip" onclick="setQuickMsg('Thank you!')">Thank you!</div>
                                        </div>
                                        <form action="ChatServlet" method="post" class="input-form" id="chatForm">
                                            <input type="hidden" name="receiverId" value="<%= otherUser %>">
                                            <input type="hidden" name="itemId" value="<%= itemId %>">
                                            <input type="text" name="message" id="messageInput" placeholder="Type your message here..."
                                                required autocomplete="off">
                                            <button type="submit" class="btn-send">Send ✈</button>
                                        </form>
                                    </div>
                            </div>
                        </div>

                        <script>
                            // Scroll to bottom of chat
                            const msgArea = document.getElementById('msgArea');
                            if(msgArea) msgArea.scrollTop = msgArea.scrollHeight;

                            function setQuickMsg(msg) {
                                const input = document.getElementById('messageInput');
                                if(input) {
                                    input.value = msg;
                                    input.focus();
                                }
                            }
                        </script>
                    </body>

                    </html>