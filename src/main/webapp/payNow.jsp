<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, util.DBConnection" %>
<%@ page session="true" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String bookingIdStr = request.getParameter("bookingId");
    if (bookingIdStr == null || bookingIdStr.isEmpty()) {
        response.sendRedirect("myBookings.jsp");
        return;
    }

    int bookingId = Integer.parseInt(bookingIdStr);
    String itemName = "";
    String itemImg = "default.png";
    double itemPrice = 0.0;
    String ownerEmail = "";
    String payStatus = "Unpaid";

    String shipAddress = "";
    String shipCity = "";
    String shipPincode = "";
    String shipPhone = "";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT b.id, b.payment_status, b.shipping_address, b.shipping_city, b.shipping_pincode, b.shipping_phone, i.name, i.image, i.price, i.owner_email " +
             "FROM bookings b JOIN items i ON b.item_id = i.id WHERE b.id = ? AND b.borrower_id = ?")) {
        ps.setInt(1, bookingId);
        ps.setInt(2, userId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                itemName = rs.getString("name");
                itemImg = rs.getString("image") != null ? rs.getString("image") : "default.png";
                itemPrice = rs.getDouble("price");
                ownerEmail = rs.getString("owner_email");
                payStatus = rs.getString("payment_status") != null ? rs.getString("payment_status") : "Unpaid";
                shipAddress = rs.getString("shipping_address") != null ? rs.getString("shipping_address") : "";
                shipCity = rs.getString("shipping_city") != null ? rs.getString("shipping_city") : "";
                shipPincode = rs.getString("shipping_pincode") != null ? rs.getString("shipping_pincode") : "";
                shipPhone = rs.getString("shipping_phone") != null ? rs.getString("shipping_phone") : "";
            } else {
                response.sendRedirect("myBookings.jsp");
                return;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UPI Payment | SpanV Studios</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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
            background: var(--bg);
            color: var(--text);
        }

        .main-content {
            margin-left: 260px;
            padding: 40px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 85vh;
        }

        .pay-card {
            background: var(--card-bg);
            border-radius: 24px;
            padding: 40px;
            max-width: 520px;
            width: 100%;
            box-shadow: 0 15px 35px rgba(219, 39, 119, 0.08);
            border: 1px solid #fbcfe8;
            text-align: center;
        }

        .pay-card h1 {
            font-size: 26px;
            margin: 0 0 10px;
            color: var(--primary);
        }

        .sub-title {
            color: #64748b;
            font-size: 14px;
            margin-bottom: 25px;
        }

        .item-summary {
            display: flex;
            align-items: center;
            gap: 15px;
            background: #fff1f2;
            padding: 15px;
            border-radius: 16px;
            margin-bottom: 25px;
            text-align: left;
        }

        .item-summary img {
            width: 65px;
            height: 65px;
            border-radius: 12px;
            object-fit: cover;
        }

        .item-details h3 {
            margin: 0 0 4px;
            font-size: 16px;
        }

        .item-details p {
            margin: 0;
            font-size: 18px;
            font-weight: 800;
            color: var(--primary);
        }

        .qr-wrapper {
            background: #ffffff;
            padding: 20px;
            border-radius: 20px;
            border: 2px dashed #fbcfe8;
            display: inline-block;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.04);
        }

        .qr-wrapper img {
            width: 220px;
            height: 220px;
            border-radius: 12px;
            display: block;
        }

        .upi-name {
            font-size: 15px;
            font-weight: 700;
            color: #2d0b1e;
            margin-top: 10px;
        }

        .contact-info-box {
            background: #f8fafc;
            border-radius: 14px;
            padding: 15px;
            margin-bottom: 25px;
            font-size: 13px;
            text-align: left;
            border: 1px solid #e2e8f0;
        }

        .contact-info-box div {
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .contact-info-box div:last-child {
            margin-bottom: 0;
        }

        .contact-info-box a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }

        .input-group {
            text-align: left;
            margin-bottom: 20px;
        }

        .input-group label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 8px;
            color: #475569;
        }

        .input-group input {
            width: 100%;
            padding: 14px;
            border-radius: 12px;
            border: 1.5px solid #cbd5e1;
            font-family: inherit;
            font-size: 15px;
            box-sizing: border-box;
            outline: none;
            transition: 0.3s;
        }

        .input-group input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(219, 39, 119, 0.15);
        }

        .btn-confirm {
            width: 100%;
            padding: 15px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 14px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: 0.3s;
            box-shadow: 0 4px 15px rgba(219, 39, 119, 0.3);
        }

        .btn-confirm:hover {
            background: var(--primary-hover);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <jsp:include page="layout/sidebar.jsp" />
    <div class="main-content">
        <div class="pay-card">
            <h1>✨ Scan & Pay via UPI</h1>
            <p class="sub-title">Scan the QR code using PhonePe, Google Pay, or Paytm to complete your boutique order.</p>

            <div class="item-summary" style="background:#fdf2f8; border:1px solid #fbcfe8; padding:18px; border-radius:16px; margin-bottom:20px; display:flex; align-items:center; gap:15px; text-align:left;">
                <img src="<%=request.getContextPath()%>/images/<%=itemImg%>" onerror="this.src='<%=request.getContextPath()%>/images/default.png'" style="width:70px; height:70px; object-fit:cover; border-radius:12px;">
                <div class="item-details" style="flex:1;">
                    <h3 style="margin:0 0 5px; font-size:18px; color:#be185d;"><%= itemName %></h3>
                    <div style="display:flex; align-items:center; gap:10px;">
                        <span style="font-size:16px; font-weight:800; color:#0f172a;">Exact Price: ₹<%= (int)itemPrice %></span>
                        <span style="background:#dcfce7; color:#15803d; font-size:11px; font-weight:800; padding:4px 8px; border-radius:50px;">🔒 Locked Amount</span>
                    </div>
                </div>
            </div>

            <% 
                String upiString = "upi://pay?pa=7899978229@ybl&pn=SpanV%20Studios&am=" + (int)itemPrice + "&cu=INR&tn=Order%20Payment%20" + bookingId;
                String qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=260x260&data=" + java.net.URLEncoder.encode(upiString, "UTF-8");
            %>

            <div id="qrContainer" style="display: none; margin-bottom: 20px;">
                <div class="qr-wrapper" style="background:white; padding:20px; border-radius:20px; border:2px solid #7c3aed; display:inline-block; box-shadow:0 10px 25px rgba(124, 58, 237, 0.15);">
                    <img id="upiQrImg" src="<%= qrUrl %>" alt="Exact ₹<%= (int)itemPrice %> UPI QR Code" style="width:220px; height:220px; border-radius:10px;">
                    <div class="upi-name" style="font-weight:800; color:#0f172a; margin-top:10px;">Account Name: SPANDANA V</div>
                    <div style="font-size:13px; color:#7c3aed; font-weight:700; margin-top:4px;">UPI ID: 7899978229@ybl</div>
                    <div style="font-size:12px; color:#059669; font-weight:700; background:#e6f4ea; padding:6px 12px; border-radius:6px; margin-top:8px;">🔒 Scanned Amount Locked to Exactly ₹<%= (int)itemPrice %></div>
                </div>
            </div>

            <script src="https://checkout.razorpay.com/v1/checkout.js"></script>

            <a href="<%= upiString %>" style="display:block; text-decoration:none; width:100%; padding:14px; background:#059669; color:white; border-radius:14px; font-weight:700; font-size:15px; text-align:center; margin-bottom:12px; transition:0.3s; box-shadow: 0 4px 12px rgba(5, 150, 105, 0.2); box-sizing:border-box;">
                📲 Pay Exact ₹<%= (int)itemPrice %> via GPay / PhonePe App
            </a>

            <button type="button" onclick="payWithRazorpay()" style="width:100%; padding:14px; background:#2563eb; color:white; border:none; border-radius:14px; font-weight:700; font-size:15px; cursor:pointer; margin-bottom:12px; transition:0.3s; box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);">
                💳 Pay Exact ₹<%= (int)itemPrice %> via Razorpay (Cards / NetBanking / UPI)
            </button>

            <button type="button" id="btnGenQr" onclick="generateQr()" style="width:100%; padding:14px; background:#7c3aed; color:white; border:none; border-radius:14px; font-weight:700; font-size:15px; cursor:pointer; margin-bottom:20px; transition:0.3s;">
                📱 Show Locked UPI QR Code (₹<%= (int)itemPrice %>)
            </button>

            <script>
                function generateQr() {
                    document.getElementById('qrContainer').style.display = 'block';
                    var btn = document.getElementById('btnGenQr');
                    btn.style.background = '#059669';
                    btn.innerHTML = '✅ QR Code Displayed (Amount Locked to ₹<%= (int)itemPrice %>)';
                }

                function payWithRazorpay() {
                    var options = {
                        "key": "rzp_test_spanv_studios",
                        "amount": "<%= (int)(itemPrice * 100) %>",
                        "currency": "INR",
                        "name": "SpanV Studios",
                        "description": "Payment for <%= itemName %>",
                        "image": "<%=request.getContextPath()%>/images/spanv_logo.jpg",
                        "handler": function (response){
                            alert("✅ Razorpay Payment Successful!\nPayment ID: " + response.razorpay_payment_id);
                            var utrInput = document.querySelector('input[name="payment_ref"]');
                            if(utrInput) {
                                utrInput.value = "RZP-" + response.razorpay_payment_id;
                                var form = utrInput.closest('form');
                                if(form) form.submit();
                            }
                        },
                        "prefill": {
                            "name": "<%= session.getAttribute("userName") %>",
                            "email": "<%= session.getAttribute("userEmail") %>"
                        },
                        "theme": { "color": "#be185d" }
                    };
                    var rzp1 = new Razorpay(options);
                    rzp1.open();
                }
            </script>

            <div class="contact-info-box">
                <div><span><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:middle; margin-right:4px; color:#e1306c;"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line></svg> Instagram:</span> <a href="https://www.instagram.com/spanv_studios/" target="_blank">@spanv_studios</a></div>
                <div><span>✉️ Email:</span> <a href="mailto:spandanav2606@gmail.com">spandanav2606@gmail.com</a></div>
                <div><span>📞 Phone / UPI:</span> <a href="tel:7899978229">+91 7899978229 (7899978229@ybl)</a></div>
            </div>

            <% if ("Paid".equalsIgnoreCase(payStatus)) { %>
                <div style="background:#dcfce7; color:#166534; padding:15px; border-radius:12px; font-weight:700;">
                    ✓ Payment Completed & Confirmed by Owner!
                </div>
            <% } else if ("Pending Verification".equalsIgnoreCase(payStatus)) { %>
                <div style="background:#fef3c7; color:#92400e; padding:15px; border-radius:12px; font-weight:700; margin-bottom:15px;">
                    ⏳ Payment UTR Submitted! Pending Owner Verification.
                </div>
                <% if (!shipAddress.isEmpty()) { %>
                    <div style="background:#f8fafc; padding:15px; border-radius:12px; text-align:left; border:1px solid #e2e8f0; font-size:13px; color:#475569;">
                        <strong style="color:#0f172a; display:block; margin-bottom:4px;">📦 Saved Shipping Address:</strong>
                        <%= shipAddress %>, <%= shipCity %> - <%= shipPincode %><br>
                        📞 Contact: <%= shipPhone %>
                    </div>
                <% } %>
            <% } else { %>
                <form action="<%=request.getContextPath()%>/ProcessPaymentServlet" method="post" style="text-align:left; margin-top:20px;">
                    <input type="hidden" name="booking_id" value="<%= bookingId %>">
                    
                    <div style="background:#fdf2f8; padding:15px; border-radius:14px; border:1px solid #fbcfe8; margin-bottom:20px;">
                        <h4 style="margin:0 0 12px; color:#be185d; font-size:15px; font-weight:700;">📦 Delivery Address Details</h4>
                        
                        <div class="input-group" style="margin-bottom:10px;">
                            <label style="font-size:12px; font-weight:700; color:#475569;">Recipient Phone Number *</label>
                            <input type="text" name="shipping_phone" value="<%= shipPhone %>" placeholder="e.g. 9876543210" required style="width:100%; padding:10px; border-radius:8px; border:1px solid #cbd5e1; box-sizing:border-box;">
                        </div>

                        <div class="input-group" style="margin-bottom:10px;">
                            <label style="font-size:12px; font-weight:700; color:#475569;">Full Delivery Address *</label>
                            <textarea name="shipping_address" placeholder="House No, Building, Street, Area..." required style="width:100%; padding:10px; border-radius:8px; border:1px solid #cbd5e1; min-height:60px; font-family:inherit; box-sizing:border-box;"><%= shipAddress %></textarea>
                        </div>

                        <div style="display:flex; gap:10px;">
                            <div class="input-group" style="flex:1;">
                                <label style="font-size:12px; font-weight:700; color:#475569;">City / Town *</label>
                                <input type="text" name="shipping_city" value="<%= shipCity %>" placeholder="e.g. Bengaluru" required style="width:100%; padding:10px; border-radius:8px; border:1px solid #cbd5e1; box-sizing:border-box;">
                            </div>
                            <div class="input-group" style="flex:1;">
                                <label style="font-size:12px; font-weight:700; color:#475569;">Pincode *</label>
                                <input type="text" name="shipping_pincode" value="<%= shipPincode %>" placeholder="e.g. 560038" required style="width:100%; padding:10px; border-radius:8px; border:1px solid #cbd5e1; box-sizing:border-box;">
                            </div>
                        </div>
                    </div>

                    <div class="input-group" style="margin-bottom:15px;">
                        <label style="font-size:13px; font-weight:700;">PhonePe / UPI Transaction Ref / UTR Number *</label>
                        <input type="text" name="payment_ref" placeholder="e.g. 420918274910 (12-digit UTR)" required style="width:100%; padding:12px; border-radius:10px; border:1px solid #cbd5e1; box-sizing:border-box;">
                    </div>

                    <button type="submit" class="btn-confirm">Submit Payment UTR & Delivery Details</button>
                </form>
            <% } %>
        </div>
    </div>
</body>
</html>
