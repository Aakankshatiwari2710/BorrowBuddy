package util;

import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailUtil {

    // Default Email Configurations for SpanV Studios
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SENDER_EMAIL = "spandanav2606@gmail.com";
    private static final String SENDER_PASSWORD = "asucwkpwwkxcjhoe";
    private static final String SENDER_NAME = "SpanV Studios";

    // Async thread pool so web requests never lag
    private static final ExecutorService executor = Executors.newFixedThreadPool(3);

    /**
     * Send HTML email in background thread
     */
    public static void sendEmailAsync(final String toEmail, final String subject, final String htmlContent) {
        if (toEmail == null || toEmail.trim().isEmpty()) return;

        executor.submit(() -> {
            try {
                sendEmailSync(toEmail, subject, htmlContent);
            } catch (Exception e) {
                System.err.println("📧 [JavaMail Failed] Target: " + toEmail + " | Subject: " + subject + " | Error: " + e.getMessage());
                e.printStackTrace();
            }
        });
    }

    /**
     * Send email synchronously
     */
    public static void sendEmailSync(String toEmail, String subject, String htmlContent) throws Exception {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL, SENDER_NAME));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setContent(htmlContent, "text/html; charset=utf-8");

        Transport.send(message);
        System.out.println("✅ [JavaMail] Email successfully sent to: " + toEmail);
    }

    // Helper HTML Templates for SpanV Studios
    public static String buildWelcomeTemplate(String userName) {
        return "<div style='font-family: Arial, sans-serif; padding: 20px; background-color: #fff1f2; border-radius: 12px;'>"
             + "  <h2 style='color: #be185d;'>Welcome to SpanV Studios, " + userName + "! ✨</h2>"
             + "  <p style='color: #334155; font-size: 15px;'>Thank you for joining our premium ethnic fashion boutique. Discover handcrafted sarees, kurtis, lehengas, and designer fabrics.</p>"
             + "  <p style='color: #64748b; font-size: 13px;'>If you have any questions, feel free to reach out to us at spandanav2606@gmail.com or +91 7899978229.</p>"
             + "  <hr style='border: none; border-top: 1px solid #fbcfe8; margin: 20px 0;'/>"
             + "  <small style='color: #94a3b8;'>SpanV Studios • Celebrating Your Elegance</small>"
             + "</div>";
    }

    public static String buildOrderReceiptTemplate(String itemName, double amount, String utrRef, String deliveryAddress) {
        return "<div style='font-family: Arial, sans-serif; padding: 20px; background-color: #fff1f2; border-radius: 12px;'>"
             + "  <h2 style='color: #be185d;'>Order Receipt & Delivery Summary 🛍️</h2>"
             + "  <p style='color: #334155;'>Thank you for your purchase! We have received your payment details.</p>"
             + "  <table style='width: 100%; border-collapse: collapse; margin: 15px 0; background: white; border-radius: 8px; overflow: hidden;'>"
             + "    <tr style='background: #fdf2f8;'><td style='padding: 10px; font-weight: bold;'>Product:</td><td style='padding: 10px;'>" + itemName + "</td></tr>"
             + "    <tr><td style='padding: 10px; font-weight: bold;'>Amount Paid:</td><td style='padding: 10px;'>₹" + (int)amount + "</td></tr>"
             + "    <tr style='background: #fdf2f8;'><td style='padding: 10px; font-weight: bold;'>UTR Ref Number:</td><td style='padding: 10px;'>" + utrRef + "</td></tr>"
             + "    <tr><td style='padding: 10px; font-weight: bold;'>Delivery Address:</td><td style='padding: 10px;'>" + deliveryAddress + "</td></tr>"
             + "  </table>"
             + "  <p style='color: #059669; font-weight: bold;'>Status: Pending Owner Verification</p>"
             + "  <hr style='border: none; border-top: 1px solid #fbcfe8; margin: 20px 0;'/>"
             + "  <small style='color: #94a3b8;'>SpanV Studios • Instagram @spanv_studios</small>"
             + "</div>";
    }

    public static String buildOrderConfirmedTemplate(int bookingId, String custName, String itemName, double price, String address, String city, String pincode, String phone, String utrNote) {
        String fullAddr = (address != null && !address.trim().isEmpty()) 
                          ? (address + (city != null && !city.isEmpty() ? ", " + city : "") + (pincode != null && !pincode.isEmpty() ? " - " + pincode : "")) 
                          : "Standard Delivery Address";
        if (phone != null && !phone.trim().isEmpty()) {
            fullAddr += " | Phone: " + phone;
        }

        return "<div style='font-family: Arial, sans-serif; padding: 25px; background-color: #f0fdf4; border-radius: 16px; border: 1px solid #bbf7d0; max-width: 550px; margin: 0 auto;'>"
             + "  <h2 style='color: #166534; margin-top: 0;'>Order & Payment Confirmed! 🎉</h2>"
             + "  <p style='color: #15803d; font-weight: bold; font-size: 15px;'>Hello " + (custName != null ? custName : "Valued Customer") + ", SpanV Studios has approved your order!</p>"
             + "  <div style='background: white; border-radius: 12px; padding: 18px; border: 1px solid #dcfce7; margin: 20px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.04);'>"
             + "    <table style='width: 100%; border-collapse: collapse; font-size: 14px; color: #1e293b;'>"
             + "      <tr style='border-bottom: 1px dashed #e2e8f0;'><td style='padding: 10px 0; color: #64748b;'>Order ID:</td><td style='padding: 10px 0; font-weight: bold; text-align: right;'>#" + bookingId + "</td></tr>"
             + "      <tr style='border-bottom: 1px dashed #e2e8f0;'><td style='padding: 10px 0; color: #64748b;'>Product Name:</td><td style='padding: 10px 0; font-weight: bold; text-align: right; color: #be185d;'>" + itemName + "</td></tr>"
             + "      <tr style='border-bottom: 1px dashed #e2e8f0;'><td style='padding: 10px 0; color: #64748b;'>Amount Paid:</td><td style='padding: 10px 0; font-weight: bold; text-align: right; color: #059669;'>₹" + (int)price + "</td></tr>"
             + "      <tr style='border-bottom: 1px dashed #e2e8f0;'><td style='padding: 10px 0; color: #64748b;'>Payment Status:</td><td style='padding: 10px 0; font-weight: bold; text-align: right; color: #166534;'>✅ VERIFIED & PAID</td></tr>"
             + "      <tr><td style='padding: 10px 0; color: #64748b;'>Delivery Address:</td><td style='padding: 10px 0; font-weight: 500; text-align: right;'>" + fullAddr + "</td></tr>"
             + "    </table>"
             + "  </div>"
             + "  <p style='color: #334155; font-size: 14px;'>Your designer piece is now being prepared for dispatch. Thank you for shopping with SpanV Studios!</p>"
             + "  <hr style='border: none; border-top: 1px solid #bbf7d0; margin: 20px 0;'/>"
             + "  <small style='color: #15803d;'>SpanV Studios • Instagram @spanv_studios • Support: +91 7899978229</small>"
             + "</div>";
    }

    public static String buildOtpEmailTemplate(String userName, String otpCode) {
        return "<div style='font-family: Arial, sans-serif; padding: 25px; background-color: #fff1f2; border-radius: 16px; max-width: 500px; margin: 0 auto; border: 1px solid #fbcfe8;'>"
             + "  <h2 style='color: #be185d; margin-top: 0;'>🔐 Verify Your Email Address</h2>"
             + "  <p style='color: #334155; font-size: 15px;'>Hello <strong>" + userName + "</strong>,</p>"
             + "  <p style='color: #334155; font-size: 15px;'>Thank you for registering with <strong>SpanV Studios</strong>. Please use the 6-digit OTP verification code below to complete your registration:</p>"
             + "  <div style='text-align: center; margin: 25px 0;'>"
             + "    <span style='font-size: 32px; font-weight: 800; color: #be185d; letter-spacing: 8px; background: white; padding: 12px 28px; border-radius: 12px; border: 2px dashed #db2777; display: inline-block;'>" + otpCode + "</span>"
             + "  </div>"
             + "  <p style='color: #64748b; font-size: 13px;'>This OTP code is valid for account activation. If you did not request this code, please ignore this email.</p>"
             + "  <hr style='border: none; border-top: 1px solid #fbcfe8; margin: 20px 0;'/>"
             + "  <small style='color: #94a3b8;'>SpanV Studios • Instagram @spanv_studios</small>"
             + "</div>";
    }
}
