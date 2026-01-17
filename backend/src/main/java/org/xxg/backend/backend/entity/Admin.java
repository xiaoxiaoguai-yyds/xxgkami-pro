package org.xxg.backend.backend.entity;

import java.time.LocalDateTime;

/**
 * 管理员实体类
 */
public class Admin {
    private Long id;
    private String username;
    private String password;
    private LocalDateTime createTime;
    private LocalDateTime lastLogin;
    private String accessToken;
    private String refreshToken;

    // 构造函数
    public Admin() {}

    public Admin(String username, String password) {
        this.username = username;
        this.password = password;
    }

    // Getter和Setter方法
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getLastLogin() {
        return lastLogin;
    }

    public void setLastLogin(LocalDateTime lastLogin) {
        this.lastLogin = lastLogin;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    @Override
    public String toString() {
        return "Admin{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", createTime=" + createTime +
                ", lastLogin=" + lastLogin +
                '}';
    }
}