<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String error = request.getParameter("error");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password | SpanV Studios</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #db2777;
            --secondary: #be185d;
            --bg: #fff1f2;
            --text: #2d0b1e;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: 'Outfit', sans-serif;
            background: linear-gradient(135deg, #fff1f2 0%, #ffe4e6 50%, #fbcfe8 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            color: var(--text);
        }

        .card {
            background: white;
            padding: 40px 35px;
            border-radius: 28px;
            box-shadow: 0 15px 40px rgba(219, 39, 119, 0.12);
            width: 100%;
            max-width: 440px;
            text-align: center;
            border: 1px solid #fbcfe8;
        }

        .logo-wrap {
            font-size: 32px;
            margin-bottom: 10px;
        }

        h2 {
            margin: 0 0 8px;
            font-size: 24px;
            font-weight: 800;
            color: var(--secondary);
        }

        p {
            color: #64748b;
            font-size: 14px;
            margin: 0 0 25px;
            line-height: 1.5;
        }

        .form-group {
            text-align: left;
            margin-bottom: 20px;
        }

        label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: #334155;
            margin-bottom: 6px;
        }

        input {
            width: 100%;
            padding: 13px 16px;
            border-radius: 12px;
            border: 2px solid #e2e8f0;
            font-family: inherit;
            font-size: 15px;
            outline: none;
            transition: 0.3s;
        }

        input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(219, 39, 119, 0.12);
        }

        .btn-submit {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 800;
            cursor: pointer;
            transition: 0.3s;
            box-shadow: 0 6px 20px rgba(219, 39, 119, 0.3);
            margin-top: 10px;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(219, 39, 119, 0.4);
        }

        .alert {
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 20px;
            text-align: left;
        }

        .alert-error { background: #fee2e2; color: #991b1b; }
        .alert-msg   { background: #dcfce7; color: #166534; }

        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: #64748b;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
        }

        .back-link:hover { color: var(--primary); }
    </style>
</head>
<body>

    <div class="card">
        <div class="logo-wrap">🔑</div>
        <h2>Forgot Password?</h2>
        <p>Enter your registered email address to receive a 6-digit password reset OTP code.</p>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-error">⚠️ <%= error %></div>
        <% } %>

        <% if (msg != null && !msg.isEmpty()) { %>
            <div class="alert alert-msg">✅ <%= msg %></div>
        <% } %>

        <form action="ForgotPasswordServlet" method="post">
            <div class="form-group">
                <label>Email Address</label>
                <input type="email" name="email" placeholder="spandanav2606@gmail.com" required>
            </div>

            <button type="submit" class="btn-submit">📩 Send Password Reset OTP</button>
        </form>

        <a href="login.jsp" class="back-link">← Back to Login</a>
    </div>

</body>
</html>
