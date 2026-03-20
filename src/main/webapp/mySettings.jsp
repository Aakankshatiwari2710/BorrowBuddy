<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%@ page session="true" %><%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    String userImg = (String) session.getAttribute("userImage");
    if(userImg == null || userImg.isEmpty()) userImg = "default_profile.png";
    
    boolean isVerified = false;
    int trustScore = 100;
    try (java.sql.Connection con = util.DBConnection.getConnection();
         java.sql.PreparedStatement ps = con.prepareStatement("SELECT is_verified, trust_score FROM users WHERE id=?")) {
        ps.setInt(1, userId);
        try (java.sql.ResultSet rs = ps.executeQuery()) {
            if(rs.next()) {
                isVerified = rs.getBoolean("is_verified");
                trustScore = rs.getInt("trust_score");
            }
        }
    } catch(Exception e) {}
%>
            <!DOCTYPE html>
            <html lang="en" id="mainHtml">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Settings | BorrowBuddy</title>
                <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet">
                <style>
                    :root {
                        --bg: #f1f5f9;
                        --card: #ffffff;
                        --text: #1e293b;
                        --subtext: #64748b;
                        --border: #e2e8f0;
                        --primary: #0f766e;
                        --primary-hover: #115e59;
                        --accent: #14b8a6;
                        --toggle-bg: #e2e8f0;
                        --toggle-thumb: #ffffff;
                    }

                    html.dark-mode {
                        --bg: #0f172a;
                        --card: #1e293b;
                        --text: #f1f5f9;
                        --subtext: #94a3b8;
                        --border: #334155;
                        --toggle-bg: #0f766e;
                    }

                    * {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }

                    body {
                        font-family: 'Outfit', sans-serif;
                        background: var(--bg);
                        color: var(--text);
                        transition: background 0.4s, color 0.4s;
                    }

                    .main-content {
                        margin-left: 260px;
                        padding: 40px;
                        min-height: 100vh;
                    }

                    .page-header {
                        margin-bottom: 35px;
                    }

                    .page-header h1 {
                        font-size: 30px;
                        font-weight: 700;
                        color: var(--primary);
                    }

                    .page-header p {
                        color: var(--subtext);
                        margin-top: 5px;
                        font-size: 15px;
                    }

                    .settings-grid {
                        display: flex;
                        flex-direction: column;
                        gap: 20px;
                        max-width: 650px;
                    }

                    .settings-card {
                        background: var(--card);
                        border-radius: 20px;
                        padding: 28px 30px;
                        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
                        border: 1px solid var(--border);
                        transition: background 0.4s, border 0.4s;
                    }

                    .settings-card h2 {
                        font-size: 16px;
                        font-weight: 700;
                        color: var(--subtext);
                        text-transform: uppercase;
                        letter-spacing: 1px;
                        margin-bottom: 20px;
                    }

                    .setting-row {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        padding: 14px 0;
                        border-bottom: 1px solid var(--border);
                    }

                    .setting-row:last-child {
                        border-bottom: none;
                    }

                    .setting-info {
                        display: flex;
                        align-items: center;
                        gap: 14px;
                    }

                    .setting-icon {
                        width: 44px;
                        height: 44px;
                        border-radius: 12px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 20px;
                        background: #f0fdfa;
                    }

                    .setting-text h3 {
                        font-size: 15px;
                        font-weight: 600;
                        color: var(--text);
                    }

                    .setting-text p {
                        font-size: 13px;
                        color: var(--subtext);
                        margin-top: 2px;
                    }

                    /* Toggle Switch */
                    .toggle-switch {
                        position: relative;
                        width: 54px;
                        height: 28px;
                    }

                    .toggle-switch input {
                        opacity: 0;
                        width: 0;
                        height: 0;
                    }

                    .toggle-slider {
                        position: absolute;
                        cursor: pointer;
                        top: 0;
                        left: 0;
                        right: 0;
                        bottom: 0;
                        background: var(--toggle-bg);
                        border-radius: 34px;
                        transition: 0.4s;
                    }

                    .toggle-slider:before {
                        position: absolute;
                        content: "";
                        height: 20px;
                        width: 20px;
                        left: 4px;
                        bottom: 4px;
                        background: var(--toggle-thumb);
                        border-radius: 50%;
                        transition: 0.4s;
                        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15);
                    }

                    input:checked+.toggle-slider {
                        background: var(--primary);
                    }

                    input:checked+.toggle-slider:before {
                        transform: translateX(26px);
                    }

                    /* Theme Preview */
                    .theme-preview {
                        display: flex;
                        gap: 12px;
                        margin-top: 20px;
                    }

                    .theme-option {
                        flex: 1;
                        padding: 14px;
                        border-radius: 14px;
                        border: 2px solid var(--border);
                        cursor: pointer;
                        text-align: center;
                        font-size: 13px;
                        font-weight: 600;
                        transition: 0.3s;
                        color: var(--text);
                        background: var(--card);
                    }

                    .theme-option.selected {
                        background: var(--primary) !important;
                        color: white !important;
                        border-color: var(--primary) !important;
                        box-shadow: 0 4px 12px rgba(15, 118, 110, 0.4) !important;
                    }

                    /* Logout button */
                    .logout-card {
                        background: #fff5f5;
                        border: 1px solid #fee2e2;
                        border-radius: 20px;
                        padding: 28px 30px;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        gap: 20px;
                    }

                    html.dark-mode .logout-card {
                        background: #2d1515;
                        border-color: #7f1d1d;
                    }

                    .logout-card .logout-info h3 {
                        font-size: 16px;
                        font-weight: 700;
                        color: #ef4444;
                    }

                    .logout-card .logout-info p {
                        font-size: 13px;
                        color: var(--subtext);
                        margin-top: 4px;
                    }

                    .btn-logout {
                        background: #ef4444;
                        color: white;
                        text-decoration: none;
                        padding: 12px 28px;
                        border-radius: 12px;
                        font-weight: 700;
                        font-size: 15px;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        white-space: nowrap;
                        transition: 0.3s;
                        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.25);
                    }

                    .btn-logout:hover {
                        background: #dc2626;
                        transform: translateY(-2px);
                        box-shadow: 0 6px 16px rgba(239, 68, 68, 0.4);
                    }

                    /* Account info */
                    .account-info {
                        display: flex;
                        align-items: center;
                        gap: 16px;
                    }

                    .avatar {
                        width: 52px;
                        height: 52px;
                        background: var(--primary);
                        color: white;
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 22px;
                        font-weight: 700;
                        flex-shrink: 0;
                        overflow: hidden;
                    }

                    .avatar img {
                        width: 100%;
                        height: 100%;
                        object-fit: cover;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="layout/sidebar.jsp" />

                <div class="main-content">
                    <div class="page-header">
                        <h1>⚙️ Settings</h1>
                        <p>Manage your preferences and account settings.</p>
                    </div>

                    <div class="settings-grid">

                        <!-- Account Info Card -->
                        <div class="settings-card">
                            <h2>Account</h2>
                            <div class="setting-row" style="border-bottom:none; margin-bottom:0; padding-bottom:0;">
                                <div class="account-info">
                                    <div class="avatar">
                                        <img src="<%=request.getContextPath()%>/images/profiles/<%=userImg%>" 
                                             alt="Profile" 
                                             onerror="this.src='<%=request.getContextPath()%>/images/default_profile.png'">
                                    </div>
                                    <div>
                                        <div style="font-weight: 700; font-size: 16px; color: var(--text);">
                                            <%= userName %>
                                        </div>
                                        <div style="font-size: 13px; color: var(--subtext); margin-top: 3px;">
                                            <span
                                                style="background: #ccfbf1; color: #0f766e; padding: 2px 10px; border-radius: 20px; font-weight: 700; font-size: 12px;">
                                                <%= userRole %>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <a href="profile.jsp"
                                    style="color: var(--primary); font-weight: 600; font-size: 14px; text-decoration: none;">Edit
                                    Profile →</a>
                            </div>
                        </div>

                        <!-- Trust and Verification Card -->
                        <div class="settings-card">
                            <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 20px;">
                                <div style="font-size: 24px;">🛡️</div>
                                <h2 style="margin:0; font-size:1.5rem;">Trust & Identity</h2>
                            </div>
                            <p style="color: var(--subtext); font-size: 14px; margin-bottom: 20px;">Enhance your reliability in the community.</p>
                            
                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 15px; background: rgba(0,0,0,0.03); border-radius: 12px; margin-bottom: 15px;">
                                <div>
                                    <span style="font-size: 11px; color: var(--subtext); display: block; text-transform: uppercase; letter-spacing: 0.5px; font-weight:700;">Trust Points</span>
                                    <span style="font-size: 18px; font-weight: 800; color: var(--primary);"><%= trustScore %> Pts</span>
                                </div>
                                <div style="text-align: right;">
                                    <span style="font-size: 11px; color: var(--subtext); display: block; text-transform: uppercase; letter-spacing: 0.5px; font-weight:700;">Status</span>
                                    <span style="display: inline-block; padding: 4px 12px; border-radius: 50px; font-size: 10px; font-weight: 900; background: <%= isVerified ? "#ccfbf1" : "#fee2e2" %>; color: <%= isVerified ? "#0f766e" : "#991b1b" %>;">
                                        <%= isVerified ? "VERIFIED" : "UNVERIFIED" %>
                                    </span>
                                </div>
                            </div>
                            
                            <% if(!isVerified) { %>
                                <button onclick="alert('Verification process started! Please check your email.')" 
                                        style="width: 100%; padding: 12px; background: var(--primary); border: none; border-radius: 10px; color: white; font-weight: 700; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 12px rgba(15, 118, 110, 0.2);">
                                    Verify Identity Now
                                </button>
                            <% } else { %>
                                <div style="text-align: center; padding: 10px; background: #ccfbf1; color: #0f766e; border-radius: 10px; font-size: 13px; font-weight: 700;">
                                    ✓ Account Fully Verified
                                </div>
                            <% } %>
                        </div>

                        <!-- Appearance Card -->
                        <div class="settings-card">
                            <h2>Appearance</h2>

                            <div class="setting-row">
                                <div class="setting-info">
                                    <div class="setting-icon">🌙</div>
                                    <div class="setting-text">
                                        <h3>Dark Mode</h3>
                                        <p>Switch between light and dark theme</p>
                                    </div>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" id="darkToggle" onchange="toggleDarkMode(this)">
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>

                            <div class="theme-preview">
                                <div class="theme-option light-preview" id="lightOption" onclick="setTheme('light')">
                                    ☀️ Light Mode
                                </div>
                                <div class="theme-option dark-preview" id="darkOption" onclick="setTheme('dark')">
                                    🌙 Dark Mode
                                </div>
                            </div>
                        </div>

                        <!-- Language Card -->
                        <div class="settings-card">
                            <h2>Language / भाषा</h2>
                            <div class="theme-preview">
                                <div class="theme-option" id="enOption" onclick="setLang('en')">
                                    🇺🇸 English
                                </div>
                                <div class="theme-option" id="hiOption" onclick="setLang('hi')">
                                    🇮🇳 Hindi
                                </div>
                            </div>
                        </div>



                        <!-- Notifications Card -->
                        <div class="settings-card">
                            <h2>Preferences</h2>

                            <div class="setting-row">
                                <div class="setting-info">
                                    <div class="setting-icon">🔔</div>
                                    <div class="setting-text">
                                        <h3>Notifications</h3>
                                        <p>View your latest alerts and updates</p>
                                    </div>
                                </div>
                                <a href="notifications.jsp"
                                    style="color: var(--primary); font-weight: 600; font-size: 14px; text-decoration: none;">View
                                    →</a>
                            </div>

                            <div class="setting-row">
                                <div class="setting-info">
                                    <div class="setting-icon">🔒</div>
                                    <div class="setting-text">
                                        <h3>Privacy & Password</h3>
                                        <p>Update your password and security settings</p>
                                    </div>
                                </div>
                                <a href="profile.jsp"
                                    style="color: var(--primary); font-weight: 600; font-size: 14px; text-decoration: none;">Manage
                                    →</a>
                            </div>
                        </div>

                        <!-- Logout Card -->
                        <div class="logout-card">
                            <div class="logout-info">
                                <h3>🚪 Sign Out</h3>
                                <p>You'll be redirected to the login page. Your data is safe.</p>
                            </div>
                            <a href="<%= request.getContextPath() %>/LogoutServlet" class="btn-logout">
                                🚪 Logout Now
                            </a>
                        </div>

                    </div>
                </div>

                </div> <!-- closing settings-grid -->
            </div> <!-- closing main-content -->
            <script>
                    // Apply saved theme IMMEDIATELY on load
                    const savedTheme = localStorage.getItem('theme') || 'light';
                    applyTheme(savedTheme);

                    function applyTheme(theme) {
                        const html = document.documentElement;
                        const toggle = document.getElementById('darkToggle');
                        const lightOpt = document.getElementById('lightOption');
                        const darkOpt = document.getElementById('darkOption');

                        if (theme === 'dark') {
                            html.classList.add('dark-mode');
                            if (toggle) toggle.checked = true;
                            if (lightOpt) lightOpt.classList.remove('selected');
                            if (darkOpt) darkOpt.classList.add('selected');
                        } else {
                            html.classList.remove('dark-mode');
                            if (toggle) toggle.checked = false;
                            if (lightOpt) lightOpt.classList.add('selected');
                            if (darkOpt) darkOpt.classList.remove('selected');
                        }
                    }

                    function toggleDarkMode(checkbox) {
                        const theme = checkbox.checked ? 'dark' : 'light';
                        localStorage.setItem('theme', theme);
                        applyTheme(theme);
                    }

                    function setTheme(theme) {
                        localStorage.setItem('theme', theme);
                        applyTheme(theme);
                    }

                    // --- Language Logic ---
                    const savedLang = localStorage.getItem('language') || 'en';
                    const updateLangUI = (lang) => {
                        const en = document.getElementById('enOption');
                        const hi = document.getElementById('hiOption');
                        if(en) en.classList.toggle('selected', lang === 'en');
                        if(hi) hi.classList.toggle('selected', lang === 'hi');
                    };
                    updateLangUI(savedLang);

                    function setLang(lang) {
                        localStorage.setItem('language', lang);
                        updateLangUI(lang);
                        location.reload();
                    }


                </script>
            </body>

            </html>