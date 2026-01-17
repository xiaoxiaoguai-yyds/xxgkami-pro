package org.xxg.backend.backend.mapper;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.Setting;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * 系统设置数据访问层
 */
@Repository
public class SettingsMapper {

    private final JdbcTemplate jdbcTemplate;

    public SettingsMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private final RowMapper<Setting> rowMapper = (rs, rowNum) -> {
        Setting setting = new Setting();
        setting.setId(rs.getInt("id"));
        setting.setName(rs.getString("name"));
        setting.setValue(rs.getString("value"));
        return setting;
    };

    /**
     * 获取所有设置
     */
    public List<Setting> findAll() {
        String sql = "SELECT * FROM settings";
        return jdbcTemplate.query(sql, rowMapper);
    }

    /**
     * 根据键名获取设置
     */
    public Setting findByName(String name) {
        String sql = "SELECT * FROM settings WHERE name = ?";
        try {
            return jdbcTemplate.queryForObject(sql, rowMapper, name);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    /**
     * 保存设置（存在则更新，不存在则插入）
     */
    public void save(String name, String value) {
        // MySQL specific: ON DUPLICATE KEY UPDATE
        // Assuming 'name' is UNIQUE in database schema as per kami.sql
        String sql = "INSERT INTO settings (name, value) VALUES (?, ?) " +
                     "ON DUPLICATE KEY UPDATE value = VALUES(value)";
        jdbcTemplate.update(sql, name, value);
    }
}
