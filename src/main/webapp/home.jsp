<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.sql.*, util.DBConnection" %>
        <%@ page session="true" %>
            <% Integer userId=(Integer) session.getAttribute("userId"); %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>SpanV Studios | Premium Ethnic Fashion</title>
                    <link rel="icon" type="image/jpg" href="images/spanv_logo.jpg">
                    <link rel="shortcut icon" href="images/spanv_logo.jpg">
                    <link
                        href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap"
                        rel="stylesheet">
                    <jsp:include page="layout/global_scripts.jsp" />
                    <style>
                        :root {
                            --primary: #db2777;
                            --primary-dark: #be185d;
                            --dark: #2d0b1e;
                            --dark-light: #471530;
                            --bg: #fff1f2;
                            --accent: #d97706;
                        }

                        * {
                            margin: 0;
                            padding: 0;
                            box-sizing: border-box;
                        }

                        body {
                            font-family: 'Outfit', sans-serif;
                            background: var(--bg);
                            color: var(--dark);
                            line-height: 1.6;
                            overflow-x: hidden;
                        }

                        /* Navbar */
                        .navbar {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            padding: 20px 8%;
                            background: rgba(255, 255, 255, 0.9);
                            backdrop-filter: blur(10px);
                            position: sticky;
                            top: 0;
                            z-index: 1000;
                            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
                        }

                        .logo {
                            font-size: 26px;
                            font-weight: 800;
                            color: var(--primary-dark);
                            text-decoration: none;
                            display: flex;
                            align-items: center;
                            gap: 8px;
                        }

                        .nav-links {
                            display: flex;
                            gap: 35px;
                            list-style: none;
                            align-items: center;
                        }

                        .nav-links a {
                            text-decoration: none;
                            color: var(--dark);
                            font-weight: 600;
                            font-size: 15px;
                            transition: 0.3s;
                        }

                        .nav-links a:hover {
                            color: var(--primary);
                        }

                        .btn-p {
                            background: var(--primary-dark);
                            color: #fff !important;
                            padding: 12px 28px;
                            border-radius: 50px;
                            font-weight: 700;
                            box-shadow: 0 10px 20px rgba(15, 118, 110, 0.2);
                            transition: 0.3s;
                        }

                        .btn-p:hover {
                            transform: translateY(-3px);
                            box-shadow: 0 15px 25px rgba(15, 118, 110, 0.3);
                        }

                        .mobile-menu {
                            display: none;
                        }

                        /* Hero Section */
                        .hero {
                            height: 85vh;
                            min-height: 600px;
                            display: flex;
                            flex-direction: column;
                            justify-content: center;
                            align-items: center;
                            text-align: center;
                            padding: 0 8%;
                            background: linear-gradient(rgba(45, 11, 30, 0.65), rgba(45, 11, 30, 0.65)),
                                url('https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=1920&q=80');
                            background-size: cover;
                            background-position: center;
                            background-attachment: fixed;
                            color: #fff;
                        }

                        .hero h1 {
                            font-size: 64px;
                            font-weight: 800;
                            margin-bottom: 25px;
                            line-height: 1.1;
                            max-width: 900px;
                        }

                        .hero h1 span {
                            color: var(--primary);
                        }

                        .hero p {
                            font-size: 22px;
                            margin-bottom: 45px;
                            max-width: 650px;
                            opacity: 0.9;
                            font-weight: 300;
                        }

                        .search-box {
                            display: flex;
                            background: rgba(255, 255, 255, 0.15);
                            backdrop-filter: blur(15px);
                            padding: 8px;
                            border-radius: 100px;
                            max-width: 700px;
                            width: 100%;
                            margin: 0 auto;
                            border: 1px solid rgba(255, 255, 255, 0.3);
                            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
                        }

                        .search-box input {
                            border: none;
                            padding: 18px 35px;
                            flex: 1;
                            border-radius: 100px;
                            outline: none;
                            font-size: 18px;
                            font-family: inherit;
                            background: transparent;
                            color: #fff;
                        }

                        .search-box input::placeholder {
                            color: rgba(255, 255, 255, 0.7);
                        }

                        .search-box button {
                            background: var(--primary);
                            color: #fff;
                            border: none;
                            padding: 10px 40px;
                            border-radius: 100px;
                            cursor: pointer;
                            font-weight: 800;
                            font-size: 16px;
                            transition: 0.3s;
                        }

                        .search-box button:hover {
                            background: #fff;
                            color: var(--dark);
                        }

                        /* Featured Grid */
                        .featured {
                            padding: 100px 8%;
                        }

                        .section-tag {
                            color: var(--primary);
                            font-weight: 800;
                            text-transform: uppercase;
                            letter-spacing: 2px;
                            display: block;
                            margin-bottom: 15px;
                            text-align: center;
                        }

                        .section-title {
                            font-size: 42px;
                            font-weight: 800;
                            margin-bottom: 60px;
                            text-align: center;
                        }

                        .grid {
                            display: grid;
                            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
                            gap: 40px;
                        }

                        .card {
                            background: #fff;
                            border-radius: 30px;
                            overflow: hidden;
                            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
                            transition: 0.4s;
                            border: 1px solid #f1f5f9;
                        }

                        .card:hover {
                            transform: translateY(-15px);
                            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.12);
                        }

                        .card-img-wrapper {
                            height: 240px;
                            overflow: hidden;
                            position: relative;
                        }

                        .card img {
                            width: 100%;
                            height: 100%;
                            object-fit: cover;
                            transition: 0.5s;
                        }

                        .card:hover img {
                            transform: scale(1.1);
                        }

                        .price-chip {
                            position: absolute;
                            bottom: 20px;
                            right: 20px;
                            background: var(--primary-dark);
                            color: #fff;
                            padding: 8px 18px;
                            border-radius: 50px;
                            font-weight: 800;
                            font-size: 14px;
                        }

                        .card-body {
                            padding: 30px;
                        }

                        .card-body h3 {
                            font-size: 22px;
                            margin-bottom: 12px;
                            font-weight: 700;
                        }

                        .card-body p {
                            color: #64748b;
                            font-size: 15px;
                            margin-bottom: 25px;
                            line-height: 1.6;
                        }

                        .rent-link {
                            display: inline-flex;
                            align-items: center;
                            gap: 8px;
                            color: var(--primary-dark);
                            font-weight: 800;
                            text-decoration: none;
                            font-size: 15px;
                            transition: 0.2s;
                        }

                        .rent-link:hover {
                            gap: 12px;
                        }

                        /* How it works */
                        .how-section {
                            background: #fff;
                            padding: 100px 8%;
                            text-align: center;
                        }

                        .steps-grid {
                            display: flex;
                            justify-content: center;
                            gap: 60px;
                            flex-wrap: wrap;
                            margin-top: 60px;
                        }

                        .step-item {
                            flex: 1;
                            min-width: 250px;
                            max-width: 350px;
                        }

                        .step-number {
                            width: 70px;
                            height: 70px;
                            background: #ccfbf1;
                            color: var(--primary-dark);
                            font-size: 28px;
                            font-weight: 800;
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin: 0 auto 25px;
                        }

                        /* Dark Footer */
                        footer {
                            background: var(--dark);
                            color: #fff;
                            padding: 100px 8% 50px;
                            border-top: 1px solid rgba(255, 255, 255, 0.05);
                        }

                        .footer-grid {
                            display: grid;
                            grid-template-columns: 2fr 1fr 1fr 1fr;
                            gap: 60px;
                        }

                        .footer-brand h3 {
                            font-size: 28px;
                            color: var(--primary);
                            margin-bottom: 25px;
                            font-weight: 800;
                        }

                        .footer-brand p {
                            color: #94a3b8;
                            max-width: 320px;
                            font-size: 16px;
                            margin-bottom: 30px;
                        }

                        .footer-col h4 {
                            font-size: 18px;
                            font-weight: 700;
                            margin-bottom: 30px;
                            position: relative;
                        }

                        .footer-col h4::after {
                            content: '';
                            position: absolute;
                            left: 0;
                            bottom: -10px;
                            width: 40px;
                            height: 3px;
                            background: var(--primary);
                            border-radius: 2px;
                        }

                        .footer-col ul {
                            list-style: none;
                        }

                        .footer-col ul li {
                            margin-bottom: 15px;
                        }

                        .footer-col ul li a {
                            text-decoration: none;
                            color: #94a3b8;
                            transition: 0.3s;
                            font-size: 15px;
                        }

                        .footer-col ul li a:hover {
                            color: var(--primary);
                            transform: translateX(5px);
                            display: inline-block;
                        }

                        .footer-bottom {
                            margin-top: 80px;
                            padding-top: 40px;
                            border-top: 1px solid rgba(255, 255, 255, 0.05);
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            color: #64748b;
                            font-size: 14px;
                        }

                        .social-links {
                            display: flex;
                            gap: 20px;
                        }

                        .social-links a {
                            width: 40px;
                            height: 40px;
                            background: rgba(255, 255, 255, 0.05);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            border-radius: 50%;
                            color: #fff;
                            text-decoration: none;
                            transition: 0.3s;
                        }

                        .social-links a:hover {
                            background: var(--primary);
                            transform: translateY(-5px);
                        }

                        @media (max-width: 1024px) {
                            .footer-grid {
                                grid-template-columns: 1fr 1fr;
                            }

                            .hero h1 {
                                font-size: 48px;
                            }
                        }

                        @media (max-width: 768px) {
                            .footer-grid {
                                grid-template-columns: 1fr;
                                gap: 30px;
                            }

                            .navbar {
                                padding: 15px 5%;
                                position: relative;
                            }

                            .hero {
                                padding: 80px 5% 60px;
                            }

                            .hero h1 {
                                font-size: 34px;
                            }

                            .mobile-menu {
                                display: block !important;
                                font-size: 26px;
                                color: var(--primary);
                                cursor: pointer;
                                padding: 5px 10px;
                                border-radius: 8px;
                                background: var(--bg);
                            }

                            .nav-links {
                                display: none;
                                flex-direction: column;
                                position: absolute;
                                top: 100%;
                                left: 0;
                                right: 0;
                                background: white;
                                padding: 20px 5%;
                                box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
                                border-bottom: 3px solid var(--primary);
                                gap: 15px;
                                z-index: 999;
                            }

                            .nav-links.active {
                                display: flex !important;
                            }
                        }
                    </style>
                </head>

                <body>
                    <!-- Premium Navbar -->
                    <nav class="navbar">
                        <a href="home.jsp" class="logo" style="display: flex; align-items: center; gap: 10px; text-decoration: none;">
                            <img src="<%=request.getContextPath()%>/images/spanv_logo.jpg" alt="SpanV Studios" style="height: 42px; border-radius: 6px; object-fit: contain;">
                            <span style="font-weight: 800; font-size: 22px; color: var(--primary);">SpanV Studios</span>
                        </a>
                        <ul class="nav-links">
                            <li><a href="viewItems.jsp">Shop Collection</a></li>
                            <% if(userId==null){ %>
                                <li><a href="login.jsp">Login</a></li>
                                <li><a href="register.jsp" class="btn-p">Join Now</a></li>
                                <% } else { %>
                                    <li><a href="dashboard.jsp">Dashboard</a></li>
                                    <li><a href="profile.jsp" class="btn-p">My Profile</a></li>
                                    <% } %>
                        </ul>
                        <div class="mobile-menu" onclick="document.querySelector('.nav-links').classList.toggle('active')">☰</div>
                    </nav>

                    <!-- Stunning Hero Section -->
                    <section class="hero">
                        <h1>Elegance In Every <span>Weave</span></h1>
                        <p>Discover our exclusive handpicked collection of designer sarees, kurtis, lehengas, and premium ethnic fabrics crafted for you.</p>
                        <form action="viewItems.jsp" method="get" class="search-box">
                            <input type="text" name="search" placeholder="Search for Sarees, Kurtis, Lehengas...">
                            <button type="submit">Search</button>
                        </form>
                    </section>

                    <!-- Featured Items Grid -->
                    <section class="featured">
                        <span class="section-tag">Exclusive Collection</span>
                        <h2 class="section-title">Shop Our Latest Designs</h2>
                        <div class="grid">
                            <% 
                            Connection con = null;
                            try {
                                con = DBConnection.getConnection();
                                if (con != null) {
                                    try (Statement st = con.createStatement();
                                         ResultSet rs = st.executeQuery("SELECT * FROM items ORDER BY id DESC LIMIT 3")) {
                                        boolean hasItems = false;
                                        while(rs.next()){ 
                                            hasItems = true; 
                                            String imgName = rs.getString("image");
                                            if(imgName == null || imgName.isEmpty()) imgName = "default.png";
                            %>
                                            <div class="card">
                                                <div class="card-img-wrapper">
                                                    <img src="<%=request.getContextPath()%>/images/<%=imgName%>"
                                                         onerror="this.src='<%=request.getContextPath()%>/images/default.png'">
                                                    <div class="price-chip">₹<%= (int)rs.getDouble("price") %></div>
                                                </div>
                                                <div class="card-body">
                                                    <h3><%=rs.getString("name")%></h3>
                                                    <p><%=rs.getString("description")%></p>
                                                    <a href="viewItems.jsp" class="rent-link">Buy Now →</a>
                                                </div>
                                            </div>
                            <%          }
                                        if(!hasItems){ %>
                                            <div style="grid-column: 1/-1; text-align: center; padding: 50px; background: #fff; border-radius: 20px;">
                                                <p style="color: #64748b;">No boutique products available right now. Adding our first design soon!</p>
                                            </div>
                            <%          }
                                    }
                                } else { %>
                                    <div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #ef4444;">
                                        Database server is starting. Please refresh in a moment.</div>
                            <%  }
                            } catch(Exception e) { %>
                                <div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #ef4444;">
                                    Unable to load items. Please verify database connection.</div>
                            <% } finally {
                                if (con != null) { try { con.close(); } catch(Exception e) {} }
                            } %>
                        </div>
                    </section>

                    <!-- Dark & Modern Footer -->
                    <footer>
                        <div class="footer-grid">
                            <div class="footer-brand">
                                <h3>SpanV Studios</h3>
                                <p>Offering premium ethnic wear and designer ensembles that celebrate tradition and modern elegance.</p>
                                <div class="social-links">
                                    <a href="https://www.instagram.com/spanv_studios/" target="_blank" title="Instagram" style="display:inline-flex; align-items:center; gap:8px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color:#e1306c;"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line></svg>
                                        Instagram
                                    </a>
                                </div>
                            </div>
                            <div class="footer-col">
                                <h4>Shop Collection</h4>
                                <ul>
                                    <li><a href="viewItems.jsp">Browse Catalog</a></li>
                                    <li><a href="addItem.jsp">Add New Design</a></li>
                                    <li><a href="myBookings.jsp">My Orders</a></li>
                                </ul>
                            </div>
                            <div class="footer-col">
                                <h4>Reach Us / Contact</h4>
                                <ul>
                                    <li>
                                        <a href="https://www.instagram.com/spanv_studios/" target="_blank" style="display:inline-flex; align-items:center; gap:6px;">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color:#e1306c;"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"></rect><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"></path><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"></line></svg>
                                            @spanv_studios
                                        </a>
                                    </li>
                                    <li><a href="mailto:spandanav2606@gmail.com">✉️ spandanav2606@gmail.com</a></li>
                                    <li><a href="tel:7899978229">📞 +91 7899978229</a></li>
                                </ul>
                            </div>
                        </div>
                        <div class="footer-bottom">
                            <p>© 2026 SpanV Studios. Celebrating your elegance.</p>
                            <p>Handcrafted with ❤️ for SpanV Boutique</p>
                        </div>
                    </footer>
                </body>

                </html>