package org.xxg.backend.backend.mapper;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.Admin;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 管理员数据访问层
 */
@Repository
public class AdminMapper {

    private final JdbcTemplate jdbcTemplate;

    public AdminMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * 根据用户名查找管理员
     */
    public Admin findByUsername(String username) {
        String sql = "SELECT * FROM admins WHERE username = ?";
        List<Admin> admins = jdbcTemplate.query(sql, new AdminRowMapper(), username);
        return admins.isEmpty() ? null : admins.get(0);
    }

    /**
     * 更新管理员最后登录时间和Token
     */
    public void updateLastLogin(Long adminId, String accessToken, String refreshToken) {
        String sql = "UPDATE admins SET last_login = ?, access_token = ?, refresh_token = ? WHERE id = ?";
        jdbcTemplate.update(sql, LocalDateTime.now(), accessToken, refreshToken, adminId);
    }

    /**
     * 清除管理员Token（登出）
     */
    public void clearTokens(Long adminId) {
        String sql = "UPDATE admins SET access_token = NULL, refresh_token = NULL WHERE id = ?";
        jdbcTemplate.update(sql, adminId);
    }

    /**
     * 插入新管理员
     */
    public int insertAdmin(Admin admin) {
        String sql = "INSERT INTO admins (username, password, create_time) VALUES (?, ?, ?)";
        return jdbcTemplate.update(sql, 
            admin.getUsername(), 
            admin.getPassword(), 
            LocalDateTime.now()
        );
    }

    /**
     * 管理员行映射器
     */
    private static class AdminRowMapper implements RowMapper<Admin> {
        @Override
        public Admin mapRow(ResultSet rs, int rowNum) throws SQLException {
            Admin admin = new Admin();
            admin.setId(rs.getLong("id"));
            admin.setUsername(rs.getString("username"));
            admin.setPassword(rs.getString("password"));
            
            // 处理可能为null的时间字段
            if (rs.getTimestamp("create_time") != null) {
                admin.setCreateTime(rs.getTimestamp("create_time").toLocalDateTime());
            }
            if (rs.getTimestamp("last_login") != null) {
                admin.setLastLogin(rs.getTimestamp("last_login").toLocalDateTime());
            }
            admin.setAccessToken(rs.getString("access_token"));
            try {
                admin.setRefreshToken(rs.getString("refresh_token"));
            } catch (SQLException e) {
                // Ignore if column doesn't exist yet
            }
            
            return admin;
        }
    }
}