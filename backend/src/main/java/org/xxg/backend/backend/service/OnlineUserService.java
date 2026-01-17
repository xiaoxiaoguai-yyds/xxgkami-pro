package org.xxg.backend.backend.service;

import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 在线用户管理服务
 * 用于跟踪和管理当前在线的用户
 */
@Service
public class OnlineUserService {
    
    // 存储在线用户信息的Map，key为用户ID，value为用户在线信息
    private final Map<String, OnlineUser> onlineUsers = new ConcurrentHashMap<>();
    
    // 用户活动超时时间（分钟）
    private static final int TIMEOUT_MINUTES = 30;
    
    /**
     * 用户上线
     */
    public void userOnline(String userId, String username, String nickname, String sessionId, String ipAddress) {
        OnlineUser onlineUser = new OnlineUser();
        onlineUser.setUserId(userId);
        onlineUser.setUsername(username);
        onlineUser.setNickname(nickname);
        onlineUser.setSessionId(sessionId);
        onlineUser.setIpAddress(ipAddress);
        onlineUser.setLoginTime(LocalDateTime.now());
        onlineUser.setLastActiveTime(LocalDateTime.now());
        
        onlineUsers.put(userId, onlineUser);
    }
    
    /**
     * 用户下线
     */
    public void userOffline(String userId) {
        onlineUsers.remove(userId);
    }
    
    /**
     * 更新用户活动时间
     */
    public void updateUserActivity(String userId) {
        OnlineUser user = onlineUsers.get(userId);
        if (user != null) {
            user.setLastActiveTime(LocalDateTime.now());
        }
    }
    
    /**
     * 获取在线用户数量
     */
    public int getOnlineUserCount() {
        cleanupInactiveUsers();
        return onlineUsers.size();
    }
    
    /**
     * 获取所有在线用户列表
     */
    public List<OnlineUser> getOnlineUserList() {
        cleanupInactiveUsers();
        return new ArrayList<>(onlineUsers.values());
    }
    
    /**
     * 获取在线用户详细信息
     */
    public Map<String, Object> getOnlineUsersInfo() {
        cleanupInactiveUsers();
        
        Map<String, Object> result = new HashMap<>();
        result.put("onlineCount", onlineUsers.size());
        result.put("lastCheck", LocalDateTime.now());
        
        // 获取在线用户列表
        List<Map<String, Object>> userList = new ArrayList<>();
        for (OnlineUser user : onlineUsers.values()) {
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("userId", user.getUserId());
            userInfo.put("username", user.getUsername());
            userInfo.put("nickname", user.getNickname());
            userInfo.put("loginTime", user.getLoginTime());
            userInfo.put("lastActiveTime", user.getLastActiveTime());
            userInfo.put("ipAddress", user.getIpAddress());
            userList.add(userInfo);
        }
        
        result.put("onlineUsers", userList);
        return result;
    }
    
    /**
     * 检查用户是否在线
     */
    public boolean isUserOnline(String userId) {
        OnlineUser user = onlineUsers.get(userId);
        if (user == null) {
            return false;
        }
        
        // 检查是否超时
        LocalDateTime timeout = LocalDateTime.now().minusMinutes(TIMEOUT_MINUTES);
        if (user.getLastActiveTime().isBefore(timeout)) {
            onlineUsers.remove(userId);
            return false;
        }
        
        return true;
    }
    
    /**
     * 清理不活跃的用户
     */
    private void cleanupInactiveUsers() {
        LocalDateTime timeout = LocalDateTime.now().minusMinutes(TIMEOUT_MINUTES);
        onlineUsers.entrySet().removeIf(entry -> 
            entry.getValue().getLastActiveTime().isBefore(timeout)
        );
    }
    
    /**
     * 在线用户信息类
     */
    public static class OnlineUser {
        private String userId;
        private String username;
        private String nickname;
        private String sessionId;
        private String ipAddress;
        private LocalDateTime loginTime;
        private LocalDateTime lastActiveTime;
        
        // Getter和Setter方法
        public String getUserId() {
            return userId;
        }
        
        public void setUserId(String userId) {
            this.userId = userId;
        }
        
        public String getUsername() {
            return username;
        }
        
        public void setUsername(String username) {
            this.username = username;
        }
        
        public String getNickname() {
            return nickname;
        }
        
        public void setNickname(String nickname) {
            this.nickname = nickname;
        }
        
        public String getSessionId() {
            return sessionId;
        }
        
        public void setSessionId(String sessionId) {
            this.sessionId = sessionId;
        }
        
        public String getIpAddress() {
            return ipAddress;
        }
        
        public void setIpAddress(String ipAddress) {
            this.ipAddress = ipAddress;
        }
        
        public LocalDateTime getLoginTime() {
            return loginTime;
        }
        
        public void setLoginTime(LocalDateTime loginTime) {
            this.loginTime = loginTime;
        }
        
        public LocalDateTime getLastActiveTime() {
            return lastActiveTime;
        }
        
        public void setLastActiveTime(LocalDateTime lastActiveTime) {
            this.lastActiveTime = lastActiveTime;
        }
    }
}