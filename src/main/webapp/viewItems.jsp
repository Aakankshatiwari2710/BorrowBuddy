<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, util.DBConnection" %>
<%@ page session="true" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("login.jsp"); return; }
    String success = request.getParameter("success");
    String term = request.getParameter("search");
    if (term == null) term = "";
    term = term.trim();
    String cat = request.getParameter("category");
    if (cat == null) cat = "All";
    
    String minPriceStr = request.getParameter("minPrice");
    String maxPriceStr = request.getParameter("maxPrice");
    double minPrice = (minPriceStr != null && !minPriceStr.isEmpty()) ? Double.parseDouble(minPriceStr) : 0;
    double maxPrice = (maxPriceStr != null && !maxPriceStr.isEmpty()) ? Double.parseDouble(maxPriceStr) : 1000000;

    String qry = (term.length() > 0) ? "&search=" + term : "";
    if (minPrice > 0) qry += "&minPrice=" + minPrice;
    if (maxPrice < 1000000) qry += "&maxPrice=" + maxPrice;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Items | BorrowBuddy</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #0f766e; --secondary: #14b8a6; --bg: #f8fafc; --text: #1e293b; --card: #ffffff; --border: #e2e8f0; }
        body { margin: 0; font-family: 'Outfit', sans-serif; background: var(--bg); color: var(--text); }
        .main-content { margin-left: 260px; padding: 40px; }
        .header { margin-bottom: 35px; }
        .header h1 { font-size: 32px; margin: 0; color: var(--primary); }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 30px; }
        .card { background: var(--card); border-radius: 20px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); transition: 0.3s; position: relative; display: flex; flex-direction: column; }
        .card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        .card img { width: 100%; height: 200px; object-fit: cover; }
        .card-body { padding: 20px; flex-grow: 1; display: flex; flex-direction: column; }
        .card-body h3 { margin: 0 0 10px; font-size: 20px; }
        .price { font-size: 20px; font-weight: 700; color: var(--primary); margin-bottom: 15px; }
        .description { font-size: 14px; color: #64748b; margin-bottom: 20px; line-height: 1.5; flex-grow: 1; }
        .time-slots { margin-bottom: 15px; background: #f8fafc; padding: 12px; border-radius: 12px; border: 1px solid #f1f5f9; }
        .time-group { margin-bottom: 10px; }
        .time-group label { display: block; font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 4px; }
        .time-group input { width: 100%; border: 1px solid #e2e8f0; border-radius: 8px; padding: 8px; font-family: inherit; font-size: 13px; box-sizing: border-box; }
        .btn-book { width: 100%; padding: 12px; background: var(--primary); color: #fff; border: none; border-radius: 12px; cursor: pointer; font-weight: 600; transition: 0.3s; }
        .btn-book:hover { background: var(--secondary); }
        .btn-disabled { background: #e2e8f0 !important; color: #94a3b8 !important; cursor: not-allowed !important; }
        .badge { position: absolute; top: 15px; right: 15px; padding: 6px 12px; border-radius: 50px; font-size: 12px; background: rgba(255,255,255,0.9); backdrop-filter: blur(5px); font-weight: 700; box-shadow: 0 2px 5px rgba(0,0,0,0.1); color: var(--primary); }
        .alert-success { background: #dcfce7; color: #166534; padding: 15px; border-radius: 12px; margin-bottom: 25px; }
        .category-filter { display: flex; gap: 10px; margin-bottom: 30px; overflow-x: auto; padding-bottom: 10px; scrollbar-width: none; }
        .category-filter::-webkit-scrollbar { display: none; }
        .category-btn { padding: 10px 22px; background: var(--card); border: 1px solid var(--border); border-radius: 50px; color: var(--text); text-decoration: none; font-size: 14px; font-weight: 500; white-space: nowrap; transition: 0.3s; cursor: pointer; }
        .category-btn:hover { border-color: var(--primary); color: var(--primary); }
        .category-btn.active { background: var(--primary); color: white; border-color: var(--primary); box-shadow: 0 4px 12px rgba(15,118,110,0.2); }
        .item-category-badge { font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--primary); background: #f0fdfa; padding: 3px 10px; border-radius: 6px; display: inline-block; margin-bottom: 8px; }
        .search-area { margin: 25px 0 15px; max-width: 500px; position: relative; }
        .search-input { width: 100%; padding: 14px 20px 14px 45px; border-radius: 12px; border: 1px solid var(--primary); background: var(--card); color: var(--text); font-family: inherit; font-size: 16px; outline: none; box-shadow: 0 4px 10px rgba(0,0,0,0.05); box-sizing: border-box; }
        .search-icon { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #94a3b8; font-size: 18px; }
        
        /* Skeleton Loader */
        .skeleton { background: #e2e8f0; position: relative; overflow: hidden; height: 350px; border-radius: 20px; }
        .skeleton::after { content: ""; position: absolute; top: 0; right: 0; bottom: 0; left: 0; transform: translateX(-100%); background: linear-gradient(90deg, rgba(255,255,255,0) 0, rgba(255,255,255,0.2) 20%, rgba(255,255,255,0.5) 60%, rgba(255,255,255,0)); animation: shimmer 2s infinite; }
        @keyframes shimmer { 100% { transform: translateX(100%); } }
    </style>
</head>
<body>
    <jsp:include page="layout/sidebar.jsp" />
    <div class="main-content">
        <div class="header">
            <h1>Browse Items</h1>
            <p style="color:#64748b">Find items to borrow from your neighbourhood</p>
        </div>
        <div class="search-area" style="max-width: 800px;">
            <form action="viewItems.jsp" method="get" id="searchForm" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                <div style="position:relative; flex:2; min-width:250px;">
                    <span class="search-icon">&#128269;</span>
                    <input type="text" name="search" class="search-input" placeholder="Search items..." value="<%= term %>">
                </div>
                <div style="display:flex; gap:5px; flex:1; min-width:200px;">
                    <input type="number" name="minPrice" class="search-input" style="padding: 10px; font-size:14px;" placeholder="Min ₹" value="<%= minPriceStr != null ? minPriceStr : "" %>">
                    <input type="number" name="maxPrice" class="search-input" style="padding: 10px; font-size:14px;" placeholder="Max ₹" value="<%= maxPriceStr != null ? maxPriceStr : "" %>">
                </div>
                <% if (!"All".equals(cat)) { %>
                    <input type="hidden" name="category" value="<%= cat %>">
                <% } %>
                <button type="submit" class="category-btn active" style="padding: 12px 25px;">Filter</button>
            </form>
        </div>
        <div class="category-filter">
            <% String[] categories = {"All","Electronics","Toys","Stationery","Tools","Appliances","Sports","Others"};
               for (String c : categories) {
                   String active = c.equals(cat) ? "active" : ""; %>
            <a href="viewItems.jsp?category=<%= c %><%= qry %>" class="category-btn <%= active %>"><%= c %></a>
            <% } %>
        </div>
        <% if ("booked".equals(success)) { %>
        <div class="alert-success">&#9989; Booking request sent successfully!</div>
        <% } %>
        <div class="grid" id="skeleton-grid">
            <div class="skeleton"></div>
            <div class="skeleton"></div>
            <div class="skeleton"></div>
            <div class="skeleton"></div>
            <div class="skeleton"></div>
            <div class="skeleton"></div>
        </div>

        <div class="grid" id="item-grid" style="display: none;">
<%
    String userEmail = (String) session.getAttribute("userEmail");
    Connection con = null;
    try {
        con = DBConnection.getConnection();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT i.*, b.status AS b_status, b.payment_status, u.is_verified AS owner_verified, ");
        sql.append("(SELECT AVG(rating) FROM reviews WHERE item_id = i.id) as avg_item_rating, ");
        sql.append("(SELECT COUNT(*) FROM reviews WHERE item_id = i.id) as review_count ");
        sql.append("FROM items i ");
        sql.append("LEFT JOIN bookings b ON i.id = b.item_id AND b.borrower_id = ? ");
        sql.append("AND (b.status = 'Pending' OR b.status = 'Approved') ");
        sql.append("JOIN users u ON i.owner_email = u.email ");
        sql.append("WHERE i.owner_email != ? ");
        if (term.length() > 0) { sql.append("AND (i.name LIKE ? OR i.description LIKE ?) "); }
        if (!"All".equals(cat)) { sql.append("AND i.category = ? "); }
        sql.append("AND i.price >= ? AND i.price <= ? ");
        sql.append("ORDER BY i.id DESC");
        PreparedStatement ps = con.prepareStatement(sql.toString());
        int idx = 1;
        ps.setInt(idx++, userId);
        ps.setString(idx++, userEmail);
        if (term.length() > 0) { ps.setString(idx++, "%" + term + "%"); ps.setString(idx++, "%" + term + "%"); }
        if (!"All".equals(cat)) { ps.setString(idx++, cat); }
        ps.setDouble(idx++, minPrice);
        ps.setDouble(idx++, maxPrice);
        ResultSet rs = ps.executeQuery();
        boolean hasItems = false;
        while (rs.next()) {
            hasItems = true;
            String bStatus = rs.getString("b_status");
            String pStatus = rs.getString("payment_status");
            String itemImg = rs.getString("image");
            if (itemImg == null || itemImg.isEmpty()) itemImg = "default.png";
            int itemId = rs.getInt("id");
            String itemCat = rs.getString("category");
            String itemName = rs.getString("name");
            double itemPrice = rs.getDouble("price");
            String itemDesc = rs.getString("description");
            boolean isOwnerVerified = rs.getBoolean("owner_verified");
            // Mock Distance logic
            double distance = 0.5 + (Math.random() * 4.5);
            String distStr = String.format("%.1f", distance);
            double itemRating = rs.getDouble("avg_item_rating");
            int reviewCount = rs.getInt("review_count");
%>
            <div class="card" style="animation: fadeIn 0.5s ease-out forwards;">
                <style>
                    @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
                </style>
                <div class="badge">₹<%= rs.getInt("price") %>/hr</div>
                <img src="<%=request.getContextPath()%>/images/<%= rs.getString("image") %>" 
                     onerror="this.src='<%=request.getContextPath()%>/images/default.png'">
                <div class="card-body">
                    <div style="display:flex; justify-content:space-between; align-items:start;">
                        <span class="item-category-badge"><%= rs.getString("category") %></span>
                        <span style="font-size:11px; color:#64748b; font-weight:600;">📍 <%= distStr %> km away</span>
                    </div>
                    <h3 style="display:flex; align-items:center; gap:8px; margin-bottom:5px;">
                        <%= rs.getString("name") %>
                        <% if(isOwnerVerified) { %>
                            <span title="Verified Owner" style="display:inline-flex; align-items:center; justify-content:center; width:16px; height:16px; background:#14b8a6; color:white; border-radius:50%; font-size:9px;">✓</span>
                        <% } %>
                    </h3>
                    <div style="display:flex; align-items:center; gap:5px; margin-bottom:15px; font-size:13px; color:#f59e0b; font-weight:700;">
                        <span>⭐ <%= itemRating > 0 ? String.format("%.1f", itemRating) : "New" %></span>
                        <span style="color:#94a3b8; font-weight:500;">(<%= reviewCount %> reviews)</span>
                    </div>
                    <p class="price">&#8377; <%= (int)itemPrice %>/hr</p>
                    <p class="description"><%= itemDesc %></p>
                    <% if (bStatus == null) { %>
                    <form action="BookItemServlet" method="post">
                        <input type="hidden" name="itemId" value="<%= itemId %>">
                        <div class="time-slots">
                            <div class="time-group"><label>Start Time</label><input type="datetime-local" name="startDate" required></div>
                            <div class="time-group"><label>End Time</label><input type="datetime-local" name="endDate" required></div>
                            <div class="time-group"><label>Condition Note (Optional)</label><input type="text" name="conditionNote" placeholder="e.g. Scratched" style="width:100%; border:1px solid #e2e8f0; border-radius:8px; padding:8px; font-size:13px; box-sizing:border-box;"></div>
                        </div>
                        <button class="btn-book">Rent Now</button>
                    </form>
                    <% } else if ("Pending".equalsIgnoreCase(bStatus)) { %>
                    <button class="btn-book btn-disabled" disabled>Pending Approval</button>
                    <% } else if ("Approved".equalsIgnoreCase(bStatus) && "Paid".equalsIgnoreCase(pStatus)) { %>
                    <button class="btn-book btn-disabled" style="background:#10b981!important;color:#fff!important;" disabled>Paid</button>
                    <% } else if ("Approved".equalsIgnoreCase(bStatus)) { %>
                    <a href="myBookings.jsp" class="btn-book" style="display:block;text-align:center;text-decoration:none;background:#0ea5e9;box-sizing:border-box;">Pay Now</a>
                    <% } %>
                </div>
            </div>
<%      }
        if (!hasItems) { %>
        <div style="grid-column:1/-1;text-align:center;padding:60px;background:white;border-radius:20px;">
            <p style="color:#94a3b8;font-size:18px;"><%= (term.length() > 0) ? "No items match your search." : "No items available yet." %></p>
        </div>
<%      }
        rs.close(); ps.close();
    } catch (Exception e) { %>
        <div style="grid-column:1/-1;color:#ef4444;background:#fee2e2;padding:20px;border-radius:12px;">Error: <%= e.getMessage() %></div>
<%  } finally { try { if (con != null) con.close(); } catch (Exception e) {} } %>
        </div>
    </div>
    
    <script>
        window.addEventListener('DOMContentLoaded', () => {
            setTimeout(() => {
                document.getElementById('skeleton-grid').style.display = 'none';
                document.getElementById('item-grid').style.display = 'grid';
            }, 800); // Brief delay for effect
        });
    </script>
</body>
</html>