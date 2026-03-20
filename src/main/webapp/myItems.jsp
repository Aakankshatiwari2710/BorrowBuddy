<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userEmail = (String) session.getAttribute("userEmail");
    if (userId == null || userEmail == null) { response.sendRedirect("login.jsp"); return; }
    String message = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Listed Items | BorrowBuddy</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #0f766e; --secondary: #14b8a6; --bg: #f8fafc; --text: #1e293b; }
        * { box-sizing: border-box; }
        body { margin: 0; font-family: 'Outfit', sans-serif; background: var(--bg); color: var(--text); }
        .main-content { margin-left: 260px; padding: 40px; }
        .header { margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; }
        .header h1 { font-size: 28px; margin: 0; color: var(--primary); }
        .header p { color: #64748b; margin: 4px 0 0; font-size: 15px; }
        .btn-add { background: var(--primary); color: white; text-decoration: none; padding: 12px 22px; border-radius: 12px; font-weight: 600; font-size: 15px; transition: 0.3s; }
        .btn-add:hover { background: var(--secondary); transform: translateY(-2px); box-shadow: 0 6px 18px rgba(15,118,110,0.3); }
        .table-container { background: white; border-radius: 20px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.06); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8fafc; padding: 14px 20px; text-align: left; font-size: 12px; color: #64748b; font-weight: 700; border-bottom: 1px solid #f1f5f9; text-transform: uppercase; letter-spacing: 0.5px; }
        td { padding: 14px 20px; border-bottom: 1px solid #f1f5f9; font-size: 14px; vertical-align: middle; }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f8fafc; }
        .item-img { width: 80px; height: 60px; border-radius: 10px; object-fit: cover; display: block; }
        .category-badge { font-size: 11px; font-weight: 700; text-transform: uppercase; color: var(--primary); background: #f0fdfa; padding: 3px 10px; border-radius: 6px; display: inline-block; }
        .price-col { font-weight: 700; color: var(--primary); }
        .btn-action { display: inline-block; padding: 7px 14px; border-radius: 8px; text-decoration: none; font-size: 13px; font-weight: 600; transition: 0.2s; margin-right: 5px; border: none; cursor: pointer; }
        .btn-action:hover { transform: translateY(-1px); box-shadow: 0 3px 8px rgba(0,0,0,0.12); }
        .btn-edit   { background: #f1f5f9; color: #475569; }
        .btn-delete { background: #fee2e2; color: #ef4444; }
        .btn-edit:hover { background: #e2e8f0; }
        .btn-delete:hover { background: #fecaca; }
        .empty-state { text-align: center; padding: 60px 20px; }
        .empty-state p { color: #94a3b8; font-size: 17px; margin: 0 0 20px; }

        /* ── Success Toast ─────────────────────────────────────────────── */
        .toast {
            position: fixed;
            top: 28px;
            left: 50%;
            transform: translateX(-50%) translateY(-120px);
            background: #22c55e;
            color: white;
            padding: 16px 32px;
            border-radius: 50px;
            font-size: 16px;
            font-weight: 700;
            box-shadow: 0 8px 30px rgba(34,197,94,0.4);
            z-index: 9999;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: transform 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
            white-space: nowrap;
        }
        .toast.show { transform: translateX(-50%) translateY(0); }
        .toast-icon { font-size: 22px; }
        .toast-close { margin-left: 16px; cursor: pointer; font-size: 18px; opacity: 0.8; background: none; border: none; color: white; padding: 0; line-height: 1; }
        .toast-close:hover { opacity: 1; }

        /* ── Progress bar under toast ──────────────────────────────────── */
        .toast-bar {
            position: absolute;
            bottom: 0; left: 0;
            height: 4px;
            background: rgba(255,255,255,0.5);
            border-radius: 0 0 50px 50px;
            width: 100%;
            animation: shrink 4s linear forwards;
        }
        @keyframes shrink { from { width: 100%; } to { width: 0%; } }
    </style>
</head>
<body>

    <% if (message != null && !message.isEmpty()) { %>
    <div class="toast" id="successToast">
        <span class="toast-icon">&#9989;</span>
        <span><%= message %></span>
        <button class="toast-close" onclick="hideToast()">&#10005;</button>
        <div class="toast-bar"></div>
    </div>
    <script>
        window.addEventListener('DOMContentLoaded', function() {
            var t = document.getElementById('successToast');
            setTimeout(function(){ t.classList.add('show'); }, 100);
            setTimeout(function(){ t.classList.remove('show'); }, 4200);
        });
        function hideToast() {
            document.getElementById('successToast').classList.remove('show');
        }
    </script>
    <% } %>

    <jsp:include page="layout/sidebar.jsp" />

    <div class="main-content">
        <div class="header">
            <div>
                <h1>&#128230; My Listed Items</h1>
                <p>Manage the items you are sharing with the community.</p>
            </div>
            <a href="addItem.jsp" class="btn-add">&#43; Add New Item</a>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Image</th>
                        <th>Item Name</th>
                        <th>Category</th>
                        <th>Description</th>
                        <th>Price / hr</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
<%
    Connection con = null;
    try {
        con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM items WHERE owner_email = ? ORDER BY id DESC"
        );
        ps.setString(1, userEmail);
        ResultSet rs = ps.executeQuery();
        boolean hasItems = false;

        while (rs.next()) {
            hasItems = true;
            String img       = rs.getString("image");
            if (img == null || img.trim().isEmpty()) img = "default.png";
            int    itemId    = rs.getInt("id");
            String itemName  = rs.getString("name");
            String itemCat   = rs.getString("category");
            String itemDesc  = rs.getString("description");
            if (itemDesc == null) itemDesc = "";
            double itemPrice = rs.getDouble("price");
            String shortDesc = itemDesc.length() > 70 ? itemDesc.substring(0, 70) + "..." : itemDesc;
%>
                    <tr>
                        <td>
                            <img src="<%= request.getContextPath() %>/images/<%= img %>"
                                 class="item-img"
                                 onerror="this.src='<%= request.getContextPath() %>/images/default.png'">
                        </td>
                        <td style="font-weight:600;"><%= itemName %></td>
                        <td><span class="category-badge"><%= itemCat != null ? itemCat : "—" %></span></td>
                        <td style="color:#64748b;"><%= shortDesc %></td>
                        <td class="price-col">&#8377; <%= (int) itemPrice %></td>
                        <td>
                            <a class="btn-action btn-edit" href="editItem.jsp?id=<%= itemId %>">&#9998; Edit</a>
                            <a class="btn-action btn-delete"
                               href="DeleteItemServlet?id=<%= itemId %>"
                               onclick="return confirm('Delete this item? This cannot be undone.');">&#128465; Delete</a>
                        </td>
                    </tr>
<%
        }
        rs.close();
        ps.close();

        if (!hasItems) {
%>
                    <tr>
                        <td colspan="6">
                            <div class="empty-state">
                                <p>You have not listed any items yet.</p>
                                <a href="addItem.jsp" class="btn-add">&#43; List Your First Item</a>
                            </div>
                        </td>
                    </tr>
<%
        }
    } catch (Exception e) {
%>
                    <tr>
                        <td colspan="6" style="text-align:center;color:#ef4444;padding:20px;">
                            Error: <%= e.getMessage() %>
                        </td>
                    </tr>
<%
    } finally {
        try { if (con != null) con.close(); } catch (Exception e) {}
    }
%>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>