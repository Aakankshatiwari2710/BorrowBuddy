<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*" %>
        <%@ page import="util.DBConnection" %>
            <%@ page session="true" %>
                <% Integer userId=(Integer) session.getAttribute("userId"); String userEmail=(String)
                    session.getAttribute("userEmail"); String userRole=(String) session.getAttribute("userRole"); if
                    (userId==null || userEmail==null || userRole==null || !userRole.equalsIgnoreCase("Owner")) {
                    response.sendRedirect("login.jsp"); return; } String message=request.getParameter("msg"); %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>My Listed Items | BorrowBuddy</title>
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
                                display: flex;
                                justify-content: space-between;
                                align-items: center;
                            }

                            .header h1 {
                                font-size: 28px;
                                margin: 0;
                            }

                            .btn-add {
                                background: var(--primary);
                                color: white;
                                text-decoration: none;
                                padding: 10px 20px;
                                border-radius: 10px;
                                font-weight: 600;
                                transition: 0.3s;
                            }

                            .btn-add:hover {
                                background: var(--secondary);
                                transform: translateY(-2px);
                            }

                            .table-container {
                                background: white;
                                border-radius: 20px;
                                overflow: hidden;
                                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
                            }

                            table {
                                width: 100%;
                                border-collapse: collapse;
                            }

                            th {
                                background: #f8fafc;
                                padding: 15px 20px;
                                text-align: left;
                                font-size: 14px;
                                color: #64748b;
                                font-weight: 600;
                                border-bottom: 1px solid #f1f5f9;
                            }

                            td {
                                padding: 15px 20px;
                                border-bottom: 1px solid #f1f5f9;
                                font-size: 15px;
                            }

                            .item-img {
                                width: 80px;
                                height: 60px;
                                border-radius: 8px;
                                object-fit: cover;
                            }

                            .btn {
                                display: inline-block;
                                padding: 6px 12px;
                                border-radius: 6px;
                                text-decoration: none;
                                font-size: 13px;
                                font-weight: 600;
                                transition: 0.2s;
                                margin-right: 5px;
                            }

                            .edit {
                                background: #f1f5f9;
                                color: #475569;
                            }

                            .edit:hover {
                                background: #e2e8f0;
                            }

                            .delete {
                                background: #fee2e2;
                                color: #ef4444;
                            }

                            .delete:hover {
                                background: #fecaca;
                            }

                            .alert-info {
                                background: #dcfce7;
                                color: #166534;
                                padding: 15px;
                                border-radius: 12px;
                                margin-bottom: 25px;
                                font-weight: 600;
                            }
                        </style>
                    </head>

                    <body>
                        <jsp:include page="layout/sidebar.jsp" />

                        <div class="main-content">
                            <div class="header">
                                <div>
                                    <h1>My Listed Items</h1>
                                    <p style="color: #64748b;">Manage the items you are sharing with others.</p>
                                </div>
                                <a href="addItem.jsp" class="btn-add">➕ Add New Item</a>
                            </div>

                            <% if(message !=null){ %>
                                <div class="alert-info">✅ <%= message %>
                                </div>
                                <% } %>

                                    <div class="table-container">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>Image</th>
                                                    <th>Name</th>
                                                    <th>Description</th>
                                                    <th>Price/Hour</th>
                                                    <th>Action</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% try { Connection con=DBConnection.getConnection(); String
                                                    q="SELECT * FROM items WHERE owner_email=? ORDER BY id DESC" ;
                                                    PreparedStatement ps=con.prepareStatement(q); ps.setString(1,
                                                    userEmail); ResultSet rs=ps.executeQuery(); boolean hasItems=false;
                                                    while(rs.next()) { hasItems=true; String img=rs.getString("image");
                                                    if(img==null || img.trim().isEmpty()) { img="default.png" ; } int
                                                    itemId=rs.getInt("id"); String itemName=rs.getString("name"); String
                                                    itemDesc=rs.getString("description"); double
                                                    itemPrice=rs.getDouble("price"); %>
                                                    <tr>
                                                        <td>
                                                            <img src="<%=request.getContextPath()%>/images/<%= img %>"
                                                                class="item-img"
                                                                onerror="this.src='<%=request.getContextPath()%>/images/default.png'">
                                                        </td>
                                                        <td style="font-weight: 600;">
                                                            <%= itemName %>
                                                        </td>
                                                        <td style="color: #64748b; font-size: 14px;">
                                                            <%= itemDesc %>
                                                        </td>
                                                        <td style="font-weight: 700; color: var(--primary);">₹ <%=
                                                                itemPrice %>
                                                        </td>
                                                        <td>
                                                            <a class="btn edit" href="editItem.jsp?id=<%= itemId %>">✏️
                                                                Edit</a>
                                                            <a class="btn delete"
                                                                href="DeleteItemServlet?id=<%= itemId %>"
                                                                onclick="return confirm('Delete?');">🗑️ Delete</a>
                                                        </td>
                                                    </tr>
                                                    <% } if(!hasItems) { %>
                                                        <tr>
                                                            <td colspan="5"
                                                                style="text-align: center; padding: 40px; color: #94a3b8;">
                                                                You haven't listed any items yet.</td>
                                                        </tr>
                                                        <% } rs.close(); ps.close(); con.close(); } catch(Exception e) {
                                                            %>
                                                            <tr>
                                                                <td colspan="5"
                                                                    style="text-align: center; color: #ef4444; padding: 20px;">
                                                                    Error: <%= e.getMessage() %>
                                                                </td>
                                                            </tr>
                                                            <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                        </div>
                    </body>

                    </html>