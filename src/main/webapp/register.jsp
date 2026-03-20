<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sign Up | BorrowBuddy</title>
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
            <a href="home.jsp" class="logo">BorrowBuddy</a>
            <h1>Create Account</h1>
            <p>Join your local verified sharing community.</p>

            <form action="<%=request.getContextPath()%>/RegisterServlet" method="post">
                <div class="input-grid">
                    <div class="input-group">
                        <label>Full Name</label>
                        <input type="text" name="name" placeholder="Dhiraj Yadav" required>
                    </div>

                    <div class="input-group">
                        <label>Email Address</label>
                        <input type="email" name="email" placeholder="dhiraj@gmail.com" required>
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
                            <option value="Customer">Borrow items (Customer)</option>
                            <option value="Owner">Lend items (Owner)</option>
                        </select>
                    </div>
                </div>

                <button type="submit" class="signup-btn">Join BorrowBuddy</button>
            </form>

            <div class="footer-links">
                Already have an account? <a href="login.jsp">Log In</a>
            </div>
        </div>

    </body>

    </html>