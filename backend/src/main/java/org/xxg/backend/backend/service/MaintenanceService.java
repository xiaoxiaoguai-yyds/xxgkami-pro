package org.xxg.backend.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.xxg.backend.backend.entity.MaintenanceSettings;
import org.xxg.backend.backend.entity.User;
import org.xxg.backend.backend.mapper.MaintenanceMapper;
import org.xxg.backend.backend.mapper.UserMapper;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Stream;

@Service
public class MaintenanceService {

    @Autowired
    private MaintenanceMapper maintenanceMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private EmailService emailService;

    @Autowired
    private SettingsService settingsService;

    public MaintenanceSettings getSettings() {
        return maintenanceMapper.getSettings();
    }

    public void updateSettings(MaintenanceSettings settings) {
        MaintenanceSettings oldSettings = maintenanceMapper.getSettings();
        maintenanceMapper.updateSettings(settings);

        // Check if enabled changed from false to true
        if (!oldSettings.getEnabled() && settings.getEnabled()) {
            sendMaintenanceNotifications(settings);
        }
    }

    private void sendMaintenanceNotifications(MaintenanceSettings settings) {
        CompletableFuture.runAsync(() -> {
            try {
                List<User> users = userMapper.findAll();
                String systemName = settingsService.getSetting("systemName");
                if (systemName == null) systemName = "XXG卡密系统";

                String subject = settings.getEmailSubject();
                if (subject == null || subject.isEmpty()) subject = "系统维护通知";

                String template = settings.getEmailTemplate();
                if (template == null || template.isEmpty()) {
                    template = "系统将于 {time} 进行维护，请提前做好准备。";
                }

                for (User user : users) {
                    if (user.getEmail() != null && !user.getEmail().isEmpty()) {
                        // Format: 系统名称，用户名+你好，系统将于时间进行维护，请等待系统维护完成后继续使用！
                        // Actually the user wants the template to be customizable from DB but fixed format.
                        // I will replace placeholders in the template.
                        
                        String content = template
                                .replace("{username}", user.getUsername())
                                .replace("{time}", settings.getStartTime() != null ? settings.getStartTime() : "近期")
                                .replace("{startTime}", settings.getStartTime() != null ? settings.getStartTime() : "")
                                .replace("{duration}", settings.getMaintenanceTime() != null ? settings.getMaintenanceTime() : "未知时长")
                                .replace("{systemName}", systemName);

                        // If the template doesn't contain the greeting, prepend it as per user request example
                        // "系统名称，用户名+你好，"
                        // But if the template in DB is full, we assume it has placeholders.
                        // Let's assume the template string in DB is just the message part.
                        
                        // Let's construct the full message as requested:
                        // "系统名称，用户名+你好，" + template content
                        
                        StringBuilder messageBuilder = new StringBuilder();
                        messageBuilder.append("<p>").append(systemName).append("，").append(user.getUsername()).append(" 你好，</p>");
                        messageBuilder.append("<p>").append(content).append("</p>");
                        messageBuilder.append("<p>请等待系统维护完成后继续使用！</p>");
                        
                        emailService.sendMaintenanceEmail(user.getEmail(), subject, messageBuilder.toString());
                        
                        // Sleep to avoid flooding (sequential sending)
                        try {
                            Thread.sleep(2000); // 2 seconds delay
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    public void clearCache() {
        // Clear temp directory (example implementation)
        // You might want to clear Spring Cache or specific temp folders
        String tempDir = "uploads/temp";
        deleteDirectoryContents(tempDir);
        System.out.println("Cache cleared");
    }

    public void clearLogs() {
        // Clear logs directory
        String logsDir = "logs";
        deleteDirectoryContents(logsDir);
        System.out.println("Logs cleared");
    }

    private void deleteDirectoryContents(String dirPath) {
        File directory = new File(dirPath);
        if (directory.exists() && directory.isDirectory()) {
            File[] files = directory.listFiles();
            if (files != null) {
                for (File file : files) {
                    if (file.isFile()) {
                        // Skip deleting the current log file if it's locked (common in Windows)
                        // or just try to delete and ignore failure
                        if (!file.getName().equals("backend.log")) { 
                             try {
                                 file.delete();
                             } catch (Exception e) {
                                 System.err.println("Failed to delete file: " + file.getName());
                             }
                        }
                    }
                }
            }
        }
    }
}
