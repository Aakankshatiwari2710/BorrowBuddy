<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String resetEmail = (String) session.getAttribute("resetEmail");
    if (resetEmail == null || resetEmail.isEmpty()) {
        response.sendRedirect("forgotPassword.jsp");
        return;
    }
    String error = request.getParameter("error");
    String msg = request.getParameter("msg");

    String activeOtp = "";
    try (java.sql.Connection con = util.DBConnection.getConnection();
         java.sql.PreparedStatement ps = con.prepareStatement("SELECT otp_code FROM users WHERE email=?")) {
        ps.setString(1, resetEmail);
        try (java.sql.ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                activeOtp = rs.getString("otp_code");
            }
        }
    } catch(Exception e) {}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Set New Password | SpanV Studios</title>
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
            max-width: 450px;
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

        .sub-text {
            color: #64748b;
            font-size: 14px;
            margin: 0 0 20px;
        }

        .email-badge {
            display: inline-block;
            background: #fdf2f8;
            color: var(--secondary);
            font-weight: 700;
            font-size: 13px;
            padding: 6px 14px;
            border-radius: 50px;
            border: 1px solid #fbcfe8;
            margin-bottom: 20px;
        }

        .form-group {
            text-align: left;
            margin-bottom: 18px;
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
            padding: 15px;
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
    </style>
</head>
<body>

    <div class="card">
        <div class="logo-wrap">🔐</div>
        <h2>Reset Your Password</h2>
        <p class="sub-text">Enter the 6-digit OTP code sent to your email and your new password.</p>

        <div class="email-badge">📧 <%= resetEmail %></div>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-error">⚠️ <%= error %></div>
        <% } %>

        <% if (msg != null && !msg.isEmpty()) { %>
            <div class="alert alert-msg">✅ <%= msg %></div>
        <% } %>

        <form action="ResetPasswordServlet" method="post">
            <div class="form-group">
                <label>6-Digit OTP Code</label>
                <input type="text" name="otp" placeholder="e.g. 849201" maxlength="6" required style="font-size:18px; font-weight:700; letter-spacing:4px; text-align:center;">
            </div>

            <div class="form-group">
                <label>New Password</label>
                <input type="password" name="newPassword" placeholder="At least 6 characters" required>
            </div>

            <div class="form-group">
                <label>Confirm New Password</label>
                <input type="password" name="confirmPassword" placeholder="Re-enter new password" required>
            </div>

            <button type="submit" class="btn-submit">✨ Reset Password &amp; Log In</button>
        </form>
    </div>

</body>
</html>
