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
    <title>Shop Collection | SpanV Studios</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Flatpickr (Modern Calendar & Time Picker) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_green.css">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <style>
        :root { --primary: #db2777; --secondary: #be185d; --bg: #fff1f2; --text: #2d0b1e; --card: #ffffff; --border: #fbcfe8; }
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

        @media (max-width: 992px) {
            .main-content { margin-left: 0 !important; padding: 80px 15px 30px !important; }
            .grid { grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
            .header h1 { font-size: 26px; }
        }

        @media (max-width: 576px) {
            .grid { grid-template-columns: 1fr; }
        }
        
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
            <h1>Shop Boutique Collection</h1>
            <p style="color:#64748b">Explore our premium sarees, kurtis, lehengas, and designer wear.</p>
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
            <% String[] categories = {"All","Saree","Kurti","Lehenga","Western Wear","Dress Materials","Others"};
               for (String c : categories) {
                   String active = c.equals(cat) ? "active" : ""; %>
            <a href="viewItems.jsp?category=<%= c %><%= qry %>" class="category-btn <%= active %>"><%= c %></a>
            <% } %>
        </div>
        <% if ("booked".equals(success)) { %>
        <div class="alert-success" style="background:#fce7f3; color:#9d174d; border-left: 5px solid #db2777;">&#9989; Order request sent successfully! Check status in "My Orders".</div>
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
        if (con == null) {
            throw new Exception("Could not establish a database connection. Please check if MySQL is running.");
        }
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT i.*, b.status AS b_status, b.payment_status, u.is_verified AS owner_verified, u.location AS owner_loc, ");
        sql.append("(SELECT AVG(rating) FROM reviews WHERE item_id = i.id) as avg_item_rating, ");
        sql.append("(SELECT COUNT(*) FROM reviews WHERE item_id = i.id) as review_count ");
        sql.append("FROM items i ");
        sql.append("LEFT JOIN bookings b ON i.id = b.item_id AND b.borrower_id = ? ");
        sql.append("AND (b.status = 'Pending' OR b.status = 'Approved') ");
        sql.append("LEFT JOIN users u ON i.owner_email = u.email ");
        sql.append("WHERE 1=1 ");
        if (term.length() > 0) { sql.append("AND (i.name LIKE ? OR i.description LIKE ? OR u.location LIKE ?) "); }
        if (!"All".equals(cat)) { sql.append("AND i.category = ? "); }
        sql.append("AND i.price >= ? AND i.price <= ? ");
        sql.append("ORDER BY i.id DESC");
        PreparedStatement ps = con.prepareStatement(sql.toString());
        int idx = 1;
        ps.setInt(idx++, userId);
        if (term.length() > 0) { ps.setString(idx++, "%" + term + "%"); ps.setString(idx++, "%" + term + "%"); ps.setString(idx++, "%" + term + "%"); }
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
            String ownerLoc = rs.getString("owner_loc");
            if(ownerLoc == null || ownerLoc.isEmpty()) ownerLoc = "Neighbourhood";
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
                <div class="badge">₹<%= rs.getInt("price") %></div>
                <img src="<%=request.getContextPath()%>/images/<%= rs.getString("image") %>" id="mainImg_<%= itemId %>"
                     onerror="this.src='<%=request.getContextPath()%>/images/default.png'"
                     style="width: 100%; height: 220px; object-fit: cover; border-top-left-radius: 20px; border-top-right-radius: 20px;">

                <%
                    String imagesJson = "";
                    try { imagesJson = rs.getString("images_json"); } catch (Exception ignored) {}
                    if (imagesJson == null || imagesJson.trim().isEmpty()) imagesJson = itemImg;
                    String[] allPhotos = imagesJson.split(",");
                    if (allPhotos.length > 1) {
                %>
                    <div class="photo-thumbnails" style="display: flex; gap: 8px; padding: 8px 12px; background: #fafafa; overflow-x: auto; border-bottom: 1px solid #f1f5f9;">
                        <% for (int p = 0; p < allPhotos.length; p++) {
                            String pImg = allPhotos[p].trim();
                            if (pImg.isEmpty()) continue;
                        %>
                            <img src="<%=request.getContextPath()%>/images/<%= pImg %>"
                                 onclick="document.getElementById('mainImg_<%= itemId %>').src = this.src"
                                 style="width: 44px; height: 44px; object-fit: cover; border-radius: 8px; cursor: pointer; border: 2px solid #e2e8f0; transition: 0.2s;"
                                 onmouseover="this.style.borderColor='#db2777'"
                                 onmouseout="this.style.borderColor='#e2e8f0'"
                                 onerror="this.style.display='none'">
                        <% } %>
                    </div>
                <% } %>

                <div class="card-body">
                    <div style="display:flex; justify-content:space-between; align-items:start;">
                        <span class="item-category-badge"><%= rs.getString("category") %></span>
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
                    <% String offerTag = rs.getString("offer_tag");
                       String stockStatus = rs.getString("stock_status");
                       if (stockStatus == null || stockStatus.isEmpty()) stockStatus = "In Stock";
                       boolean isOutOfStock = "Out of Stock".equalsIgnoreCase(stockStatus);

                       if (offerTag != null && !offerTag.trim().isEmpty()) { %>
                        <div style="background:#f59e0b; color:white; font-size:11px; font-weight:800; padding:4px 10px; border-radius:6px; display:inline-block; margin-bottom:8px; text-transform:uppercase;">🏷️ <%= offerTag %></div>
                    <% } %>

                    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:8px;">
                        <p class="price" style="margin:0;">&#8377; <%= (int)itemPrice %></p>
                        <% if (isOutOfStock) { %>
                            <span style="background:#fee2e2; color:#b91c1c; font-size:11px; font-weight:800; padding:4px 10px; border-radius:50px;">🔴 OUT OF STOCK</span>
                        <% } else { %>
                            <span style="background:#dcfce7; color:#15803d; font-size:11px; font-weight:800; padding:4px 10px; border-radius:50px;">🟢 IN STOCK</span>
                        <% } %>
                    </div>
                    <p class="description"><%= itemDesc %></p>
                    <% 
                    String sessionUserEmail = (String) session.getAttribute("userEmail");
                    String ownerEmail = rs.getString("owner_email");
                    boolean isMyItem = sessionUserEmail != null && sessionUserEmail.equalsIgnoreCase(ownerEmail);
                    
                    if (isMyItem) { %>
                        <a href="editItem.jsp?id=<%= itemId %>" class="btn-book" style="background:#2563eb; text-decoration:none; text-align:center; display:block; box-sizing:border-box;">✏️ Manage / Edit Item</a>
                    <% } else if (isOutOfStock) { %>
                        <button class="btn-book btn-disabled" disabled style="background:#cbd5e1!important; color:#64748b!important; cursor:not-allowed; border:none; width:100%;">🔴 Out of Stock</button>
                    <% } else if (bStatus == null) { %>
                    <form action="BookItemServlet" method="post">
                        <input type="hidden" name="itemId" value="<%= itemId %>">
                        <input type="hidden" name="startDate" value="">
                        <input type="hidden" name="endDate" value="">
                        <input type="hidden" name="conditionNote" value="Purchase">
                        <button class="btn-book" style="background:var(--primary);">Buy Now</button>
                    </form>
                    <% } else if ("Pending".equalsIgnoreCase(bStatus)) { %>
                    <button class="btn-book btn-disabled" disabled style="background:#fbcfe8!important; color:#be185d!important;">Order Pending Approval</button>
                    <% } else if ("Approved".equalsIgnoreCase(bStatus) && "Paid".equalsIgnoreCase(pStatus)) { %>
                    <button class="btn-book btn-disabled" style="background:#10b981!important;color:#fff!important;" disabled>Paid & Confirmed</button>
                    <% } else if ("Approved".equalsIgnoreCase(bStatus)) { %>
                    <a href="myBookings.jsp" class="btn-book" style="display:block;text-align:center;text-decoration:none;background:#db2777;box-sizing:border-box;">Pay Now</a>
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
            }, 800); 

            // Initialize Modern Calendar (Flatpickr)
            flatpickr(".datetime-picker", {
                enableTime: true,
                dateFormat: "Y-m-dTH:i", // Standard format for server
                altInput: true,
                altFormat: "F j, Y  h:i K", // User friendly display
                minDate: "today",
                time_24hr: false
            });
        });
    </script>
</body>
</html>