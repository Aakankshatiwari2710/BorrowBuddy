<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Create Account | SpanV Studios</title>
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            :root {
                --primary: #db2777;
                --primary-hover: #be185d;
                --bg: #fff1f2;
            }

            body {
                font-family: 'Outfit', sans-serif;
                background-color: var(--bg);
                margin: 0;
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                background-image: radial-gradient(#cbd5e1 1px, transparent 1px);
                background-size: 24px 24px;
            }

            .signup-card {
                background: white;
                padding: 40px;
                border-radius: 24px;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.01);
                width: 100%;
                max-width: 480px;
                border: 1px solid #fbcfe8;
                text-align: center;
            }

            .logo {
                font-size: 24px;
                font-weight: 700;
                color: var(--primary);
                text-decoration: none;
                margin-bottom: 20px;
                display: inline-block;
            }

            h1 {
                font-size: 22px;
                color: #0f172a;
                margin: 0 0 8px 0;
            }

            p {
                color: #64748b;
                font-size: 14px;
                margin-bottom: 24px;
            }

            .input-grid {
                display: flex;
                flex-direction: column;
                gap: 16px;
                text-align: left;
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
                box-shadow: 0 0 0 3px rgba(219, 39, 119, 0.1);
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
               if(err != null && !err.isEmpty()) { 
                   String msg = err; 
                   if("duplicate_email".equals(err)) {
                       msg = "This email is already registered."; 
                   } else if("db_connection_failed".equals(err)) {
                       msg = "Database connection failed. Please ensure MySQL is running.";
                   }
            %>
                <div style="background: #fee2e2; color: #ef4444; padding: 12px; border-radius: 10px; margin-bottom: 20px; font-size: 13px; font-weight: 500; border: 1px solid #fecaca; text-align: left;">
                    ⚠️ <%= msg %>
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
                        <label>Date of Birth (DOB)</label>
                        <input type="date" name="dob" required>
                    </div>

                    <div class="input-group">
                        <label>Your Location</label>
                        <input type="text" name="location" placeholder="City or Street Name" required>
                    </div>

                    <div class="input-group">
                        <label>I want to...</label>
                        <select name="role" required>
                            <option value="" disabled selected>Select your primary role</option>
                            <option value="Customer">Shop &amp; Buy designs (Customer)</option>
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