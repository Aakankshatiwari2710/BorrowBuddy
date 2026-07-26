<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String email = (String) session.getAttribute("userEmail");
    if (userId == null || email == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Orders & Sales | SpanV Studios</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <jsp:include page="layout/global_scripts.jsp" />
    <style>
        :root {
            --primary: #db2777;
            --secondary: #be185d;
            --bg: #fff1f2;
            --text: #2d0b1e;
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

        .header h1 {
            font-size: 28px;
            margin: 0;
            color: var(--primary);
        }

        .table-container {
            background: white;
            border-radius: 20px;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 750px;
        }

        @media (max-width: 992px) {
            .main-content { margin-left: 0 !important; padding: 80px 15px 30px !important; }
            .header h1 { font-size: 24px; }
            .stats-grid { grid-template-columns: 1fr !important; gap: 15px !important; }
        }

        th {
            background: #f8fafc;
            padding: 15px 18px;
            text-align: left;
            font-size: 12px;
            color: #64748b;
            font-weight: 700;
            border-bottom: 1px solid #f1f5f9;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        td {
            padding: 15px 18px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
            vertical-align: middle;
        }

        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f8fafc; }

        .status-badge {
            padding: 4px 12px;
            border-radius: 50px;
            font-size: 12px;
            font-weight: 700;
            display: inline-block;
        }

        .status-Approved { background: #dcfce7; color: #166534; }
        .status-Pending  { background: #fef3c7; color: #92400e; }
        .status-Rejected { background: #fee2e2; color: #991b1b; }
        .status-Cancelled { background: #fee2e2; color: #991b1b; }

        .pay-badge {
            display: inline-block;
            margin-top: 4px;
            font-size: 11px;
            font-weight: 800;
            padding: 3px 8px;
            border-radius: 4px;
        }
        .pay-paid   { background: #d1fae5; color: #065f46; }
        .pay-unpaid { background: #fef9c3; color: #854d0e; }

        .btn {
            display: inline-block;
            padding: 8px 14px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            transition: 0.25s;
            margin-right: 4px;
            cursor: pointer;
            border: none;
            white-space: nowrap;
        }

        .btn-approve { background: var(--primary); color: white; }
        .btn-reject  { background: #ef4444; color: white; }
        .btn:hover { transform: translateY(-1px); box-shadow: 0 4px 10px rgba(0,0,0,0.12); }
    </style>
</head>

<body>
    <jsp:include page="layout/sidebar.jsp" />

    <div class="main-content">
        <div class="header">
            <h1>Sales &amp; Order Management</h1>
            <p style="color: #64748b; margin-top: 5px;">Track your boutique sales, earnings, payments, and delivery addresses.</p>
        </div>

        <% 
           int totalBookings = 0;
           double totalEarnings = 0;
           int pendingCount = 0;
           String topItem = "None";
           int maxBookings = 0;

           try (Connection conAn = DBConnection.getConnection();
                PreparedStatement psAn = conAn.prepareStatement(
                    "SELECT i.name, COUNT(b.id) as b_cnt, SUM(CASE WHEN b.payment_status='Paid' OR b.status='Approved' THEN i.price ELSE 0 END) as earn " +
                    "FROM bookings b JOIN items i ON b.item_id = i.id WHERE i.owner_email=? GROUP BY i.id, i.name")) {
               psAn.setString(1, email);
               try (ResultSet rsAn = psAn.executeQuery()) {
                   while(rsAn.next()) {
                       totalEarnings += rsAn.getDouble("earn");
                       int cnt = rsAn.getInt("b_cnt");
                       if(cnt > maxBookings) {
                           maxBookings = cnt;
                           topItem = rsAn.getString("name");
                       }
                   }
               }
           } catch(Exception e) {}
           
           try (Connection conP = DBConnection.getConnection();
                PreparedStatement psP = conP.prepareStatement("SELECT COUNT(*) FROM bookings b JOIN items i ON b.item_id = i.id WHERE i.owner_email=? AND (b.status='Pending' OR b.payment_status='Pending Verification')")) {
               psP.setString(1, email);
               try(ResultSet rsP = psP.executeQuery()) { if(rsP.next()) pendingCount = rsP.getInt(1); }
           } catch(Exception e) {}
           
           try (Connection conA = DBConnection.getConnection();
                PreparedStatement psA = conA.prepareStatement("SELECT COUNT(*) FROM bookings b JOIN items i ON b.item_id = i.id WHERE i.owner_email=? AND b.status='Approved'")) {
               psA.setString(1, email);
               try(ResultSet rsA = psA.executeQuery()) { if(rsA.next()) totalBookings = rsA.getInt(1); }
           } catch(Exception e) {}
        %>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 30px;">
            <div style="background: white; padding: 22px; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-left: 5px solid #10b981;">
                <span style="display: block; font-size: 12px; color: #64748b; font-weight: 700; text-transform: uppercase;">Total Earnings</span>
                <span style="display: block; font-size: 26px; font-weight: 800; color: #1e293b; margin-top: 4px;">₹<%= (int)totalEarnings %></span>
            </div>
            <div style="background: white; padding: 22px; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-left: 5px solid #3b82f6;">
                <span style="display: block; font-size: 12px; color: #64748b; font-weight: 700; text-transform: uppercase;">Confirmed Orders</span>
                <span style="display: block; font-size: 26px; font-weight: 800; color: #1e293b; margin-top: 4px;"><%= totalBookings %></span>
            </div>
            <div style="background: white; padding: 22px; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-left: 5px solid #f59e0b;">
                <span style="display: block; font-size: 12px; color: #64748b; font-weight: 700; text-transform: uppercase;">Pending Verification</span>
                <span style="display: block; font-size: 26px; font-weight: 800; color: #1e293b; margin-top: 4px;"><%= pendingCount %></span>
            </div>
            <div style="background: white; padding: 22px; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-left: 5px solid #8b5cf6;">
                <span style="display: block; font-size: 12px; color: #64748b; font-weight: 700; text-transform: uppercase;">Top Performer</span>
                <span style="display: block; font-size: 18px; font-weight: 800; color: #1e293b; margin-top: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="<%= topItem %>"><%= topItem %></span>
            </div>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Product &amp; Price</th>
                        <th>Customer Details</th>
                        <th>📦 Delivery Address</th>
                        <th>Payment UTR Ref</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                    String sql = "SELECT b.id, b.item_id, b.status, b.payment_status, b.condition_note, " +
                                 "b.shipping_address, b.shipping_city, b.shipping_pincode, b.shipping_phone, " +
                                 "i.name AS item_name, i.price AS item_price, i.image AS item_image, " +
                                 "u.name AS borrower_name, u.email AS borrower_email " +
                                 "FROM bookings b JOIN items i ON b.item_id = i.id " +
                                 "JOIN users u ON b.borrower_id = u.id " +
                                 "WHERE i.owner_email=? ORDER BY b.id DESC";
                    
                    try (Connection con = DBConnection.getConnection(); 
                         PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setString(1, email);
                        try (ResultSet rs = ps.executeQuery()) {
                            boolean found = false;
                            while(rs.next()){
                                found = true;
                                int b_id = rs.getInt("id");
                                String itemName = rs.getString("item_name");
                                double itemPrice = rs.getDouble("item_price");
                                String itemImg = rs.getString("item_image");
                                if(itemImg == null || itemImg.isEmpty()) itemImg = "default.png";
                                
                                String custName = rs.getString("borrower_name");
                                String custEmail = rs.getString("borrower_email");
                                String custPhone = rs.getString("shipping_phone");
                                String shipAddr = rs.getString("shipping_address");
                                String shipCity = rs.getString("shipping_city");
                                String shipPin = rs.getString("shipping_pincode");
                                
                                String status = rs.getString("status");
                                String payStatus = rs.getString("payment_status") != null ? rs.getString("payment_status") : "Unpaid";
                                String utrRef = rs.getString("condition_note");
                                boolean isPaid = "Paid".equalsIgnoreCase(payStatus);
                    %>
                        <tr>
                            <td style="font-weight:700; color:#64748b;">#<%= b_id %></td>
                            <td>
                                <div style="display:flex; align-items:center; gap:10px;">
                                    <img src="<%=request.getContextPath()%>/images/<%=itemImg%>" onerror="this.src='<%=request.getContextPath()%>/images/default.png'" style="width:40px; height:40px; object-fit:cover; border-radius:8px;">
                                    <div>
                                        <div style="font-weight:700; color:#0f172a;"><%= itemName %></div>
                                        <div style="font-weight:800; color:#be185d; font-size:13px;">₹<%= (int)itemPrice %></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div style="font-weight:700; color:#0f172a;"><%= custName %></div>
                                <div style="color:#64748b; font-size:12px;"><%= custEmail %></div>
                                <% if(custPhone != null && !custPhone.isEmpty()) { %>
                                    <div style="color:#0284c7; font-weight:700; font-size:12px;">📞 <%= custPhone %></div>
                                <% } %>
                            </td>
                            <td style="font-size:13px; color:#334155; max-width:200px;">
                                <% if (shipAddr != null && !shipAddr.trim().isEmpty()) { %>
                                    📍 <strong><%= shipAddr %></strong><br>
                                    <%= shipCity != null ? shipCity : "" %> <%= shipPin != null ? ("- " + shipPin) : "" %>
                                <% } else { %>
                                    <span style="color:#94a3b8; font-style:italic;">Not provided yet</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (utrRef != null && utrRef.startsWith("UTR:")) { %>
                                    <span style="background:#e0e7ff; color:#3730a3; font-size:11px; font-weight:700; padding:4px 8px; border-radius:6px; display:inline-block;"><%= utrRef %></span>
                                <% } else { %>
                                    <span style="color:#94a3b8; font-size:12px;">Pending UTR</span>
                                <% } %>
                            </td>
                            <td>
                                <span class="status-badge status-<%= status %>"><%= status %></span>
                                <div><span class="pay-badge <%= isPaid ? "pay-paid" : "pay-unpaid" %>"><%= isPaid ? "PAID" : payStatus %></span></div>
                            </td>
                            <td>
                                <% if ("Cancelled".equalsIgnoreCase(status) || "Rejected".equalsIgnoreCase(status)) { %>
                                    <span style="color:#ef4444; font-weight:700; font-size:13px;">❌ Cancelled</span>
                                <% } else if ("Pending".equalsIgnoreCase(status) || "Pending Verification".equalsIgnoreCase(payStatus)) { %>
                                    <a href="ApproveServlet?id=<%= b_id %>&action=Approved" class="btn btn-approve">✅ Confirm Order & Payment</a>
                                    <a href="CancelBookingServlet?id=<%= b_id %>&redirect=OwnerBookings.jsp" class="btn btn-reject" onclick="return confirm('Are you sure you want to cancel this order?');">❌ Cancel</a>
                                <% } else if ("Approved".equalsIgnoreCase(status)) { %>
                                    <a href="ApproveServlet?id=<%= b_id %>&action=Returned" class="btn btn-approve" style="background:#10b981;">Mark Delivered</a>
                                    <a href="CancelBookingServlet?id=<%= b_id %>&redirect=OwnerBookings.jsp" class="btn btn-reject" onclick="return confirm('Are you sure you want to cancel this order?');">❌ Cancel</a>
                                <% } else { %>
                                    <span style="color:#10b981; font-weight:700; font-size:13px;">✓ Delivered</span>
                                <% } %>
                            </td>
                        </tr>
                    <% 
                            } 
                            if(!found){ 
                    %>
                        <tr>
                            <td colspan="7" style="text-align: center; color: #94a3b8; padding: 40px;">No customer orders found.</td>
                        </tr>
                    <% 
                            } 
                        } 
                    } catch(Exception e) { 
                    %>
                        <tr>
                            <td colspan="7" style="text-align: center; color: #ef4444; padding: 20px;">Error loading orders: <%= e.getMessage() %></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>