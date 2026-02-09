package org.xxg.backend.backend.service;

import jakarta.mail.internet.MimeMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Properties;

/**
 * 邮件服务
 */
@Service
public class EmailService {

    private final SettingsService settingsService;

    public EmailService(SettingsService settingsService) {
        this.settingsService = settingsService;
    }

    /**
     * 获取设置值（优先使用覆盖配置）
     */
    private String getSettingValue(String key, Map<String, String> overrides) {
        if (overrides != null && overrides.containsKey(key)) {
            return overrides.get(key);
        }
        return settingsService.getSetting(key);
    }

    /**
     * 创建 JavaMailSender 实例
     */
    private JavaMailSender createMailSender(Map<String, String> overrides) {
        JavaMailSenderImpl mailSender = new JavaMailSenderImpl();
        
        String host = getSettingValue("smtp_server", overrides);
        String portStr = getSettingValue("smtp_port", overrides);
        String username = getSettingValue("smtp_email", overrides);
        String password = getSettingValue("smtp_password", overrides);
        String sslEnabled = getSettingValue("smtp_ssl", overrides); // Note: check key name consistency

        if (host == null || username == null || password == null) {
            throw new RuntimeException("邮件配置不完整 (Host: " + host + ", User: " + username + ")");
        }

        mailSender.setHost(host);
        try {
            mailSender.setPort(portStr != null && !portStr.isEmpty() ? Integer.parseInt(portStr) : 587);
        } catch (NumberFormatException e) {
            mailSender.setPort(587);
        }
        mailSender.setUsername(username);
        mailSender.setPassword(password);

        Properties props = mailSender.getJavaMailProperties();
        props.put("mail.transport.protocol", "smtp");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        
        if ("true".equals(sslEnabled)) {
             props.put("mail.smtp.ssl.enable", "true");
        }
        
        return mailSender;
    }

    /**
     * 发送验证码邮件
     */
    public void sendVerificationEmail(String to, String code, String type) {
        try {
            JavaMailSender mailSender = createMailSender(null);
            String senderName = getSettingValue("sender_name", null);
            String fromEmail = getSettingValue("smtp_email", null);
            
            if (senderName == null) senderName = "System";

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            String subject = "register".equals(type) ? "注册验证码 - XXG卡密系统" : "重置密码验证码 - XXG卡密系统";
            
            helper.setFrom(fromEmail, senderName);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(getVerificationEmailTemplate(senderName, code, type), true);
            
            mailSender.send(message);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("发送邮件失败: " + e.getMessage());
        }
    }

