package org.xxg.backend.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.service.SystemMonitorService;

import java.util.Map;

/**
 * 系统监控控制器
 */
@RestController
@RequestMapping("/monitor")
public class SystemMonitorController {

    @Autowired
    private SystemMonitorService systemMonitorService;

    /**
     * 获取数据库状态信息
     */
    @GetMapping("/database")
    public ResponseEntity<Map<String, Object>> getDatabaseStatus() {
        try {
            Map<String, Object> databaseStatus = systemMonitorService.getDatabaseStatus();
            return ResponseEntity.ok(databaseStatus);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取系统资源状态
     */
    @GetMapping("/system")
    public ResponseEntity<Map<String, Object>> getSystemStatus() {
        try {
            Map<String, Object> systemStatus = systemMonitorService.getSystemStatus();
            return ResponseEntity.ok(systemStatus);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取API服务状态
     */
    @GetMapping("/api")
    public ResponseEntity<Map<String, Object>> getApiStatus() {
        try {
            Map<String, Object> apiStatus = systemMonitorService.getApiStatus();
            return ResponseEntity.ok(apiStatus);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取在线用户信息
     */
    @GetMapping("/users")
    public ResponseEntity<Map<String, Object>> getOnlineUsers() {
        try {
            Map<String, Object> onlineUsers = systemMonitorService.getOnlineUsers();
            return ResponseEntity.ok(onlineUsers);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取所有监控数据
     */
    @GetMapping("/all")
    public ResponseEntity<Map<String, Object>> getAllMonitorData() {
        try {
            Map<String, Object> allData = systemMonitorService.getAllMonitorData();
            return ResponseEntity.ok(allData);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 检查更新
     */
    @GetMapping("/check-update")
    public ResponseEntity<?> checkUpdate() {
        try {
            String url = "https://gitee.com/xiaoxiaoguai-yyds/xxgkami-pro/raw/master/public/version.json";
            org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate();
            String result = restTemplate.getForObject(url, String.class);
            // Parse JSON manually or return string directly. 
            // Since we need to return JSON, returning string with proper content type or parsing it is fine.
            // Let's return the raw string, but set content type to application/json
            return ResponseEntity.ok()
                .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
                .body(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of("error", "检查更新失败: " + e.getMessage()));
        }
    }
}