<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*" %>
        <%@ page import="util.DBConnection" %>
            <%@ page session="true" %>
                <% Integer userId=(Integer) session.getAttribute("userId"); String userEmail=(String)
                    session.getAttribute("userEmail"); if (userId==null || userEmail==null) {
                    response.sendRedirect("login.jsp"); return; } %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Booking Requests | BorrowBuddy</title>
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
                            }

                            .header h1 {
                                font-size: 28px;
                                margin: 0;
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

                            .status-badge {
                                padding: 4px 12px;
                                border-radius: 50px;
                                font-size: 12px;
                                font-weight: 600;
                            }

                            .status-Pending {
                                background: #fef3c7;
                                color: #92400e;
                            }

                            .status-Approved {
                                background: #dcfce7;
                                color: #166534;
                            }

                            .status-Rejected {
                                background: #fee2e2;
                                color: #991b1b;
                            }

                            .btn {
                                display: inline-block;
                                padding: 8px 15px;
                                border-radius: 8px;
                                text-decoration: none;
                                font-size: 13px;
                                font-weight: 600;
                                transition: 0.3s;
                                margin-right: 5px;
                            }

                            .btn-approve {
                                background: var(--primary);
                                color: white;
                            }

                            .btn-reject {
                                background: #ef4444;
                                color: white;
                            }

                            .btn-chat {
                                background: #3b82f6;
                                color: white;
                            }

                            .btn:hover {
                                transform: translateY(-1px);
                                box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
                            }
                        </style>
                    </head>

                    <body>

                        <jsp:include page="layout/sidebar.jsp" />

                        <div class="main-content">
                            <div class="header">
                                <h1>Borrowing Requests</h1>
                                <p style="color: #64748b;">Manage people who want to rent your items.</p>
                            </div>

                            <div class="table-container">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Item</th>
                                            <th>Borrower</th>
                                            <th>Email</th>
                                            <th>Dates</th>
                                            <th>Status</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% try (Connection con=DBConnection.getConnection(); PreparedStatement
                                            ps=con.prepareStatement( "SELECT b.id, b.borrower_id, b.item_id, i.name AS item_name, "
                                            + "u.name AS borrower_name, u.email, u.location, "
                                            + "b.start_date, b.end_date, b.status FROM bookings b "
                                            + "JOIN items i ON b.item_id = i.id JOIN users u ON b.borrower_id = u.id "
                                            + "WHERE i.owner_email = ? ORDER BY b.id DESC" )) { ps.setString(1,
                                            userEmail); try (ResultSet rs=ps.executeQuery()) { boolean found=false;
                                            while(rs.next()){ found=true; String status=rs.getString("status"); int
                                            b_id=rs.getInt("id"); int borrower_id=rs.getInt("borrower_id"); int
                                            item_id=rs.getInt("item_id"); %>
                                            <tr>
                                                <td style="font-weight: 600;">
                                                    <%=rs.getString("item_name")%>
                                                </td>
                                                <td>
                                                    <%=rs.getString("borrower_name")%>
                                                </td>
                                                <td style="color: #64748b;">
                                                    <%=rs.getString("email")%>
                                                </td>
                                                <td style="font-size: 13px;">
                                                    <%=rs.getDate("start_date")%> to <%=rs.getDate("end_date")%>
                                                </td>
                                                <td>
                                                    <span class="status-badge status-<%=status%>">
                                                        <%=status%>
                                                    </span>
                                                </td>
                                                <td>
                                                    <a href="chat.jsp?user=<%=borrower_id%>&item=<%=item_id%>"
                                                        class="btn btn-chat">Chat</a>
                                                    <% if ("Pending".equalsIgnoreCase(status)) { %>
                                                        <a href="ApproveServlet?id=<%=b_id%>&action=Approved"
                                                            class="btn btn-approve">Approve</a>
                                                        <a href="ApproveServlet?id=<%=b_id%>&action=Rejected"
                                                            class="btn btn-reject">Reject</a>
                                                        <% } %>
                                                </td>
                                            </tr>
                                            <% } if(!found){ %>
                                                <tr>
                                                    <td colspan="6"
                                                        style="text-align: center; color: #94a3b8; padding: 40px;">No
                                                        requests found.</td>
                                                </tr>
                                                <% } } } catch(Exception e) { %>
                                                    <tr>
                                                        <td colspan="6"
                                                            style="text-align: center; color: #ef4444; padding: 20px;">
                                                            Error: <%=e.getMessage()%>
                                                        </td>
                                                    </tr>
                                                    <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </body>

                    </html>