    public void sendMaintenanceEmail(String to, String subject, String content) {
        try {
            JavaMailSender mailSender = createMailSender(null);
            String senderName = getSettingValue("sender_name", null);
            String fromEmail = getSettingValue("smtp_email", null);
            
            if (senderName == null) senderName = "System";

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail, senderName);
            helper.setTo(to);
            helper.setSubject(subject);
            
            // Wrap content in a beautiful HTML template
            String htmlContent = getBeautifulEmailTemplate(senderName, subject, content);
            helper.setText(htmlContent, true);
            
            mailSender.send(message);
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Failed to send maintenance email to " + to + ": " + e.getMessage());
            // Don't throw exception to avoid stopping the loop
        }
    }

    private String getBeautifulEmailTemplate(String senderName, String title, String content) {
        return "<!DOCTYPE html>" +
               "<html>" +
               "<head>" +
               "<meta charset='utf-8'>" +
               "<style>" +
               "body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }" +
               ".container { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); margin-top: 40px; margin-bottom: 40px; }" +
               ".header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #ffffff; padding: 30px; text-align: center; }" +
               ".header h1 { margin: 0; font-size: 24px; font-weight: 600; }" +
               ".content { padding: 40px; color: #333333; line-height: 1.6; }" +
               ".footer { background-color: #f8f9fa; padding: 20px; text-align: center; color: #999999; font-size: 12px; }" +
               ".highlight { color: #667eea; font-weight: bold; }" +
               "</style>" +
               "</head>" +
               "<body>" +
               "<div class='container'>" +
               "<div class='header'>" +
               "<h1>" + title + "</h1>" +
               "</div>" +
               "<div class='content'>" +
               content +
               "</div>" +
               "<div class='footer'>" +
               "<p>此邮件由系统自动发送，请勿回复。</p>" +
               "<p>&copy; " + java.time.Year.now().getValue() + " " + senderName + ". All rights reserved.</p>" +
               "</div>" +
               "</div>" +
               "</body>" +
               "</html>";
    }

    private String getVerificationEmailTemplate(String senderName, String code, String type) {
        String currentYear = String.valueOf(java.time.Year.now().getValue());
        String title = "register".equals(type) ? "注册验证码" : "重置密码验证码";
        String description = "register".equals(type) 
            ? "您正在注册 XXG 卡密系统账号，请使用以下验证码完成注册。" 
            : "您正在申请重置 XXG 卡密系统的登录密码，请使用以下验证码完成重置。";

        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f4f4f7; color: #51545e; margin: 0; padding: 0; }
                    .email-wrapper { width: 100%%; background-color: #f4f4f7; padding: 40px 20px; }
                    .email-content { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
                    .email-header { background: linear-gradient(135deg, #6366f1 0%%, #4f46e5 100%%); padding: 30px; text-align: center; color: #ffffff; }
                    .email-header h1 { margin: 0; font-size: 24px; font-weight: bold; letter-spacing: 1px; }
                    .email-body { padding: 40px; }
                    .email-body h2 { margin-top: 0; color: #1f2937; font-size: 20px; font-weight: 600; }
                    .email-body p { line-height: 1.6; color: #4b5563; margin-bottom: 16px; }
                    .code-box { background-color: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 6px; padding: 16px; margin: 24px 0; text-align: center; }
                    .code-text { color: #166534; font-weight: 700; font-size: 24px; letter-spacing: 4px; }
                    .email-footer { background-color: #f9fafb; padding: 24px; text-align: center; font-size: 12px; color: #9ca3af; border-top: 1px solid #e5e7eb; }
                </style>
            </head>
            <body>
                <div class="email-wrapper">
                    <div class="email-content">
                        <div class="email-header">
                            <h1>XXG 卡密系统</h1>
                        </div>
                        <div class="email-body">
                            <h2>%s</h2>
                            <p>您好：</p>
                            <p>%s 验证码有效期为 5 分钟。</p>
                            
                            <div class="code-box">
                                <div class="code-text">%s</div>
                            </div>
                            
                            <p>如果您没有请求此验证码，请忽略此邮件。</p>
                        </div>
                        <div class="email-footer">
                            <p>&copy; %s XXG Kami System. All rights reserved.</p>
                            <p>此邮件由系统自动发送，请勿回复。</p>
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(title, description, code, senderName, currentYear);
    }

    /**
     * 发送注册成功通知
     */
    public void sendRegistrationSuccess(String to) {
        try {
            String notifyEnabled = settingsService.getSetting("notify_user_reg");
            if (!"true".equals(notifyEnabled)) {
                return;
            }

            JavaMailSender mailSender = createMailSender(null);
            String senderName = getSettingValue("sender_name", null);
            String fromEmail = getSettingValue("smtp_email", null);
            
            if (senderName == null) senderName = "System";

            String content = settingsService.getSetting("tpl_user_reg");
            if (content == null || content.isEmpty()) {
                content = "欢迎注册XXG卡密系统！您的账户已成功创建。";
            }

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail, senderName);
            helper.setTo(to);
            helper.setSubject("注册成功 - " + senderName);
            helper.setText(getCommonEmailTemplate("注册成功", content, senderName), true);
            
            mailSender.send(message);
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Failed to send registration success email: " + e.getMessage());
        }
    }

    /**
     * 发送订单通知
     */
    public void sendOrderNotification(String to, String orderNo) {
        String notifyEnabled = settingsService.getSetting("notify_order_create");
        // Default to true if not set (null), otherwise respect the setting
        if ("false".equals(notifyEnabled)) {
            return;
        }

        try {
            JavaMailSender mailSender = createMailSender(null);
            String senderName = getSettingValue("sender_name", null);
            String fromEmail = getSettingValue("smtp_email", null);
            
            if (senderName == null) senderName = "System";

            String contentTemplate = settingsService.getSetting("tpl_order_notify");
            if (contentTemplate == null || contentTemplate.isEmpty()) {
                contentTemplate = "您的订单已创建成功，订单号：{orderNumber}，请及时查看。";
            }
            
            String content = contentTemplate.replace("{orderNumber}", orderNo);

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail, senderName);
            helper.setTo(to);
            helper.setSubject("订单通知 - " + senderName);
            helper.setText(getCommonEmailTemplate("订单通知", content, senderName), true);
            
            mailSender.send(message);
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Failed to send order notification email: " + e.getMessage());
        }
    }

    /**
     * 发送卡密使用通知
     */
    public void sendCardUsedNotification(String to, String cardKey, String usageTime) {
        String notifyEnabled = settingsService.getSetting("notify_key_used");
        // 默认为 true，除非显式设置为 false
        if ("false".equals(notifyEnabled)) {
            return;
        }

        try {
            JavaMailSender mailSender = createMailSender(null);
            String senderName = getSettingValue("sender_name", null);
            String fromEmail = getSettingValue("smtp_email", null);
            
            if (senderName == null) senderName = "System";

            String content = String.format("您的卡密 %s 已于 %s 被使用。", cardKey, usageTime);

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail, senderName);
            helper.setTo(to);
            helper.setSubject("卡密使用通知 - " + senderName);
            helper.setText(getCommonEmailTemplate("卡密使用通知", content, senderName), true);
            
            mailSender.send(message);
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Failed to send card usage notification: " + e.getMessage());
        }
    }

    private String getCommonEmailTemplate(String title, String content, String senderName) {
        String currentYear = String.valueOf(java.time.Year.now().getValue());
        
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f4f4f7; color: #51545e; margin: 0; padding: 0; }
                    .email-wrapper { width: 100%%; background-color: #f4f4f7; padding: 40px 20px; }
                    .email-content { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
                    .email-header { background: linear-gradient(135deg, #6366f1 0%%, #4f46e5 100%%); padding: 30px; text-align: center; color: #ffffff; }
                    .email-header h1 { margin: 0; font-size: 24px; font-weight: bold; letter-spacing: 1px; }
                    .email-body { padding: 40px; }
                    .email-body h2 { margin-top: 0; color: #1f2937; font-size: 20px; font-weight: 600; }
                    .email-body p { line-height: 1.6; color: #4b5563; margin-bottom: 16px; }
                    .email-footer { background-color: #f9fafb; padding: 24px; text-align: center; font-size: 12px; color: #9ca3af; border-top: 1px solid #e5e7eb; }
                </style>
            </head>
            <body>
                <div class="email-wrapper">
                    <div class="email-content">
                        <div class="email-header">
                            <h1>XXG 卡密系统</h1>
                        </div>
                        <div class="email-body">
                            <h2>%s</h2>
                            <p>%s</p>
                        </div>
                        <div class="email-footer">
                            <p>&copy; %s %s. All rights reserved.</p>
                            <p>此邮件由系统自动发送，请勿回复。</p>
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(title, content, currentYear, senderName);
    }

    /**
     * 发送测试邮件
     */
    public void sendTestEmail(String to, Map<String, String> configOverrides) {
        try {
            JavaMailSender mailSender = createMailSender(configOverrides);
            String senderName = getSettingValue("sender_name", configOverrides);
            String fromEmail = getSettingValue("smtp_email", configOverrides);
            
            if (senderName == null) senderName = "System";

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(fromEmail, senderName);
            helper.setTo(to);
            helper.setSubject("测试邮件 - XXG卡密系统");
            helper.setText(getTestEmailTemplate(senderName), true);
            
            mailSender.send(message);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("发送邮件失败: " + e.getMessage());
        }
    }

    private String getTestEmailTemplate(String senderName) {
        String currentYear = String.valueOf(java.time.Year.now().getValue());
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <style>
                    body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f4f4f7; color: #51545e; margin: 0; padding: 0; }
                    .email-wrapper { width: 100%%; background-color: #f4f4f7; padding: 40px 20px; }
                    .email-content { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
                    .email-header { background: linear-gradient(135deg, #6366f1 0%%, #4f46e5 100%%); padding: 30px; text-align: center; color: #ffffff; }
                    .email-header h1 { margin: 0; font-size: 24px; font-weight: bold; letter-spacing: 1px; }
                    .email-body { padding: 40px; }
                    .email-body h2 { margin-top: 0; color: #1f2937; font-size: 20px; font-weight: 600; }
                    .email-body p { line-height: 1.6; color: #4b5563; margin-bottom: 16px; }
                    .status-box { background-color: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 6px; padding: 16px; margin: 24px 0; text-align: center; }
                    .status-text { color: #166534; font-weight: 600; font-size: 16px; display: flex; align-items: center; justify-content: center; gap: 8px; }
                    .email-footer { background-color: #f9fafb; padding: 24px; text-align: center; font-size: 12px; color: #9ca3af; border-top: 1px solid #e5e7eb; }
                </style>
            </head>
            <body>
                <div class="email-wrapper">
                    <div class="email-content">
                        <div class="email-header">
                            <h1>XXG 卡密系统</h1>
                        </div>
                        <div class="email-body">
                            <h2>邮件服务配置测试</h2>
                            <p>您好，%s：</p>
                            <p>这是一封来自 XXG 卡密系统的测试邮件。如果您看到了这封邮件，说明您的邮件服务配置（SMTP）已正确设置并可以正常工作。</p>
                            
                            <div class="status-box">
                                <div class="status-text">
                                    <span>✅</span>
                                    <span>配置验证成功</span>
                                </div>
                            </div>
                            
                            <p>您现在可以放心地在系统中使用邮件通知功能了。系统将通过此配置发送重要的业务通知。</p>
                        </div>
                        <div class="email-footer">
                            <p>&copy; %s XXG Kami System. All rights reserved.</p>
                            <p>此邮件由系统自动发送，请勿回复。</p>
                        </div>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(senderName, currentYear);
    }
}
