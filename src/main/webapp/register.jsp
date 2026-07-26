<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Clear any previous leftover session when visiting register page
    if (session.getAttribute("userId") != null) {
        session.invalidate();
        session = request.getSession(true);
    }
%>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sign Up | SpanV Studios</title>
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
            rel="stylesheet">


        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>✨</text></svg>">
        <jsp:include page="layout/global_scripts.jsp" />
        <style>
            :root {
                --primary: #db2777;
                --primary-hover: #be185d;
                --bg: #fff1f2;
                --text: #2d0b1e;
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
                min-height: 100vh;
                padding: 20px;
            }

            .signup-card {
                background: var(--card-bg);
                width: 100%;
                max-width: 450px;
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
                margin-bottom: 5px;
            }

            h1 {
                font-size: 24px;
                margin: 0;
                color: #1e293b;
            }

            p {
                color: #64748b;
                font-size: 14px;
                margin: 10px 0 25px;
            }

            .input-grid {
                text-align: left;
                display: grid;
                grid-template-columns: 1fr;
                gap: 15px;
            }

            .input-group label {
                display: block;
                font-size: 13px;
                font-weight: 600;
                margin-bottom: 6px;
                color: #334155;
            }

            input,
            select {
                width: 100%;
                padding: 12px 15px;
                border-radius: 12px;
                border: 1px solid #e2e8f0;
                font-family: inherit;
                box-sizing: border-box;
                outline: none;
                transition: 0.3s;
            }

            input:focus,
            select:focus {
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.1);
            }

            .signup-btn {
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
                margin-top: 20px;
            }

            .signup-btn:hover {
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
        </style>
    </head>

    <body>

        <div class="signup-card">
            <a href="home.jsp" class="logo">✨ SpanV Studios</a>
            <h1>Create Account</h1>
            <p>Join our premium boutique shopping community.</p>

            <% String err = request.getParameter("error"); 
               if(err != null) { 
                   String msg = "Registration failed. Please try again."; 
                   if("duplicate_email".equals(err)) {
                       msg = "This email is already registered."; 
                   } else if("db_connection_failed".equals(err)) {
                       msg = "Database connection failed. Please ensure MySQL is running.";
                   } else if("server_error".equals(err)) {
                       msg = "Server error occurred. Please try again.";
                   }
            %>
                <div style="background: #fee2e2; color: #ef4444; padding: 10px; border-radius: 8px; margin-bottom: 20px; font-size: 13px; font-weight: 500;">
                    <%= msg %>
                </div>
            <% } %>

            <form action="<%=request.getContextPath()%>/RegisterServlet" method="post">
                <div class="input-grid">
                    <div class="input-group">
                        <label>Full Name</label>
                        <input type="text" name="name" placeholder="SpanV Customer" required>
                    </div>

                    <div class="input-group">
                        <label>Email Address</label>
                        <input type="email" name="email" placeholder="spandanav2606@gmail.com" required>
                    </div>

                    <div class="input-group">
                        <label>Password</label>
                        <input type="password" name="password" placeholder="At least 6 characters" required>
                    </div>

                    <div class="input-group">
                        <label>Your Location</label>
                        <input type="text" name="location" placeholder="City or Street Name" required>
                    </div>

                    <div class="input-group">
                        <label>I want to...</label>
                        <select name="role" required>
                            <option value="" disabled selected>Select your primary role</option>
                            <option value="Customer">Shop & Buy designs (Customer)</option>
                            <option value="Owner">Sell boutique designs (Owner)</option>
                        </select>
                    </div>
                </div>

                <button type="submit" class="signup-btn">Join SpanV Studios</button>
            </form>

            <div class="footer-links">
                Already have an account? <a href="login.jsp">Log In</a>
            </div>
        </div>

    </body>

    </html>