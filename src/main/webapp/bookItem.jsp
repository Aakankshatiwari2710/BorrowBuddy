<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page session="true" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String itemId = request.getParameter("id");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Book Item</title>

<style>
body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #dfe8e8;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
}

.card {
    background: #ffffff;
    padding: 40px;
    width: 400px;
    border-radius: 12px;
    box-shadow: 0 8px 20px rgba(0,0,0,0.1);
}

h2 {
    text-align: center;
    margin-bottom: 25px;
    color: #1f7a73;
}

input[type="date"] {
    width: 100%;
    padding: 10px;
    margin: 8px 0 18px 0;
    border-radius: 8px;
    border: 1px solid #ccc;
    font-size: 14px;
}

button {
    width: 100%;
    padding: 12px;
    background: #1f7a73;
    border: none;
    color: white;
    font-size: 16px;
    border-radius: 8px;
    cursor: pointer;
}

button:hover {
    background: #16635d;
}
</style>
</head>

<body>

<div class="card">
    <h2>Book Item</h2>

    <form action="<%=request.getContextPath()%>/BookItemServlet" method="post">
        <input type="hidden" name="item_id" value="<%= itemId %>">

        <label>Start Date</label>
        <input type="date" name="start_date" required>

        <label>End Date</label>
        <input type="date" name="end_date" required>

        <button type="submit">Confirm Booking</button>
    </form>
</div>

</body>
</html>
