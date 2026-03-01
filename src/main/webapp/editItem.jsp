<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*" %>
        <%@ page import="util.DBConnection" %>
            <%@ page session="true" %>
                <% Integer userId=(Integer) session.getAttribute("userId"); String userEmail=(String)
                    session.getAttribute("userEmail"); String userRole=(String) session.getAttribute("userRole"); if
                    (userId==null || userEmail==null || userRole==null || !userRole.equalsIgnoreCase("Owner")) {
                    response.sendRedirect("login.jsp"); return; } String id=request.getParameter("id"); String name="" ,
                    description="" , image="" ; double price=0; try (Connection con=DBConnection.getConnection();
                    PreparedStatement ps=con.prepareStatement("SELECT * FROM items WHERE id=? AND owner_email=?")) {
                    ps.setInt(1, Integer.parseInt(id !=null ? id : "0" )); ps.setString(2, userEmail); try (ResultSet
                    rs=ps.executeQuery()) { if(rs.next()){ name=rs.getString("name");
                    description=rs.getString("description"); price=rs.getDouble("price"); image=rs.getString("image"); }
                    else { response.sendRedirect("myItems.jsp"); return; } } } catch(Exception e){ e.printStackTrace();
                    } %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Edit Item | BorrowBuddy</title>
                        <link
                            href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
                            rel="stylesheet">
                        <style>
                            :root {
                                --primary: #0f766e;
                                --secondary: #14b8a6;
                                --bg: #f8fafc;
                                --card: #ffffff;
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

                            .container {
                                max-width: 600px;
                                margin: 0 auto;
                            }

                            .card {
                                background: var(--card);
                                padding: 40px;
                                border-radius: 25px;
                                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
                            }

                            h2 {
                                margin: 0 0 10px;
                                font-size: 28px;
                                color: var(--primary);
                            }

                            .form-group {
                                margin-bottom: 20px;
                                text-align: left;
                            }

                            label {
                                display: block;
                                font-weight: 600;
                                margin-bottom: 8px;
                                font-size: 14px;
                            }

                            input[type="text"],
                            input[type="number"],
                            textarea {
                                width: 100%;
                                padding: 12px 15px;
                                border-radius: 12px;
                                border: 1px solid #e2e8f0;
                                font-family: inherit;
                                box-sizing: border-box;
                                outline: none;
                                transition: 0.3s;
                            }

                            input:focus,
                            textarea:focus {
                                border-color: var(--primary);
                                box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.1);
                            }

                            .current-img {
                                width: 150px;
                                height: 100px;
                                object-fit: cover;
                                border-radius: 12px;
                                margin-bottom: 20px;
                                border: 2px solid #f1f5f9;
                            }

                            .btn-submit {
                                width: 100%;
                                padding: 15px;
                                background: var(--primary);
                                color: white;
                                border: none;
                                border-radius: 12px;
                                font-size: 16px;
                                font-weight: 700;
                                cursor: pointer;
                                transition: 0.3s;
                                margin-top: 20px;
                            }

                            .btn-submit:hover {
                                background: var(--primary-hover);
                                transform: translateY(-2px);
                            }

                            .back-btn {
                                display: inline-block;
                                margin-top: 20px;
                                color: #64748b;
                                text-decoration: none;
                                font-size: 14px;
                                font-weight: 500;
                            }
                        </style>
                    </head>

                    <body>
                        <jsp:include page="layout/sidebar.jsp" />
                        <div class="main-content">
                            <div class="container">
                                <div class="card">
                                    <h2>Edit Item</h2>
                                    <p style="color: #64748b; margin-bottom: 25px;">Update the details for your listed
                                        item.</p>

                                    <div style="text-align: center;">
                                        <img src="<%=request.getContextPath()%>/images/<%= image %>" class="current-img"
                                            onerror="this.src='<%=request.getContextPath()%>/images/default.png'">
                                    </div>

                                    <form action="UpdateItemServlet" method="post">
                                        <input type="hidden" name="id" value="<%= id %>">

                                        <div class="form-group">
                                            <label>Item Name</label>
                                            <input type="text" name="name" value="<%= name %>" required>
                                        </div>

                                        <div class="form-group">
                                            <label>Description</label>
                                            <textarea name="description" required><%= description %></textarea>
                                        </div>

                                        <div class="form-group">
                                            <label>Price per Hour (₹)</label>
                                            <input type="number" name="price" value="<%= (int)price %>" required>
                                        </div>

                                        <button type="submit" class="btn-submit">Update Details</button>
                                    </form>

                                    <a href="myItems.jsp" class="back-btn">← Back to My Items</a>
                                </div>
                            </div>
                        </div>
                    </body>

                    </html>