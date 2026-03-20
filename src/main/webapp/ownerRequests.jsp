<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userEmail = (String) session.getAttribute("userEmail");
    if (userId == null || userEmail == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Requests | BorrowBuddy</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #0f766e; --secondary: #14b8a6; --bg: #f8fafc; --text: #1e293b; }
        body { margin: 0; font-family: 'Outfit', sans-serif; background: var(--bg); color: var(--text); }
        .main-content { margin-left: 260px; padding: 40px; }
        .header { margin-bottom: 30px; }
        .header h1 { font-size: 28px; margin: 0; color: var(--primary); }
        .header p { color: #64748b; margin-top: 6px; }
        .table-container { background: white; border-radius: 20px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8fafc; padding: 14px 18px; text-align: left; font-size: 12px; color: #64748b; font-weight: 700; border-bottom: 1px solid #f1f5f9; text-transform: uppercase; letter-spacing: 0.5px; }
        td { padding: 14px 18px; border-bottom: 1px solid #f1f5f9; font-size: 14px; vertical-align: middle; }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f8fafc; }
        .status-badge { padding: 5px 14px; border-radius: 50px; font-size: 12px; font-weight: 600; }
        .status-Pending  { background: #fef3c7; color: #92400e; }
        .status-Approved { background: #dcfce7; color: #166534; }
        .status-Rejected { background: #fee2e2; color: #991b1b; }
        .pay-badge { display: inline-block; margin-left: 6px; font-size: 11px; font-weight: 700; padding: 3px 8px; border-radius: 4px; }
        .pay-paid   { background: #d1fae5; color: #065f46; }
        .pay-unpaid { background: #fef9c3; color: #854d0e; }
        .btn { display: inline-block; padding: 7px 14px; border-radius: 8px; text-decoration: none; font-size: 13px; font-weight: 600; transition: 0.25s; margin-right: 4px; cursor: pointer; border: none; white-space: nowrap; }
        .btn:hover { transform: translateY(-1px); box-shadow: 0 4px 10px rgba(0,0,0,0.12); }
        .btn-approve { background: var(--primary); color: white; }
        .btn-reject  { background: #ef4444; color: white; }
        .btn-chat    { background: #3b82f6; color: white; }
        .empty-state { text-align: center; padding: 60px 20px; color: #94a3b8; }
        .empty-state p { font-size: 16px; }
    </style>
</head>
<body>
    <jsp:include page="layout/sidebar.jsp" />
    <div class="main-content">
        <div class="header">
            <h1>Borrowing Requests</h1>
            <p>Manage people who want to rent your items.</p>
        </div>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Item</th>
                        <th>Borrower</th>
                        <th>Email</th>
                        <th>Duration</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
<%
    Connection con = null;
    try {
        con = DBConnection.getConnection();
        String query = "SELECT b.id, b.borrower_id, b.item_id, i.name AS item_name, " +
            "u.name AS borrower_name, u.email, b.start_date, b.end_date, b.status, b.payment_status " +
            "FROM bookings b JOIN items i ON b.item_id = i.id JOIN users u ON b.borrower_id = u.id " +
            "WHERE i.owner_email = ? ORDER BY b.id DESC";
        PreparedStatement ps = con.prepareStatement(query);
        ps.setString(1, userEmail);
        ResultSet rs = ps.executeQuery();
        boolean found = false;
        while (rs.next()) {
            found = true;
            String status     = rs.getString("status");
            String payStatus  = rs.getString("payment_status");
            if (payStatus == null) payStatus = "Unpaid";
            int    bId        = rs.getInt("id");
            int    borrowerId = rs.getInt("borrower_id");
            int    itemId     = rs.getInt("item_id");
            boolean isPaid    = "Paid".equalsIgnoreCase(payStatus);
%>
                    <tr>
                        <td style="font-weight:600;"><%= rs.getString("item_name") %></td>
                        <td><%= rs.getString("borrower_name") %></td>
                        <td style="color:#64748b;"><%= rs.getString("email") %></td>
                        <td style="font-size:13px;color:#475569;">
                            <%= rs.getString("start_date") != null ? rs.getString("start_date") : "-" %>
                            <br>&#10132; <%= rs.getString("end_date") != null ? rs.getString("end_date") : "-" %>
                        </td>
                        <td>
                            <span class="status-badge status-<%= status %>"><%= status %></span>
                            <span class="pay-badge <%= isPaid ? "pay-paid" : "pay-unpaid" %>"><%= isPaid ? "PAID" : "UNPAID" %></span>
                        </td>
                        <td>
                            <a href="chat.jsp?user=<%= borrowerId %>&item=<%= itemId %>" class="btn btn-chat">Chat</a>
                            <% if ("Pending".equalsIgnoreCase(status)) { %>
                            <a href="ApproveServlet?id=<%= bId %>&action=Approved" class="btn btn-approve">Approve</a>
                            <a href="ApproveServlet?id=<%= bId %>&action=Rejected" class="btn btn-reject">Reject</a>
                            <% } %>
                        </td>
                    </tr>
<%
        }
        if (!found) { %>
                    <tr><td colspan="6"><div class="empty-state"><p>No booking requests yet.</p></div></td></tr>
<%      }
        rs.close(); ps.close();
    } catch (Exception e) { %>
                    <tr><td colspan="6" style="text-align:center;color:#ef4444;padding:20px;">Error: <%= e.getMessage() %></td></tr>
<%  } finally { try { if (con != null) con.close(); } catch(Exception e){} } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>