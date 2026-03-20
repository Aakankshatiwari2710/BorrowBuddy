<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*" %>
        <%@ page import="util.DBConnection" %>
            <%@ page session="true" %>
                <% Integer userId=(Integer) session.getAttribute("userId"); String email=(String)
                    session.getAttribute("userEmail"); if(userId==null){ response.sendRedirect("login.jsp"); return; }
                    %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Owner Bookings | BorrowBuddy</title>
                        <link
                            href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
                            rel="stylesheet">
                        <style>
                            :root {
                                --primary: #0f766e;
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

                            .status-Approved {
                                background: #dcfce7;
                                color: #166534;
                            }

                            .status-Pending {
                                background: #fef3c7;
                                color: #92400e;
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

                            .btn-chat {
                                background: #3b82f6;
                                color: white;
                            }

                            .btn-approve {
                                background: var(--primary);
                                color: white;
                            }

                            .btn-reject {
                                background: #ef4444;
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
                    <h1>Owner Management</h1>
                    <p style="color: #64748b; margin-top: 5px;">Track your bookings and earnings.</p>
                </div>

                <% 
                   int totalBookings = 0;
                   double totalEarnings = 0;
                   int pendingCount = 0;
                   String topItem = "None";
                   int maxBookings = 0;
                   try (Connection conAn = DBConnection.getConnection();
                        PreparedStatement psAn = conAn.prepareStatement("SELECT i.name, COUNT(b.id) as b_cnt, SUM(CASE WHEN b.status='Approved' THEN i.price ELSE 0 END) as earn FROM bookings b JOIN items i ON b.item_id = i.id WHERE i.owner_email=? GROUP BY i.id, i.name")) {
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
                   
                   // Get pending count separately for accuracy
                   try (Connection conP = DBConnection.getConnection();
                        PreparedStatement psP = conP.prepareStatement("SELECT COUNT(*) FROM bookings b JOIN items i ON b.item_id = i.id WHERE i.owner_email=? AND b.status='Pending'")) {
                       psP.setString(1, email);
                       try(ResultSet rsP = psP.executeQuery()) { if(rsP.next()) pendingCount = rsP.getInt(1); }
                   } catch(Exception e) {}
                   
                   // Total approved bookings
                   try (Connection conA = DBConnection.getConnection();
                        PreparedStatement psA = conA.prepareStatement("SELECT COUNT(*) FROM bookings b JOIN items i ON b.item_id = i.id WHERE i.owner_email=? AND b.status='Approved'")) {
                       psA.setString(1, email);
                       try(ResultSet rsA = psA.executeQuery()) { if(rsA.next()) totalBookings = rsA.getInt(1); }
                   } catch(Exception e) {}
                %>

                <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px;">
                    <div style="background: white; padding: 25px; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-left: 5px solid #10b981;">
                        <span style="display: block; font-size: 13px; color: #64748b; font-weight: 700; text-transform: uppercase;">Total Earnings</span>
                        <span style="display: block; font-size: 28px; font-weight: 800; color: #1e293b; margin-top: 5px;">₹<%= (int)totalEarnings %></span>
                    </div>
                    <div style="background: white; padding: 25px; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-left: 5px solid #3b82f6;">
                        <span style="display: block; font-size: 13px; color: #64748b; font-weight: 700; text-transform: uppercase;">Active Bookings</span>
                        <span style="display: block; font-size: 28px; font-weight: 800; color: #1e293b; margin-top: 5px;"><%= totalBookings %></span>
                    </div>
                    <div style="background: white; padding: 25px; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-left: 5px solid #f59e0b;">
                        <span style="display: block; font-size: 13px; color: #64748b; font-weight: 700; text-transform: uppercase;">Pending Requests</span>
                        <span style="display: block; font-size: 28px; font-weight: 800; color: #1e293b; margin-top: 5px;"><%= pendingCount %></span>
                    </div>
                    <div style="background: white; padding: 25px; border-radius: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-left: 5px solid #8b5cf6;">
                        <span style="display: block; font-size: 13px; color: #64748b; font-weight: 700; text-transform: uppercase;">Top Performer</span>
                        <span style="display: block; font-size: 20px; font-weight: 800; color: #1e293b; margin-top: 5px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="<%= topItem %>"><%= topItem %></span>
                    </div>
                </div>

                            <div class="table-container">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Item Name</th>
                                            <th>Borrower ID</th>
                                            <th>Status</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% try (Connection con=DBConnection.getConnection(); PreparedStatement
                                            ps=con.prepareStatement( "SELECT b.id, b.item_id, b.status, b.borrower_id, i.name "
                                            + "FROM bookings b " + "JOIN items i ON b.item_id = i.id "
                                            + "WHERE i.owner_email=? ORDER BY b.id DESC" )) { ps.setString(1, email);
                                            try (ResultSet rs=ps.executeQuery()) { boolean found=false;
                                            while(rs.next()){ found=true; String status=rs.getString("status"); int
                                            b_id=rs.getInt("id"); int borrower_id=rs.getInt("borrower_id"); int
                                            item_id=rs.getInt("item_id"); %>
                                            <tr>
                                                <td>#<%=b_id%>
                                                </td>
                                                <td style="font-weight: 600;">
                                                    <%=rs.getString("name")%>
                                                </td>
                                                <td>UserID: <%=borrower_id%>
                                                </td>
                                                <td>
                                                    <span class="status-badge status-<%=status%>">
                                                        <%=status%>
                                                    </span>
                                                </td>
                                                <td>
                                                    <a href="chat.jsp?user=<%=borrower_id%>&item=<%=item_id%>"
                                                        class="btn btn-chat">💬 Chat</a>
                                                    <% if ("Pending".equalsIgnoreCase(status)) { %>
                                                        <a href="ApproveServlet?id=<%=b_id%>&action=Approved"
                                                            class="btn btn-approve">Approve</a>
                                                        <a href="ApproveServlet?id=<%=b_id%>&action=Rejected"
                                                            class="btn btn-reject">Reject</a>
                                                    <% } else if ("Approved".equalsIgnoreCase(status)) { %>
                                                        <a href="ApproveServlet?id=<%=b_id%>&action=Returned"
                                                            class="btn btn-approve" style="background:#10b981;">Mark Returned</a>
                                                    <% } %>
                                                </td>
                                            </tr>
                                            <% } if(!found){ %>
                                                <tr>
                                                    <td colspan="5"
                                                        style="text-align: center; color: #94a3b8; padding: 40px;">No
                                                        bookings found.</td>
                                                </tr>
                                                <% } } } catch(Exception e) { %>
                                                    <tr>
                                                        <td colspan="5"
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