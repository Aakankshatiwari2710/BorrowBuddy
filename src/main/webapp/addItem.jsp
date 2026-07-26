<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (role == null) { response.sendRedirect("login.jsp"); return; }
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Product | SpanV Studios</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #db2777; --primary-hover: #be185d; --bg: #fff1f2; --card: #ffffff; --text: #2d0b1e; --border: #fbcfe8; }
        body { margin: 0; font-family: 'Outfit', sans-serif; background: var(--bg); color: var(--text); }
        .main-content { margin-left: 260px; padding: 40px; }
        .container { max-width: 620px; margin: 0 auto; }
        .page-header { margin-bottom: 30px; }
        .page-header h1 { font-size: 28px; margin: 0; color: var(--primary); }
        .page-header p { color: #64748b; margin-top: 6px; }
        .card { background: var(--card); padding: 40px; border-radius: 24px; box-shadow: 0 8px 30px rgba(0,0,0,0.07); }
        .form-group { margin-bottom: 22px; }
        label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 14px; color: #374151; }
        input[type="text"], input[type="number"], textarea, select {
            width: 100%; padding: 13px 16px; border-radius: 12px; border: 1.5px solid var(--border);
            font-family: inherit; font-size: 15px; box-sizing: border-box; outline: none; transition: 0.3s;
            background: #fafafa; color: var(--text);
        }
        input:focus, textarea:focus, select:focus { border-color: var(--primary); background: white; box-shadow: 0 0 0 3px rgba(15,118,110,0.1); }
        textarea { height: 110px; resize: vertical; }
        select { cursor: pointer; }
        .file-input-wrapper { background: #f8fafc; border: 2px dashed var(--border); padding: 25px 20px; border-radius: 14px; text-align: center; transition: 0.3s; }
        .file-input-wrapper:hover { border-color: var(--primary); background: #f0fdfa; }
        .file-input-wrapper p { margin: 0 0 12px; color: #64748b; font-size: 14px; }
        input[type="file"] { cursor: pointer; }
        .btn-submit { width: 100%; padding: 15px; background: var(--primary); color: white; border: none; border-radius: 14px; font-size: 16px; font-weight: 700; cursor: pointer; transition: 0.3s; margin-top: 10px; }
        .btn-submit:hover { background: var(--primary-hover); transform: translateY(-2px); box-shadow: 0 8px 20px rgba(15,118,110,0.25); }
        .alert-error { background: #fee2e2; color: #991b1b; padding: 14px 18px; border-radius: 12px; margin-bottom: 25px; font-weight: 500; }
        .back-link { display: inline-block; margin-top: 18px; color: #64748b; text-decoration: none; font-size: 14px; }
        .back-link:hover { color: var(--primary); }
        #preview-wrap { margin-top: 12px; display: none; }
        #preview-wrap img { width: 100%; max-height: 180px; object-fit: cover; border-radius: 10px; border: 1px solid var(--border); }
        #fileLabel { display: block; margin-top: 6px; font-size: 13px; color: var(--primary); font-weight: 600; }
    </style>
</head>
<body>
    <jsp:include page="layout/sidebar.jsp" />
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>✨ Add a New Product</h1>
                <p>Add a new designer product to your boutique collection.</p>
            </div>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-error">&#10060; Error: <%= error %></div>
            <% } %>

            <div class="card">
                <form action="<%= request.getContextPath() %>/AddItemServlet" method="post" enctype="multipart/form-data" id="addForm">

                    <div class="form-group">
                        <label for="itemName">Product Name *</label>
                        <input type="text" id="itemName" name="name" placeholder="e.g. Designer Banarasi Silk Saree" required>
                    </div>

                    <div class="form-group">
                        <label for="itemCategory">Category *</label>
                        <select id="itemCategory" name="category" required>
                            <option value="" disabled selected>Select a category</option>
                            <option value="Saree">🌸 Saree</option>
                            <option value="Kurti">👗 Kurti</option>
                            <option value="Lehenga">✨ Lehenga</option>
                            <option value="Western Wear">👚 Western Wear</option>
                            <option value="Dress Materials">🧵 Dress Materials</option>
                            <option value="Others">📦 Others</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="itemDesc">Description (Optional)</label>
                        <textarea id="itemDesc" name="description" placeholder="Optional details, fabric info, usage notes..."></textarea>
                    </div>

                    <div class="form-group">
                        <label for="itemPrice">Product Price (&#8377;) *</label>
                        <input type="number" id="itemPrice" name="price" placeholder="e.g. 2500" min="1" step="1" required>
                    </div>

                    <div class="form-group">
                        <label for="offerTag">Offer / Discount Badge (Optional)</label>
                        <input type="text" id="offerTag" name="offer_tag" placeholder="e.g. 20% OFF, Festival Special, Buy 1 Get 1">
                    </div>

                    <div class="form-group">
                        <label for="stockStatus">Availability / Stock Status (Optional)</label>
                        <select id="stockStatus" name="stock_status" style="width:100%; padding:12px; border-radius:10px; border:1px solid #cbd5e1; font-family:inherit; font-size:14px;">
                            <option value="In Stock" selected>🟢 In Stock (Available for Buyers)</option>
                            <option value="Out of Stock">🔴 Out of Stock (Temporarily Unavailable)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Product Photo</label>
                        <div class="file-input-wrapper">
                            <p>📸 Click to upload an image of your product</p>
                            <input type="file" name="image" accept="image/*" id="imageInput" onchange="previewImage(this)">
                            <span id="fileLabel"></span>
                        </div>
                        <div id="preview-wrap">
                            <img id="imgPreview" src="#" alt="Preview">
                        </div>
                    </div>

                    <button type="submit" class="btn-submit" id="submitBtn">✨ Add Product to Boutique</button>
                </form>

                <a href="myItems.jsp" class="back-link">&#8592; Back to My Items</a>
            </div>
        </div>
    </div>

    <script>
        function previewImage(input) {
            var label = document.getElementById('fileLabel');
            var wrap = document.getElementById('preview-wrap');
            var img = document.getElementById('imgPreview');

            if (input.files && input.files[0]) {
                var file = input.files[0];
                label.textContent = '✓ ' + file.name;
                var reader = new FileReader();
                reader.onload = function(e) {
                    img.src = e.target.result;
                    wrap.style.display = 'block';
                };
                reader.readAsDataURL(file);
            }
        }

        document.getElementById('addForm').addEventListener('submit', function() {
            var btn = document.getElementById('submitBtn');
            btn.textContent = '⏳ Saving item...';
            btn.disabled = true;
        });
    </script>
</body>
</html>