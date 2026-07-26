<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>
<% 
    Integer userId = (Integer) session.getAttribute("userId");
    String userEmail = (String) session.getAttribute("userEmail");
    String userRole = (String) session.getAttribute("userRole");

    if (userId == null || userEmail == null || userRole == null || !userRole.equalsIgnoreCase("Owner")) {
        response.sendRedirect("login.jsp");
        return;
    }

    String id = request.getParameter("id");
    if (id == null || id.isEmpty()) {
        response.sendRedirect("myItems.jsp");
        return;
    }

    String name = "", description = "", image = "", category = "", offerTag = "", stockStatus = "In Stock";
    double price = 0;
    String errorMsg = null;

    try (Connection con = DBConnection.getConnection()) {
        if (con == null) {
            errorMsg = "Database connection failed. Please check if MySQL is running.";
        } else {
            String sql = "SELECT * FROM items WHERE id=? AND owner_email=?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, Integer.parseInt(id));
                ps.setString(2, userEmail);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        name = rs.getString("name");
                        description = rs.getString("description");
                        price = rs.getDouble("price");
                        image = rs.getString("image");
                        category = rs.getString("category");
                        offerTag = rs.getString("offer_tag");
                        stockStatus = rs.getString("stock_status") != null ? rs.getString("stock_status") : "In Stock";
                    } else {
                        response.sendRedirect("myItems.jsp");
                        return;
                    }
                }
            }
        }
    } catch (Exception e) {
        errorMsg = "Error: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product | SpanV Studios</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #db2777; --secondary: #be185d; --bg: #fff1f2; --card: #ffffff; --text: #2d0b1e; }
        body { margin: 0; font-family: 'Outfit', sans-serif; background: var(--bg); color: var(--text); }
        .main-content { margin-left: 260px; padding: 40px; }
        .container { max-width: 600px; margin: 0 auto; }
        .card { background: var(--card); padding: 40px; border-radius: 25px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        h2 { margin: 0 0 10px; font-size: 28px; color: var(--primary); }
        .form-group { margin-bottom: 20px; }
        label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 14px; }
        input, textarea, select { width: 100%; padding: 12px 15px; border-radius: 12px; border: 1px solid #e2e8f0; font-family: inherit; box-sizing: border-box; outline: none; transition: 0.3s; }
        input:focus, textarea:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.1); }
        .current-img { width: 100%; height: 200px; object-fit: cover; border-radius: 15px; margin-bottom: 20px; border: 3px solid #f1f5f9; }
        .btn-submit { width: 100%; padding: 15px; background: var(--primary); color: white; border: none; border-radius: 12px; font-size: 16px; font-weight: 700; cursor: pointer; transition: 0.3s; margin-top: 10px; }
        .btn-submit:hover { background: var(--secondary); transform: translateY(-2px); }
        .error-banner { background: #fee2e2; color: #ef4444; padding: 15px; border-radius: 12px; margin-bottom: 20px; font-weight: 500; font-size: 14px; }
    </style>
</head>
<body>
    <jsp:include page="layout/sidebar.jsp" />
    <div class="main-content">
        <div class="container">
            <div class="card">
                <h2>Edit Product</h2>
                <p style="color: #64748b; margin-bottom: 25px;">Update the details for your boutique product.</p>

                <% if (errorMsg != null) { %>
                    <div class="error-banner">⚠️ <%= errorMsg %></div>
                <% } %>

                <form action="UpdateItemServlet" method="post">
                    <input type="hidden" name="id" value="<%= id %>">
                    
                    <div class="form-group" style="text-align: center;">
                        <img src="<%=request.getContextPath()%>/images/<%= (image != null && !image.isEmpty()) ? image : "default.png" %>" 
                             class="current-img" onerror="this.src='<%=request.getContextPath()%>/images/default.png'">
                    </div>

                    <div class="form-group">
                        <label>Product Name</label>
                        <input type="text" name="name" value="<%= name %>" required>
                    </div>

                    <div class="form-group">
                        <label>Description (Optional)</label>
                        <textarea name="description" rows="4"><%= description != null ? description : "" %></textarea>
                    </div>

                    <div class="form-group">
                        <label>Product Price (₹) *</label>
                        <input type="number" name="price" value="<%= (int)price %>" required>
                    </div>

                    <div class="form-group">
                        <label>Offer / Discount Badge (Optional)</label>
                        <input type="text" name="offer_tag" value="<%= offerTag != null ? offerTag : "" %>" placeholder="e.g. 20% OFF, Festival Offer, Buy 1 Get 1">
                    </div>

                    <div class="form-group">
                        <label>Category</label>
                        <select name="category" required>
                            <% String[] cats = {"Saree", "Kurti", "Lehenga", "Western Wear", "Dress Materials", "Others"};
                               for(String c : cats) { %>
                                <option value="<%= c %>" <%= c.equals(category) ? "selected" : "" %>><%= c %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Availability / Stock Status (Optional)</label>
                        <select name="stock_status" style="width:100%; padding:12px; border-radius:12px; border:1px solid #e2e8f0; font-family:inherit; font-size:14px;">
                            <option value="In Stock" <%= "In Stock".equalsIgnoreCase(stockStatus) ? "selected" : "" %>>🟢 In Stock (Available for Buyers)</option>
                            <option value="Out of Stock" <%= "Out of Stock".equalsIgnoreCase(stockStatus) ? "selected" : "" %>>🔴 Out of Stock (Temporarily Unavailable)</option>
                        </select>
                    </div>

                    <button type="submit" class="btn-submit">Save Changes</button>
                    <a href="myItems.jsp" style="display:block; text-align:center; margin-top:20px; text-decoration:none; color:#64748b; font-size:14px;">Cancel & Go Back</a>
                </form>
            </div>
        </div>
    </div>
</body>
</html>