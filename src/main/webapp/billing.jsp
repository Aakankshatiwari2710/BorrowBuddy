<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page session="true" %>
        <% Integer userId=(Integer) session.getAttribute("userId"); if(userId==null){
            response.sendRedirect("login.jsp"); return; } String bookingId=request.getParameter("bookingId"); String
            amount=request.getParameter("amount"); if(bookingId==null || amount==null) {
            response.sendRedirect("myBookings.jsp"); return; } %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Secure Payment | BorrowBuddy</title>
                <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet">
                <style>
                    :root {
                        --primary: #0f766e;
                        --secondary: #14b8a6;
                        --bg: #f8fafc;
                        --text: #1e293b;
                    }

                    body {
                        margin: 0;
                        font-family: 'Outfit', sans-serif;
                        background: var(--bg);
                        color: var(--text);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        min-height: 100vh;
                    }

                    .checkout-container {
                        background: white;
                        width: 100%;
                        max-width: 450px;
                        border-radius: 24px;
                        padding: 40px;
                        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.06);
                        text-align: center;
                    }

                    h1 {
                        margin: 0 0 10px;
                        font-size: 24px;
                    }

                    p.subtitle {
                        color: #64748b;
                        margin-top: 0;
                        margin-bottom: 30px;
                    }

                    .amount-display {
                        background: #f0fdfa;
                        border-radius: 16px;
                        padding: 25px;
                        margin-bottom: 30px;
                        border: 1px solid #ccfbf1;
                    }

                    .amount-display h2 {
                        margin: 0;
                        font-size: 36px;
                        color: var(--primary);
                    }

                    .amount-display span {
                        font-size: 14px;
                        color: #0d9488;
                        font-weight: 600;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                    }

                    .form-group {
                        text-align: left;
                        margin-bottom: 20px;
                    }

                    .form-group label {
                        display: block;
                        font-size: 13px;
                        font-weight: 600;
                        color: #475569;
                        margin-bottom: 8px;
                    }

                    .form-group input {
                        width: 100%;
                        box-sizing: border-box;
                        padding: 12px 15px;
                        border-radius: 10px;
                        border: 1px solid #cbd5e1;
                        font-family: 'Outfit', sans-serif;
                        font-size: 15px;
                        transition: 0.3s;
                    }

                    .form-group input:focus {
                        border-color: var(--secondary);
                        outline: none;
                        box-shadow: 0 0 0 4px rgba(20, 184, 166, 0.1);
                    }

                    .row {
                        display: flex;
                        gap: 15px;
                    }

                    .row .form-group {
                        flex: 1;
                    }

                    .btn-pay {
                        width: 100%;
                        padding: 15px;
                        background: var(--primary);
                        color: white;
                        border: none;
                        border-radius: 12px;
                        font-size: 16px;
                        font-weight: 600;
                        font-family: 'Outfit', sans-serif;
                        cursor: pointer;
                        transition: 0.3s;
                        box-shadow: 0 4px 15px rgba(15, 118, 110, 0.2);
                        margin-top: 10px;
                    }

                    .btn-pay:hover {
                        background: var(--secondary);
                        transform: translateY(-2px);
                    }

                    .btn-pay:active {
                        transform: translateY(0);
                    }

                    .btn-cancel {
                        display: block;
                        margin-top: 20px;
                        color: #94a3b8;
                        text-decoration: none;
                        font-size: 14px;
                        font-weight: 500;
                        transition: 0.2s;
                    }

                    .btn-cancel:hover {
                        color: #ef4444;
                    }

                    .secure-badge {
                        margin-top: 25px;
                        font-size: 12px;
                        color: #94a3b8;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        gap: 5px;
                    }
                </style>
            </head>

            <body>
                <div class="checkout-container">
                    <h1>Secure Checkout</h1>
                    <p class="subtitle">Complete your payment to confirm your booking</p>

                    <div class="amount-display">
                        <span>Total Payable</span>
                        <h2>₹<%= amount %>
                        </h2>
                    </div>

                    <form action="<%= request.getContextPath() %>/ProcessPaymentServlet" method="post">
                        <input type="hidden" name="bookingId" value="<%= bookingId %>">
                        <input type="hidden" name="amount" value="<%= amount %>">

                        <div class="form-group">
                            <label>Cardholder Name</label>
                            <input type="text" name="cardName" placeholder="Dhiraj Yadav" required>
                        </div>

                        <div class="form-group">
                            <label>Card Number</label>
                            <input type="text" name="cardNumber" placeholder="XXXX XXXX XXXX XXXX" maxlength="19"
                                required>
                        </div>

                        <div class="row">
                            <div class="form-group">
                                <label>Expiry Date</label>
                                <input type="text" name="expiry" placeholder="MM/YY" maxlength="5" required>
                            </div>
                            <div class="form-group">
                                <label>CVV</label>
                                <input type="password" name="cvv" placeholder="•••" maxlength="3" required>
                            </div>
                        </div>

                        <button type="submit" class="btn-pay">Pay ₹<%= amount %> Now</button>
                    </form>

                    <a href="myBookings.jsp" class="btn-cancel">Cancel Payment</a>

                    <div class="secure-badge">
                        🔒 Payments are secure and encrypted
                    </div>
                </div>
            </body>

            </html>