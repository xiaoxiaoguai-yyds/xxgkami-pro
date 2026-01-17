package org.xxg.backend.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.dto.LoginResponse;
import org.xxg.backend.backend.entity.MaintenanceSettings;
import org.xxg.backend.backend.service.MaintenanceService;

import java.util.Map;

@RestController
@RequestMapping("/maintenance")
public class MaintenanceController {

    @Autowired
    private MaintenanceService maintenanceService;

    @GetMapping("/status")
    public LoginResponse getStatus() {
        try {
            MaintenanceSettings settings = maintenanceService.getSettings();
            return LoginResponse.success("获取成功", settings);
        } catch (Exception e) {
            return LoginResponse.error("获取失败: " + e.getMessage());
        }
    }

    @PostMapping("/update")
    public LoginResponse updateSettings(@RequestBody MaintenanceSettings settings) {
        try {
            maintenanceService.updateSettings(settings);
            return LoginResponse.success("更新成功", null);
        } catch (Exception e) {
            return LoginResponse.error("更新失败: " + e.getMessage());
        }
    }

    @RequestMapping(value = "/clear-cache", method = {RequestMethod.GET, RequestMethod.POST})
    public LoginResponse clearCache() {
        try {
            maintenanceService.clearCache();
            return LoginResponse.success("缓存清理成功", null);
        } catch (Exception e) {
            return LoginResponse.error("缓存清理失败: " + e.getMessage());
        }
    }

    @RequestMapping(value = "/clear-logs", method = {RequestMethod.GET, RequestMethod.POST})
    public LoginResponse clearLogs() {
        try {
            maintenanceService.clearLogs();
            return LoginResponse.success("日志清理成功", null);
        } catch (Exception e) {
            return LoginResponse.error("日志清理失败: " + e.getMessage());
        }
    }
}
