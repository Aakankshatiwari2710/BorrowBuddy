<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page session="true" %>
        <% Integer userId=(Integer) session.getAttribute("userId"); String userName=(String)
            session.getAttribute("userName"); String email=(String) session.getAttribute("userEmail"); String
            role=(String) session.getAttribute("userRole"); String userImage=(String) session.getAttribute("userImage");
            if (userId==null) { response.sendRedirect("login.jsp"); return; } if(userImage==null || userImage.isEmpty())
            userImage="default_profile.png" ; String edit=request.getParameter("edit"); %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>My Profile | BorrowBuddy</title>
                <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css">
                <style>
                    :root {
                        --primary: #0f766e;
                        --primary-light: #14b8a6;
                        --bg: #f8fafc;
                        --card-bg: #ffffff;
                        --text: #1e293b;
                        --text-light: #64748b;
                    }

                    body {
                        margin: 0;
                        font-family: 'Poppins', sans-serif;
                        background: var(--bg);
                        color: var(--text);
                    }

                    .main-content {
                        margin-left: 260px;
                        padding: 40px;
                    }

                    .profile-container {
                        max-width: 800px;
                        margin: 0 auto;
                    }

                    .profile-card {
                        background: var(--card-bg);
                        border-radius: 20px;
                        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
                        overflow: hidden;
                        position: relative;
                    }

                    .profile-header {
                        background: linear-gradient(135deg, var(--primary), var(--primary-light));
                        height: 120px;
                    }

                    .profile-body {
                        padding: 0 40px 40px;
                        text-align: center;
                        margin-top: -60px;
                    }

                    .profile-img-container {
                        position: relative;
                        display: inline-block;
                        margin-bottom: 20px;
                    }

                    .profile-img {
                        width: 140px;
                        height: 140px;
                        border-radius: 50%;
                        border: 5px solid #fff;
                        object-fit: cover;
                        background: #eee;
                        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
                    }

                    .profile-name {
                        font-size: 24px;
                        font-weight: 700;
                        margin: 0;
                        color: var(--text);
                    }

                    .profile-role {
                        font-size: 14px;
                        color: var(--text-light);
                        background: #f1f5f9;
                        padding: 4px 12px;
                        border-radius: 20px;
                        display: inline-block;
                        margin-top: 8px;
                        font-weight: 500;
                        text-transform: uppercase;
                    }

                    .profile-info {
                        margin-top: 30px;
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 20px;
                        text-align: left;
                    }

                    .info-group {
                        background: #f8fafc;
                        padding: 15px 20px;
                        border-radius: 12px;
                        border: 1px solid #e2e8f0;
                    }

                    .info-label {
                        font-size: 12px;
                        color: var(--text-light);
                        display: block;
                        margin-bottom: 4px;
                        font-weight: 600;
                        text-transform: uppercase;
                    }

                    .info-value {
                        font-size: 16px;
                        font-weight: 500;
                    }

                    .btn-container {
                        margin-top: 30px;
                    }

                    .btn {
                        display: inline-block;
                        padding: 12px 30px;
                        border-radius: 10px;
                        background: var(--primary);
                        color: white;
                        text-decoration: none;
                        font-weight: 600;
                        font-size: 14px;
                        transition: 0.3s;
                        border: none;
                        cursor: pointer;
                    }

                    .btn:hover {
                        background: #115e59;
                        transform: translateY(-2px);
                        box-shadow: 0 5px 15px rgba(15, 118, 110, 0.3);
                    }

                    .btn-secondary {
                        background: #f1f5f9;
                        color: var(--text);
                        margin-left: 10px;
                    }

                    .btn-secondary:hover {
                        background: #e2e8f0;
                    }

                    .edit-form {
                        text-align: left;
                        margin-top: 30px;
                    }

                    .form-row {
                        margin-bottom: 20px;
                    }

                    label {
                        display: block;
                        margin-bottom: 8px;
                        font-size: 14px;
                        font-weight: 600;
                        color: var(--text);
                    }

                    input[type="text"],
                    input[type="email"],
                    input[type="password"] {
                        width: 100%;
                        padding: 12px;
                        border: 1px solid #e2e8f0;
                        border-radius: 10px;
                        box-sizing: border-box;
                        font-family: inherit;
                    }

                    .file-input-wrapper {
                        position: relative;
                        background: #f8fafc;
                        padding: 20px;
                        border: 2px dashed #e2e8f0;
                        border-radius: 12px;
                        text-align: center;
                    }

                    .file-input-wrapper:hover {
                        border-color: var(--primary);
                    }

                    #cropModal {
                        display: none;
                        position: fixed;
                        z-index: 1000;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        background: rgba(0, 0, 0, 0.8);
                        justify-content: center;
                        align-items: center;
                        padding: 20px;
                    }

                    .modal-content {
                        background: white;
                        padding: 25px;
                        border-radius: 20px;
                        width: 100%;
                        max-width: 600px;
                        text-align: center;
                        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
                    }

                    .crop-area {
                        max-height: 400px;
                        margin: 20px 0;
                        overflow: hidden;
                        background: #f1f5f9;
                        border-radius: 10px;
                    }

                    .crop-area img {
                        max-width: 100%;
                        display: block;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="layout/sidebar.jsp" />
                <div class="main-content">
                    <div class="profile-container">
                        <div class="profile-card">
                            <div class="profile-header"></div>
                            <div class="profile-body">
                                <div class="profile-img-container">
                                    <img id="profilePreview"
                                        src="<%=request.getContextPath()%>/images/profiles/<%=userImage%>"
                                        alt="Profile Picture" class="profile-img"
                                        onerror="this.src='<%=request.getContextPath()%>/images/default_profile.png'">
                                </div>

                                <% if (edit==null) { %>
                                    <h2 class="profile-name">
                                        <%= userName %>
                                    </h2>
                                    <span class="profile-role">
                                        <%= role %>
                                    </span>

                                    <div class="profile-info">
                                        <div class="info-group">
                                            <span class="info-label">Full Name</span>
                                            <span class="info-value">
                                                <%= userName %>
                                            </span>
                                        </div>
                                        <div class="info-group">
                                            <span class="info-label">Email Address</span>
                                            <span class="info-value">
                                                <%= email %>
                                            </span>
                                        </div>
                                    </div>

                                    <div class="btn-container">
                                        <a href="profile.jsp?edit=true" class="btn">Edit Profile</a>
                                    </div>
                                    <% } else { %>
                                        <h2 class="profile-name">Edit Profile</h2>
                                        <form id="profileForm" action="UpdateProfileServlet" method="post"
                                            enctype="multipart/form-data" class="edit-form">
                                            <input type="hidden" id="croppedImageData" name="croppedImageData">
                                            <div class="form-row">
                                                <label>Profile Picture</label>
                                                <div class="file-input-wrapper">
                                                    <input type="file" id="imageInput" name="profileImage"
                                                        accept="image/*">
                                                    <p id="fileStatus"
                                                        style="font-size: 12px; color: #64748b; margin-top: 10px;">Click
                                                        to select and crop photo</p>
                                                </div>
                                            </div>
                                            <div class="form-row">
                                                <label>Full Name</label>
                                                <input type="text" name="name" value="<%= userName %>" required>
                                            </div>
                                            <div class="form-row">
                                                <label>Email Address</label>
                                                <input type="email" name="email" value="<%= email %>" required>
                                            </div>
                                            <div class="form-row">
                                                <label>Current Password</label>
                                                <input type="password" name="password" required>
                                            </div>
                                            <div class="btn-container">
                                                <button type="submit" class="btn">Save Changes</button>
                                                <a href="profile.jsp" class="btn btn-secondary">Cancel</a>
                                            </div>
                                        </form>
                                        <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Cropping Modal -->
                <div id="cropModal">
                    <div class="modal-content">
                        <h3 style="margin-top:0">Adjust Your Photo</h3>
                        <div class="crop-area"><img id="cropImage" src=""></div>
                        <div class="btn-container" style="margin-bottom:0">
                            <button id="cropBtn" class="btn">Crop & Apply</button>
                            <button id="cancelCrop" class="btn btn-secondary">Cancel</button>
                        </div>
                    </div>
                </div>

                <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"></script>
                <script>
                    let cropper;
                    const imageInput = document.getElementById('imageInput');
                    const cropModal = document.getElementById('cropModal');
                    const cropImage = document.getElementById('cropImage');
                    const cropBtn = document.getElementById('cropBtn');
                    const cancelCrop = document.getElementById('cancelCrop');
                    const croppedImageDataInput = document.getElementById('croppedImageData');
                    const profilePreview = document.getElementById('profilePreview');
                    const fileStatus = document.getElementById('fileStatus');

                    if (imageInput) {
                        imageInput.addEventListener('change', function (e) {
                            const files = e.target.files;
                            if (files && files.length > 0) {
                                const reader = new FileReader();
                                reader.onload = function (event) {
                                    cropImage.src = event.target.result;
                                    cropModal.style.display = 'flex';
                                    if (cropper) cropper.destroy();
                                    setTimeout(() => {
                                        cropper = new Cropper(cropImage, {
                                            aspectRatio: 1,
                                            viewMode: 1,
                                            dragMode: 'move',
                                            autoCropArea: 0.8
                                        });
                                    }, 100);
                                };
                                reader.readAsDataURL(files[0]);
                            }
                        });
                        cancelCrop.onclick = () => { cropModal.style.display = 'none'; imageInput.value = ''; };
                        cropBtn.onclick = (e) => {
                            e.preventDefault();
                            const canvas = cropper.getCroppedCanvas({ width: 500, height: 500 });
                            const base64data = canvas.toDataURL('image/jpeg', 0.9);
                            croppedImageDataInput.value = base64data;
                            profilePreview.src = base64data;
                            fileStatus.innerText = "✅ Image Cropped Successfully!";
                            fileStatus.style.color = "var(--primary)";
                            cropModal.style.display = 'none';
                        };
                    }
                </script>
            </body>

            </html>