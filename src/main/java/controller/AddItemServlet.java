package controller;

import java.io.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/AddItemServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,      // 10 MB max per file
    maxRequestSize = 50 * 1024 * 1024     // 50 MB max per request (multiple images)
)
public class AddItemServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String name        = request.getParameter("name");
        String description = request.getParameter("description");
        if (description == null) description = "";
        String price       = request.getParameter("price");
        String category    = request.getParameter("category");
        String offerTag    = request.getParameter("offer_tag");
        if (offerTag == null) offerTag = "";
        String stockStatus = request.getParameter("stock_status");
        if (stockStatus == null || stockStatus.isEmpty()) stockStatus = "In Stock";
        String ownerEmail  = (String) session.getAttribute("userEmail");

        // ── Handle multiple uploaded images ──────────────────────────────────────────
        List<String> savedImages = new ArrayList<>();
        String deployedPath = getServletContext().getRealPath("/images");
        File deployDir = new File(deployedPath);
        if (!deployDir.exists()) deployDir.mkdirs();

        for (Part part : request.getParts()) {
            if ("image".equals(part.getName()) && part.getSize() > 0) {
                String submittedName = part.getSubmittedFileName();
                if (submittedName != null && !submittedName.trim().isEmpty()) {
                    String baseName = new File(submittedName).getName();
                    String uniqueFileName = System.currentTimeMillis() + "_" + baseName.replaceAll("[^a-zA-Z0-9._-]", "_");

                    // 1. Write to deployed /images directory
                    File destFile = new File(deployDir, uniqueFileName);
                    part.write(destFile.getAbsolutePath());
                    savedImages.add(uniqueFileName);

                    // 2. Best-effort copy to source directory for persistence across redeploys
                    try {
                        String srcPath = getServletContext().getRealPath("/")
                                .replace("\\tmp0\\wtpwebapps\\ShareSphere\\", "\\ShareSphere\\src\\main\\webapp\\")
                                .replace("/tmp0/wtpwebapps/ShareSphere/", "/ShareSphere/src/main/webapp/");
                        File srcDir = new File(srcPath + "images");
                        if (srcDir.exists()) {
                            File srcImgFile = new File(srcDir, uniqueFileName);
                            try (InputStream is = new FileInputStream(destFile);
                                 OutputStream os = new FileOutputStream(srcImgFile)) {
                                byte[] buf = new byte[4096];
                                int len;
                                while ((len = is.read(buf)) > 0) os.write(buf, 0, len);
                            }
                        }
                    } catch (Exception ignored) {}
                }
            }
        }

        String primaryImage = "default.png";
        String imagesJsonList = "";

        if (!savedImages.isEmpty()) {
            primaryImage = savedImages.get(0);
            imagesJsonList = String.join(",", savedImages);
        } else {
            imagesJsonList = "default.png";
        }

        // ── Insert into database ───────────────────────────────────────────
        try (Connection con = DBConnection.getConnection()) {
            if (con == null) {
                response.sendRedirect("addItem.jsp?error=Database+connection+failed.");
                return;
            }

            // Ensure images_json column exists
            try (Statement stmt = con.createStatement()) {
                stmt.executeUpdate("ALTER TABLE items ADD COLUMN images_json TEXT NULL");
            } catch (Exception ignored) {}

            try {
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO items (name, description, price, image, images_json, owner_email, category, offer_tag, stock_status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
                );
                ps.setString(1, name);
                ps.setString(2, description);
                ps.setDouble(3, Double.parseDouble(price));
                ps.setString(4, primaryImage);
                ps.setString(5, imagesJsonList);
                ps.setString(6, ownerEmail);
                ps.setString(7, category);
                ps.setString(8, offerTag);
                ps.setString(9, stockStatus);
                ps.executeUpdate();
                ps.close();
            } catch (Exception sqlEx) {
                System.err.println("⚠️ Insert with images_json failed, using fallback query: " + sqlEx.getMessage());
                PreparedStatement psFb = con.prepareStatement(
                    "INSERT INTO items (name, description, price, image, owner_email, category, offer_tag, stock_status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
                );
                psFb.setString(1, name);
                psFb.setString(2, description);
                psFb.setDouble(3, Double.parseDouble(price));
                psFb.setString(4, primaryImage);
                psFb.setString(5, ownerEmail);
                psFb.setString(6, category);
                psFb.setString(7, offerTag);
                psFb.setString(8, stockStatus);
                psFb.executeUpdate();
                psFb.close();
            }

            response.sendRedirect("myItems.jsp?msg=Product+with+" + savedImages.size() + "+photos+added+successfully!");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addItem.jsp?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}
