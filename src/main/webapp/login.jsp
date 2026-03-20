<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Login | BorrowBuddy</title>
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
            rel="stylesheet">


        <jsp:include page="layout/global_scripts.jsp" />
        <style>
            :root {
                --primary: #0f766e;
                --primary-hover: #115e59;
                --bg: #f1f5f9;
                --text: #1e293b;
                --card-bg: #ffffff;
            }

            body {
                margin: 0;
                font-family: 'Outfit', sans-serif;
                background-color: var(--bg);
                color: var(--text);
                display: flex;
                align-items: center;
                justify-content: center;
                height: 100vh;
            }

            .login-card {
                background: var(--card-bg);
                width: 100%;
                max-width: 400px;
                padding: 40px;
                border-radius: 25px;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
                text-align: center;
            }

            .logo {
                font-size: 28px;
                font-weight: 700;
                color: var(--primary);
                text-decoration: none;
                display: block;
                margin-bottom: 10px;
            }

            h1 {
                font-size: 24px;
                margin: 0;
                color: #1e293b;
            }

            p {
                color: #64748b;
                font-size: 14px;
                margin: 10px 0 30px;
            }

            .input-group {
                text-align: left;
                margin-bottom: 20px;
            }

            label {
                display: block;
                font-size: 14px;
                font-weight: 600;
                margin-bottom: 8px;
                color: #334155;
            }

            input {
                width: 100%;
                padding: 12px 15px;
                border-radius: 12px;
                border: 1px solid #e2e8f0;
                font-family: inherit;
                box-sizing: border-box;
                outline: none;
                transition: 0.3s;
            }

            input:focus {
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.1);
            }

            .login-btn {
                width: 100%;
                padding: 14px;
                background: var(--primary);
                color: white;
                border: none;
                border-radius: 12px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: 0.3s;
                margin-top: 10px;
            }

            .login-btn:hover {
                background: var(--primary-hover);
                transform: translateY(-2px);
            }

            .footer-links {
                margin-top: 25px;
                font-size: 14px;
                color: #64748b;
            }

            .footer-links a {
                color: var(--primary);
                text-decoration: none;
                font-weight: 600;
            }

            .error-msg {
                background: #fef2f2;
                color: #ef4444;
                padding: 10px;
                border-radius: 8px;
                margin-bottom: 20px;
                font-size: 13px;
            }
        </style>
    </head>

    <body>
        <div class="login-card">
            <a href="home.jsp" class="logo">BorrowBuddy</a>
            <h1>Welcome Back</h1>
            <p>Log in to access your neighborhood sharing circle.</p>
            <% String err=request.getParameter("error"); if(err !=null) { String
                msg="Login failed. Please check credentials." ; if("wrongpass".equals(err))
                msg="Incorrect password. Please try again." ; else if("notfound".equals(err))
                msg="Account not found with this email." ; else if("empty".equals(err)) msg="Please fill in all fields."
                ; %>
                <div class="error-msg">
                    <%= msg %>
                </div>
                <% } %>
                    <form action="<%=request.getContextPath()%>/LoginServlet" method="post">
                        <div class="input-group">
                            <label>Email Address</label>
                            <input type="email" name="email" placeholder="dhiraj@gmail.com" required>
                        </div>
                        <div class="input-group">
                            <label>Password</label>
                            <input type="password" name="password" placeholder="••••••••" required>
                        </div>
                        <button type="submit" class="login-btn">Log In</button>
                    </form>
                    <div class="footer-links">Don't have an account? <a href="register.jsp">Sign Up</a></div>
        </div>
    </body>

    </html>