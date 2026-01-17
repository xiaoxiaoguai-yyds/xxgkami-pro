package org.xxg.backend.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.service.OnlineUserService;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * 在线用户管理控制器
 */
@RestController
@RequestMapping("/online")
public class OnlineUserController {

    @Autowired
    private OnlineUserService onlineUserService;

    /**
     * 用户上线
     */
    @PostMapping("/login")
    public ResponseEntity<String> userLogin(@RequestBody Map<String, String> request, HttpServletRequest httpRequest) {
        try {
            String userId = request.get("userId");
            String username = request.get("username");
            String nickname = request.get("nickname");
            String sessionId = httpRequest.getSession().getId();
            String ipAddress = getClientIpAddress(httpRequest);
            
            onlineUserService.userOnline(userId, username, nickname, sessionId, ipAddress);
            
            return ResponseEntity.ok()
                .header("Content-Type", "text/plain;charset=UTF-8")
                .body("用户上线成功");
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                .header("Content-Type", "text/plain;charset=UTF-8")
                .body("用户上线失败: " + e.getMessage());
        }
    }

    /**
     * 用户下线
     */
    @PostMapping("/logout")
    public ResponseEntity<String> userLogout(@RequestBody Map<String, String> request) {
        try {
            String userId = request.get("userId");
            onlineUserService.userOffline(userId);
            
            return ResponseEntity.ok("用户下线成功");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("用户下线失败: " + e.getMessage());
        }
    }

    /**
     * 更新用户活动时间
     */
    @PostMapping("/heartbeat")
    public ResponseEntity<String> updateActivity(@RequestBody Map<String, String> request) {
        try {
            String userId = request.get("userId");
            onlineUserService.updateUserActivity(userId);
            
            return ResponseEntity.ok("活动时间更新成功");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("活动时间更新失败: " + e.getMessage());
        }
    }

    /**
     * 检查用户是否在线
     */
    @GetMapping("/check/{userId}")
    public ResponseEntity<Map<String, Object>> checkUserOnline(@PathVariable String userId) {
        try {
            boolean isOnline = onlineUserService.isUserOnline(userId);
            return ResponseEntity.ok(Map.of("userId", userId, "isOnline", isOnline));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取在线用户列表
     */
    @GetMapping("/list")
    public ResponseEntity<Map<String, Object>> getOnlineUserList() {
        try {
            Map<String, Object> onlineInfo = onlineUserService.getOnlineUsersInfo();
            return ResponseEntity.ok(onlineInfo);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取客户端IP地址
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty() && !"unknown".equalsIgnoreCase(xForwardedFor)) {
            return xForwardedFor.split(",")[0];
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty() && !"unknown".equalsIgnoreCase(xRealIp)) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
}