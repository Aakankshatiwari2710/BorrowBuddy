<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page session="true" %>

<%
String role = (String) session.getAttribute("userRole");
if (role == null || !role.equalsIgnoreCase("Admin")) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Admin Dashboard</title>
</head>
<body>

<h2>Admin Panel</h2>

<a href="manageUsers.jsp">Manage Users</a><br><br>
<a href="manageItems.jsp">Manage Items</a><br><br>
<a href="LogoutServlet">Logout</a>

</body>
</html>
