<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%
    String userEmail = (String) session.getAttribute("pending_email");
    if (userEmail == null || userEmail.isEmpty()) {
        userEmail = (String) session.getAttribute("userEmail");
    }
    if (userEmail == null || userEmail.isEmpty()) {
        response.sendRedirect("register.jsp");
        return;
    }
    String error = request.getParameter("error");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Verification (OTP) | SpanV Studios</title>
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

        .otp-card {
            background: white;
            padding: 40px 35px;
            border-radius: 28px;
            box-shadow: 0 15px 40px rgba(219, 39, 119, 0.12);
            width: 100%;
            max-width: 460px;
            text-align: center;
            border: 1px solid #fbcfe8;
            position: relative;
            overflow: hidden;
        }

        .logo-wrap {
            width: 70px;
            height: 70px;
            background: #fdf2f8;
            border: 2px solid #fbcfe8;
            border-radius: 50%;
            margin: 0 auto 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
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
            line-height: 1.5;
            margin-bottom: 25px;
        }

        .user-email-badge {
            display: inline-block;
            background: #fdf2f8;
            color: var(--secondary);
            font-weight: 700;
            font-size: 13px;
            padding: 6px 14px;
            border-radius: 50px;
            border: 1px solid #fbcfe8;
            margin-bottom: 25px;
            word-break: break-all;
        }

        .otp-inputs {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-bottom: 25px;
        }

        .otp-box {
            width: 50px;
            height: 58px;
            border: 2px solid #cbd5e1;
            border-radius: 14px;
            font-size: 24px;
            font-weight: 800;
            text-align: center;
            color: var(--secondary);
            outline: none;
            transition: all 0.25s;
            background: #f8fafc;
        }

        .otp-box:focus {
            border-color: var(--primary);
            background: white;
            box-shadow: 0 0 0 4px rgba(219, 39, 119, 0.15);
            transform: translateY(-2px);
        }

        .btn-verify {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            border: none;
            border-radius: 14px;
            font-size: 16px;
            font-weight: 800;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 6px 20px rgba(219, 39, 119, 0.3);
            margin-bottom: 20px;
        }

        .btn-verify:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(219, 39, 119, 0.4);
        }

        .resend-wrap {
            font-size: 14px;
            color: #64748b;
        }

        .resend-link {
            color: var(--primary);
            font-weight: 700;
            text-decoration: none;
            transition: 0.2s;
        }

        .resend-link:hover { text-decoration: underline; }

        .alert-banner {
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 20px;
            text-align: left;
        }

        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .alert-msg   { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
    </style>
</head>
<body>

    <div class="otp-card">
        <div class="logo-wrap">🔐</div>
        <h2>Verify Email OTP</h2>
        <p class="sub-text">We have sent a 6-digit OTP verification code to your email inbox.</p>
        
        <div class="user-email-badge">📧 <%= userEmail %></div>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-banner alert-error">⚠️ <%= error %></div>
        <% } %>

        <% if (msg != null && !msg.isEmpty()) { %>
            <div class="alert-banner alert-msg">✅ <%= msg %></div>
        <% } %>

        <form action="VerifyOtpServlet" method="post" id="otpForm">
            <div class="otp-inputs">
                <input type="text" name="otp1" class="otp-box" maxlength="1" autofocus onkeyup="moveNext(this, 'otp2')" onkeydown="moveBack(event, this, '')">
                <input type="text" name="otp2" id="otp2" class="otp-box" maxlength="1" onkeyup="moveNext(this, 'otp3')" onkeydown="moveBack(event, this, 'otp1')">
                <input type="text" name="otp3" id="otp3" class="otp-box" maxlength="1" onkeyup="moveNext(this, 'otp4')" onkeydown="moveBack(event, this, 'otp2')">
                <input type="text" name="otp4" id="otp4" class="otp-box" maxlength="1" onkeyup="moveNext(this, 'otp5')" onkeydown="moveBack(event, this, 'otp3')">
                <input type="text" name="otp5" id="otp5" class="otp-box" maxlength="1" onkeyup="moveNext(this, 'otp6')" onkeydown="moveBack(event, this, 'otp4')">
                <input type="text" name="otp6" id="otp6" class="otp-box" maxlength="1" onkeyup="moveNext(this, '')" onkeydown="moveBack(event, this, 'otp5')">
            </div>

            <button type="submit" class="btn-verify">✨ Verify &amp; Activate Account</button>
        </form>

        <div class="resend-wrap">
            Didn't receive the OTP email? 
            <a href="ResendOtpServlet" class="resend-link" id="resendBtn">Resend New OTP Code</a>
        </div>
    </div>

    <script>
        function moveNext(current, nextId) {
            if (current.value.length >= 1 && nextId !== '') {
                document.getElementById(nextId).focus();
            }
        }

        function moveBack(event, current, prevId) {
            if (event.key === "Backspace" && current.value.length === 0 && prevId !== '') {
                document.getElementById(prevId).focus();
            }
        }
    </script>
</body>
</html>
