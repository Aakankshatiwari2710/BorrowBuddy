<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page session="true" %>
        <% String role=(String) session.getAttribute("userRole"); if (role==null || !role.equalsIgnoreCase("Owner")) {
            response.sendRedirect("login.jsp"); return; } %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Add Item | BorrowBuddy</title>
                <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet">
                <style>
                    :root {
                        --primary: #0f766e;
                        --primary-hover: #115e59;
                        --bg: #f8fafc;
                        --card: #ffffff;
                        --text: #1e293b;
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
                    }

                    .container {
                        max-width: 600px;
                        margin: 0 auto;
                    }

                    .card {
                        background: var(--card);
                        padding: 40px;
                        border-radius: 25px;
                        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
                    }

                    h2 {
                        margin: 0 0 10px;
                        font-size: 28px;
                        color: var(--primary);
                    }

                    p.subtitle {
                        color: #64748b;
                        margin-bottom: 30px;
                        font-size: 15px;
                    }

                    .form-group {
                        margin-bottom: 20px;
                        text-align: left;
                    }

                    label {
                        display: block;
                        font-weight: 600;
                        margin-bottom: 8px;
                        font-size: 14px;
                    }

                    input[type="text"],
                    input[type="number"],
                    textarea {
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
                    textarea:focus {
                        border-color: var(--primary);
                        box-shadow: 0 0 0 3px rgba(15, 118, 110, 0.1);
                    }

                    textarea {
                        height: 100px;
                        resize: vertical;
                    }

                    .file-input-wrapper {
                        background: #f8fafc;
                        border: 2px dashed #e2e8f0;
                        padding: 20px;
                        border-radius: 15px;
                        text-align: center;
                        cursor: pointer;
                        transition: 0.3s;
                    }

                    .file-input-wrapper:hover {
                        border-color: var(--primary);
                        background: #f0fdfa;
                    }

                    input[type="file"] {
                        width: 100%;
                    }

                    .btn-submit {
                        width: 100%;
                        padding: 15px;
                        background: var(--primary);
                        color: white;
                        border: none;
                        border-radius: 12px;
                        font-size: 16px;
                        font-weight: 700;
                        cursor: pointer;
                        transition: 0.3s;
                        margin-top: 20px;
                    }

                    .btn-submit:hover {
                        background: var(--primary-hover);
                        transform: translateY(-2px);
                        box-shadow: 0 5px 15px rgba(15, 118, 110, 0.2);
                    }

                    .back-btn {
                        display: inline-block;
                        margin-top: 20px;
                        color: #64748b;
                        text-decoration: none;
                        font-size: 14px;
                        font-weight: 500;
                    }

                    .back-btn:hover {
                        color: var(--primary);
                    }
                </style>
            </head>

            <body>
                <jsp:include page="layout/sidebar.jsp" />
                <div class="main-content">
                    <div class="container">
                        <div class="card">
                            <h2>List New Item</h2>
                            <p class="subtitle">Fill in the details to share your item with the community.</p>

                            <form action="<%=request.getContextPath()%>/AddItemServlet" method="post"
                                enctype="multipart/form-data">
                                <div class="form-group">
                                    <label>Item Name</label>
                                    <input type="text" name="name" placeholder="e.g. Professional Drill Machine"
                                        required>
                                </div>

                                <div class="form-group">
                                    <label>Description</label>
                                    <textarea name="description"
                                        placeholder="Describe the condition, usage, and any rules..."
                                        required></textarea>
                                </div>

                                <div class="form-group">
                                    <label>Rental Price (₹ / hour)</label>
                                    <input type="number" name="price" placeholder="e.g. 150" required>
                                </div>

                                <div class="form-group">
                                    <label>Item Photo</label>
                                    <div class="file-input-wrapper">
                                        <input type="file" name="image" required>
                                    </div>
                                </div>

                                <button type="submit" class="btn-submit">List Item for Rent</button>
                            </form>

                            <a href="dashboard.jsp" class="back-btn">← Back to Dashboard</a>
                        </div>
                    </div>
                </div>
            </body>

            </html>