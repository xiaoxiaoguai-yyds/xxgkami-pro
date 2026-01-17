package org.xxg.backend.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.service.EmailService;
import org.xxg.backend.backend.service.SettingsService;

import java.util.Map;

/**
 * 系统设置控制器
 */
@RestController
@RequestMapping("/settings")
public class SettingsController {

    private final SettingsService settingsService;
    private final EmailService emailService;

    public SettingsController(SettingsService settingsService, EmailService emailService) {
        this.settingsService = settingsService;
        this.emailService = emailService;
    }

    /**
     * 获取所有设置
     */
    @GetMapping("/all")
    public ResponseEntity<Map<String, String>> getAllSettings() {
        return ResponseEntity.ok(settingsService.getAllSettings());
    }

    /**
     * 批量保存设置
     */
    @PostMapping("/save")
    public ResponseEntity<String> saveSettings(@RequestBody Map<String, String> settings) {
        try {
            settingsService.saveSettings(settings);
            return ResponseEntity.ok("Settings saved successfully");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Failed to save settings: " + e.getMessage());
        }
    }

    /**
     * 发送测试邮件
     */
    @PostMapping("/email/test")
    public ResponseEntity<String> sendTestEmail(@RequestBody Map<String, String> request) {
        String to = request.get("to");
        if (to == null || to.isEmpty()) {
            return ResponseEntity.badRequest().body("Recipient email is required");
        }
        
        // 允许从请求中传入临时配置用于测试
        // 移除 to 字段，剩下的即为配置
        Map<String, String> configOverrides = new java.util.HashMap<>(request);
        configOverrides.remove("to");
        
        try {
            emailService.sendTestEmail(to, configOverrides);
            return ResponseEntity.ok("Test email sent successfully");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Failed to send test email: " + e.getMessage());
        }
    }
}
