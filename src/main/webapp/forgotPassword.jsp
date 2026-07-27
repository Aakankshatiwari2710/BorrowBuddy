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
    <title>Reset Password via DOB | SpanV Studios</title>
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
            max-width: 460px;
            text-align: center;
            border: 1px solid #fbcfe8;
        }

        .logo-wrap {
            font-size: 36px;
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
            margin-bottom: 16px;
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
            padding: 12px 16px;
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

        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .alert-msg   { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }

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
        <div class="logo-wrap">🔐</div>
        <h2>Reset Password</h2>
        <p>Verify your Email &amp; Date of Birth (DOB) to create a new password instantly.</p>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-error">⚠️ <%= error %></div>
        <% } %>

        <% if (msg != null && !msg.isEmpty()) { %>
            <div class="alert alert-msg">✅ <%= msg %></div>
        <% } %>

        <form action="<%=request.getContextPath()%>/ForgotPasswordServlet" method="post" id="resetForm" onsubmit="return validateForm()">
            <div class="form-group">
                <label>Registered Email Address</label>
                <input type="email" name="email" placeholder="e.g. sakshitiwari0627@gmail.com" required>
            </div>

            <div class="form-group">
                <label>Date of Birth (DOB)</label>
                <input type="date" name="dob" required>
            </div>

            <div class="form-group">
                <label>New Password</label>
                <input type="password" name="newPassword" id="newPassword" placeholder="At least 6 characters" required>
            </div>

            <div class="form-group">
                <label>Confirm New Password</label>
                <input type="password" name="confirmPassword" id="confirmPassword" placeholder="Repeat new password" required>
            </div>

            <button type="submit" class="btn-submit">✨ Update Password &amp; Login</button>
        </form>

        <a href="login.jsp" class="back-link">← Back to Login</a>
    </div>

    <script>
        function validateForm() {
            var pass = document.getElementById("newPassword").value;
            var confirm = document.getElementById("confirmPassword").value;
            if (pass !== confirm) {
                alert("Passwords do not match! Please check and try again.");
                return false;
            }
            if (pass.length < 6) {
                alert("Password must be at least 6 characters long.");
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
