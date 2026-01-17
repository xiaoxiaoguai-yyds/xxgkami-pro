package org.xxg.backend.backend.mapper;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.User;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 用户数据访问层
 */
@Repository
public class UserMapper {

    private final JdbcTemplate jdbcTemplate;

    public UserMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * 根据ID查找用户
     */
    public User findById(Long id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        List<User> users = jdbcTemplate.query(sql, new UserRowMapper(), id);
        return users.isEmpty() ? null : users.get(0);
    }

    /**
     * 根据用户名查找用户
     */
    public User findByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ? AND status = 1";
        List<User> users = jdbcTemplate.query(sql, new UserRowMapper(), username);
        return users.isEmpty() ? null : users.get(0);
    }

    /**
     * 根据邮箱查找用户
     */
    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ? AND status = 1";
        List<User> users = jdbcTemplate.query(sql, new UserRowMapper(), email);
        return users.isEmpty() ? null : users.get(0);
    }

    /**
     * 根据用户名或邮箱查找用户
     */
    public User findByUsernameOrEmail(String usernameOrEmail) {
        String sql = "SELECT * FROM users WHERE (username = ? OR email = ?) AND status = 1";
        List<User> users = jdbcTemplate.query(sql, new UserRowMapper(), usernameOrEmail, usernameOrEmail);
        return users.isEmpty() ? null : users.get(0);
    }

    /**
     * 查找所有用户
     */
    public List<User> findAll() {
        String sql = "SELECT * FROM users ORDER BY create_time DESC";
        return jdbcTemplate.query(sql, new UserRowMapper());
    }

    /**
     * 更新用户最后登录信息和Token
     */
    public void updateLastLogin(Long userId, String loginIp, String accessToken, String refreshToken) {
        String sql = "UPDATE users SET last_login_time = ?, last_login_ip = ?, login_count = login_count + 1, access_token = ?, refresh_token = ? WHERE id = ?";
        jdbcTemplate.update(sql, LocalDateTime.now(), loginIp, accessToken, refreshToken, userId);
    }

    /**
     * 清除用户Token（登出）
     */
    public void clearTokens(Long userId) {
        String sql = "UPDATE users SET access_token = NULL, refresh_token = NULL WHERE id = ?";
        jdbcTemplate.update(sql, userId);
    }

    /**
     * 更新用户Token
     */
    public void updateAccessToken(Long userId, String accessToken) {
        String sql = "UPDATE users SET access_token = ? WHERE id = ?";
        jdbcTemplate.update(sql, accessToken, userId);
    }

    /**
     * 更新用户密码
     */
    public void updatePassword(String username, String password) {
        String sql = "UPDATE users SET password = ? WHERE username = ?";
        jdbcTemplate.update(sql, password, username);
    }

    /**
     * 更新用户信息
     */
    public void updateUser(User user) {
        String sql = "UPDATE users SET nickname = ?, email = ?, phone = ?, avatar = ?, update_time = ? WHERE id = ?";
        jdbcTemplate.update(sql, user.getNickname(), user.getEmail(), user.getPhone(), user.getAvatar(), LocalDateTime.now(), user.getId());
    }

    /**
     * 插入新用户
     */
    public int insertUser(User user) {
        String sql = "INSERT INTO users (username, email, password, nickname, phone, email_verified, status, register_ip, create_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql, 
            user.getUsername(), 
            user.getEmail(), 
            user.getPassword(), 
            user.getNickname(),
            user.getPhone(),
            user.getEmailVerified(),
            user.getStatus(), 
            user.getRegisterIp(), 
            LocalDateTime.now()
        );
    }

    /**
     * 统计所有用户数量
     */
    public int countTotalUsers() {
        String sql = "SELECT COUNT(*) FROM users";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class);
        return count != null ? count : 0;
    }

    /**
     * 统计活跃用户（最近N天登录过）
     */
    public int countActiveUsers(int days) {
        String sql = "SELECT COUNT(*) FROM users WHERE last_login_time >= DATE_SUB(NOW(), INTERVAL ? DAY)";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, days);
        return count != null ? count : 0;
    }

    /**
     * 统计非活跃用户（最近N天未登录）
     */
    public int countInactiveUsers(int days) {
        String sql = "SELECT COUNT(*) FROM users WHERE last_login_time < DATE_SUB(NOW(), INTERVAL ? DAY) OR last_login_time IS NULL";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, days);
        return count != null ? count : 0;
    }

    /**
     * 用户行映射器
     */
    private static class UserRowMapper implements RowMapper<User> {
        @Override
        public User mapRow(ResultSet rs, int rowNum) throws SQLException {
            User user = new User();
            user.setId(rs.getLong("id"));
            user.setUsername(rs.getString("username"));
            user.setEmail(rs.getString("email"));
            user.setPassword(rs.getString("password"));
            user.setNickname(rs.getString("nickname"));
            user.setAvatar(rs.getString("avatar"));
            user.setPhone(rs.getString("phone"));
            user.setStatus(rs.getInt("status"));
            user.setEmailVerified(rs.getInt("email_verified"));
            
            // 处理可能为null的时间字段
            if (rs.getTimestamp("last_login_time") != null) {
                user.setLastLoginTime(rs.getTimestamp("last_login_time").toLocalDateTime());
            }
            
            user.setLastLoginIp(rs.getString("last_login_ip"));
            user.setLoginCount(rs.getInt("login_count"));
            user.setRegisterIp(rs.getString("register_ip"));
            
            if (rs.getTimestamp("create_time") != null) {
                user.setCreateTime(rs.getTimestamp("create_time").toLocalDateTime());
            }
            if (rs.getTimestamp("update_time") != null) {
                user.setUpdateTime(rs.getTimestamp("update_time").toLocalDateTime());
            }
            user.setAccessToken(rs.getString("access_token"));
            try {
                user.setRefreshToken(rs.getString("refresh_token"));
            } catch (SQLException e) {
                // Ignore
            }
            
            return user;
        }
    }
}