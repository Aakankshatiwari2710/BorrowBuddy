<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!-- Global Theme & Language Engine (V4 - Comprehensive Coverage) -->
<style>
    /* 1. Global Dark Mode Variables */
    html.dark-mode {
        --bg-main: #0f172a;
        --bg-card: #1e293b;
        --text-primary: #ffffff; 
        --text-secondary: #cbd5e1;
        --border-color: #334155;
        --primary: #14b8a6;
    }

    /* Base Body & Layout */
    html.dark-mode body {
        background-color: var(--bg-main) !important;
        color: var(--text-primary) !important;
    }

    html.dark-mode .main-content,
    html.dark-mode .dashboard-container,
    html.dark-mode .container,
    html.dark-mode .auth-container,
    html.dark-mode .login-container,
    html.dark-mode .register-container,
    html.dark-mode .profile-container {
        background-color: var(--bg-main) !important;
    }

    /* Universal Card & Component Overrides */
    html.dark-mode .card,
    html.dark-mode .action-card,
    html.dark-mode .settings-card,
    html.dark-mode .notification-card,
    html.dark-mode .notification-list,
    html.dark-mode .table-container,
    html.dark-mode .profile-card,
    html.dark-mode .item-card,
    html.dark-mode .booking-card,
    html.dark-mode .checkout-container,
    html.dark-mode .chat-container,
    html.dark-mode .info-group,
    html.dark-mode .file-input-wrapper,
    html.dark-mode .modal-content,
    html.dark-mode .search-container,
    html.dark-mode .item-list,
    html.dark-mode .listing-container {
        background-color: var(--bg-card) !important;
        border: 1px solid var(--border-color) !important;
        color: var(--text-primary) !important;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5) !important;
    }

    /* Specific Item Overrides (Notifications, Lists) */
    html.dark-mode .notification-item, 
    html.dark-mode .list-item {
        border-bottom: 1px solid var(--border-color) !important;
        background-color: transparent !important;
        color: var(--text-primary) !important;
    }

    html.dark-mode .notification-item:hover,
    html.dark-mode .list-item:hover {
        background-color: #334155 !important;
    }

    html.dark-mode .icon, 
    html.dark-mode .card-icon {
        background-color: #0f172a !important;
        color: var(--primary) !important;
    }

    /* Forced Dark Text on Light Elements (Badges) */
    html.dark-mode .badge,
    html.dark-mode [class*="badge-"],
    html.dark-mode .status-badge,
    html.dark-mode .category-badge {
        color: #0f172a !important;
        font-weight: 700 !important;
    }

    /* Headings & Text visibility */
    html.dark-mode h1, html.dark-mode h2, html.dark-mode h3, 
    html.dark-mode h4, html.dark-mode h5,
    html.dark-mode .profile-name, html.dark-mode .header,
    html.dark-mode .message {
        color: var(--text-primary) !important;
    }

    html.dark-mode p, html.dark-mode label, 
    html.dark-mode .description, html.dark-mode .subtext,
    html.dark-mode .timestamp, html.dark-mode .info-label {
        color: var(--text-secondary) !important;
    }

    /* Forms */
    html.dark-mode input,
    html.dark-mode textarea,
    html.dark-mode select {
        background-color: #0f172a !important;
        color: #ffffff !important;
        border: 1px solid var(--border-color) !important;
    }

    /* Navigation */
    html.dark-mode .sidebar {
        background-color: #0f172a !important;
    }
    
    html.dark-mode .sidebar ul li a.active {
        background-color: #1e293b !important;
    }

    /* Buttons */
    html.dark-mode .btn,
    html.dark-mode button,
    html.dark-mode .login-btn,
    html.dark-mode .action-btn {
        color: #ffffff !important;
        font-weight: 600 !important;
    }
</style>

<script>
    (function() {
        // 1. Theme Logic
        const applyTheme = (theme) => {
            if (theme === 'dark') document.documentElement.classList.add('dark-mode');
            else document.documentElement.classList.remove('dark-mode');
        };
        applyTheme(localStorage.getItem('theme') || 'light');

        // 2. Language Logic (Hindi)
        const translations = {
            "Home": "मुख्य पृष्ठ",
            "Dashboard": "डैशबोर्ड",
            "My Profile": "मेरी प्रोफ़ाइल",
            "Settings": "सेटिंग्स",
            "Notifications": "सूचनाएं",
            "Logout": "लॉगआउट",
            "Search Items": "सामान खोजें",
            "My Items": "मेरे सामान",
            "Requests": "अनुरोध",
            "Add New Item": "नया सामान जोड़ें",
            "Pending Approval": "अनुमोदन लंबित",
            "Appearance": "दिखावट",
            "Choose Language": "भाषा चुनें",
            "Dark Mode": "डार्क मोड",
            "Stay updated with your booking requests and community alerts.": "अपनी बुकिंग अनुरोधों और सामुदायिक अलर्ट के साथ अपडेट रहें।"
        };

        const sortedKeys = Object.keys(translations).sort((a, b) => b.length - a.length);

        function translateNode(node) {
            if (!node) return;
            if (node.nodeType === 3) {
                let text = node.nodeValue;
                let trimmed = text.trim();
                for (const key of sortedKeys) {
                    if (trimmed.includes(key)) {
                        node.nodeValue = text.replace(new RegExp(key, 'g'), translations[key]);
                    }
                }
            } else if (node.nodeType === 1 && !['SCRIPT', 'STYLE', 'TEXTAREA'].includes(node.tagName)) {
                if (node.placeholder) {
                    for (const key of sortedKeys) {
                        if (node.placeholder.includes(key)) node.placeholder = node.placeholder.replace(key, translations[key]);
                    }
                }
                node.childNodes.forEach(translateNode);
            }
        }

        const runTranslation = () => {
            if (localStorage.getItem('language') === 'hi') {
                translateNode(document.body);
                new MutationObserver(m => m.forEach(r => r.addedNodes.forEach(translateNode))).observe(document.body, {childList:true, subtree:true});
            }
        };

        if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', runTranslation);
        else runTranslation();
    })();

    // 3. PWA Registration
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
            navigator.serviceWorker.register('sw.js')
                .then(reg => console.log('SW Registered', reg))
                .catch(err => console.log('SW Error', err));
        });
    }
</script>

<link rel="manifest" href="manifest.json">
<meta name="theme-color" content="#0f766e">
<link rel="apple-touch-icon" href="images/logo_192.png">
