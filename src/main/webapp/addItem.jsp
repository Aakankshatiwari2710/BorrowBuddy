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
    <link rel="icon" type="image/jpg" href="images/spanv_logo.jpg">
    <link rel="shortcut icon" href="images/spanv_logo.jpg">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #db2777; --primary-hover: #be185d; --bg: #fff1f2; --card: #ffffff; --text: #2d0b1e; --border: #fbcfe8; }
        body { margin: 0; font-family: 'Outfit', sans-serif; background: var(--bg); color: var(--text); }
        .main-content { margin-left: 260px; padding: 40px; }
        .container { max-width: 650px; margin: 0 auto; }
        .page-header { margin-bottom: 30px; }
        .page-header h1 { font-size: 28px; margin: 0; color: var(--primary); }
        .page-header p { color: #64748b; margin-top: 6px; }
        .card { background: var(--card); padding: 40px; border-radius: 24px; box-shadow: 0 8px 30px rgba(0,0,0,0.07); border: 1px solid var(--border); }
        .form-group { margin-bottom: 22px; }
        label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 14px; color: #374151; }
        input[type="text"], input[type="number"], textarea, select {
            width: 100%; padding: 13px 16px; border-radius: 12px; border: 1.5px solid var(--border);
            font-family: inherit; font-size: 15px; box-sizing: border-box; outline: none; transition: 0.3s;
            background: #fafafa; color: var(--text);
        }
        input:focus, textarea:focus, select:focus { border-color: var(--primary); background: white; box-shadow: 0 0 0 3px rgba(219,39,119,0.1); }
        textarea { height: 110px; resize: vertical; }
        select { cursor: pointer; }
        .file-input-wrapper { background: #fff0f5; border: 2px dashed var(--primary); padding: 30px 20px; border-radius: 16px; text-align: center; transition: 0.3s; cursor: pointer; }
        .file-input-wrapper:hover { background: #ffe4e6; }
        .file-input-wrapper p { margin: 0 0 8px; color: var(--primary); font-size: 15px; font-weight: 700; }
        .file-input-wrapper span { color: #64748b; font-size: 13px; }
        input[type="file"] { cursor: pointer; }
        .btn-submit { width: 100%; padding: 15px; background: linear-gradient(135deg, var(--primary), var(--primary-hover)); color: white; border: none; border-radius: 14px; font-size: 16px; font-weight: 700; cursor: pointer; transition: 0.3s; margin-top: 10px; box-shadow: 0 6px 20px rgba(219,39,119,0.25); }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(219,39,119,0.35); }
        .alert-error { background: #fee2e2; color: #991b1b; padding: 14px 18px; border-radius: 12px; margin-bottom: 25px; font-weight: 500; }
        .back-link { display: inline-block; margin-top: 18px; color: #64748b; text-decoration: none; font-size: 14px; }
        .back-link:hover { color: var(--primary); }
        .preview-grid { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 15px; }
        .preview-item { width: 90px; height: 90px; border-radius: 12px; overflow: hidden; border: 2px solid #db2777; position: relative; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .preview-item img { width: 100%; height: 100%; object-fit: cover; }
        .preview-item .badge-main { position: absolute; bottom: 0; left: 0; right: 0; background: rgba(219,39,119,0.85); color: white; font-size: 10px; font-weight: 700; text-align: center; padding: 2px 0; }
    </style>
</head>
<body>
    <jsp:include page="layout/sidebar.jsp" />
    <div class="main-content">
        <div class="container">
            <div class="page-header">
                <h1>✨ Add a New Product</h1>
                <p>Upload multiple photos to showcase your boutique design to buyers.</p>
            </div>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-error">⚠️ Error: <%= error %></div>
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
                        <textarea id="itemDesc" name="description" placeholder="Describe fabric, embroidery, occasion details..."></textarea>
                    </div>

                    <div class="form-group">
                        <label for="itemPrice">Product Price (&#8377;) *</label>
                        <input type="number" id="itemPrice" name="price" placeholder="e.g. 2500" min="1" step="1" required>
                    </div>

                    <div class="form-group">
                        <label for="offerTag">Offer / Discount Badge (Optional)</label>
                        <input type="text" id="offerTag" name="offer_tag" placeholder="e.g. 20% OFF, Festival Special">
                    </div>

                    <div class="form-group">
                        <label for="stockStatus">Availability / Stock Status (Optional)</label>
                        <select id="stockStatus" name="stock_status">
                            <option value="In Stock" selected>🟢 In Stock (Available for Buyers)</option>
                            <option value="Out of Stock">🔴 Out of Stock (Temporarily Unavailable)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Product Photos (Select Multiple Photos) 📸 *</label>
                        <div class="file-input-wrapper" onclick="document.getElementById('imageInput').click()">
                            <p>📸 Click here to select multiple product photos</p>
                            <span>Hold Ctrl / Shift to select multiple images at once</span>
                            <input type="file" name="image" accept="image/*" id="imageInput" multiple style="display:none;" onchange="previewImages(this)">
                        </div>
                        <div id="fileCountLabel" style="margin-top: 8px; font-weight: 700; color: var(--primary); font-size: 14px;"></div>
                        <div class="preview-grid" id="previewGrid"></div>
                    </div>

                    <button type="submit" class="btn-submit" id="submitBtn">✨ Add Product with Multiple Photos</button>
                </form>

                <a href="myItems.jsp" class="back-link">&#8592; Back to My Items</a>
            </div>
        </div>
    </div>

    <script>
        function previewImages(input) {
            var grid = document.getElementById('previewGrid');
            var label = document.getElementById('fileCountLabel');
            grid.innerHTML = '';

            if (input.files && input.files.length > 0) {
                label.textContent = '✓ ' + input.files.length + ' photo(s) selected';

                for (var i = 0; i < input.files.length; i++) {
                    (function(file, index) {
                        var reader = new FileReader();
                        reader.onload = function(e) {
                            var item = document.createElement('div');
                            item.className = 'preview-item';
                            item.innerHTML = '<img src="' + e.target.result + '" alt="Photo ' + (index + 1) + '">' +
                                             (index === 0 ? '<span class="badge-main">Cover</span>' : '');
                            grid.appendChild(item);
                        };
                        reader.readAsDataURL(file);
                    })(input.files[i], i);
                }
            } else {
                label.textContent = '';
            }
        }

        document.getElementById('addForm').addEventListener('submit', function() {
            var btn = document.getElementById('submitBtn');
            btn.textContent = '⏳ Uploading photos and saving product...';
            btn.disabled = true;
        });
    </script>
</body>
</html>