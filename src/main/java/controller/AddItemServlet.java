package controller;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;
import util.DBConnection;

@WebServlet("/AddItemServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5 MB max
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
        String price       = request.getParameter("price");
        String category    = request.getParameter("category");
        String ownerEmail  = (String) session.getAttribute("userEmail");

        // ── Handle uploaded image ──────────────────────────────────────────
        String fileName = "default.png"; // fallback
        Part filePart = request.getPart("image");

        if (filePart != null && filePart.getSize() > 0) {
            String submitted = filePart.getSubmittedFileName();
            if (submitted != null && !submitted.trim().isEmpty()) {
                // sanitize: keep only the simple filename, no path traversal
                fileName = new File(submitted).getName();

                // 1️⃣ Save to the DEPLOYED images folder (served immediately)
                String deployedPath = getServletContext().getRealPath("/images");
                File deployDir = new File(deployedPath);
                if (!deployDir.exists()) deployDir.mkdirs();
                filePart.write(deployedPath + File.separator + fileName);

                // 2️⃣ Also copy to SOURCE images folder (survives redeployment)
                try {
                    String srcPath = getServletContext().getRealPath("/")
                            .replace("\\tmp0\\wtpwebapps\\ShareSphere\\", "\\ShareSphere\\src\\main\\webapp\\")
                            .replace("/tmp0/wtpwebapps/ShareSphere/", "/ShareSphere/src/main/webapp/");
                    File srcDir = new File(srcPath + "images");
                    if (srcDir.exists()) {
                        File srcImgFile = new File(srcDir, fileName);
                        File deployedImgFile = new File(deployedPath, fileName);
                        if (!srcImgFile.exists()) {
                            InputStream is = new FileInputStream(deployedImgFile);
                            OutputStream os = new FileOutputStream(srcImgFile);
                            byte[] buf = new byte[4096];
                            int len;
                            while ((len = is.read(buf)) > 0) os.write(buf, 0, len);
                            is.close(); os.close();
                        }
                    }
                } catch (Exception ignored) {
                    // Copy to source is best-effort only
                }
            }
        }

        // ── Insert into database ───────────────────────────────────────────
        Connection con = null;
        try {
            con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO items (name, description, price, image, owner_email, category) " +
                "VALUES (?, ?, ?, ?, ?, ?)"
            );
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setDouble(3, Double.parseDouble(price));
            ps.setString(4, fileName);
            ps.setString(5, ownerEmail);
            ps.setString(6, category);
            ps.executeUpdate();
            ps.close();

            response.sendRedirect("myItems.jsp?msg=Item+added+successfully!");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addItem.jsp?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } finally {
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
