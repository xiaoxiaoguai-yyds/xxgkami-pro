package org.xxg.backend.backend.mapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.MaintenanceSettings;

import jakarta.annotation.PostConstruct;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class MaintenanceMapper {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @PostConstruct
    public void initTable() {
        String sql = "CREATE TABLE IF NOT EXISTS system_maintenance (" +
                "id INT PRIMARY KEY, " +
                "enabled BOOLEAN DEFAULT FALSE, " +
                "content TEXT, " +
                "maintenance_time VARCHAR(255), " +
                "start_time VARCHAR(255), " +
                "email_subject VARCHAR(255), " +
                "email_template TEXT" +
                ")";
        jdbcTemplate.execute(sql);

        // Check if new columns exist, if not add them (for existing table)
        try {
            jdbcTemplate.execute("ALTER TABLE system_maintenance ADD COLUMN start_time VARCHAR(255)");
        } catch (Exception e) {
            // Column might already exist
        }
        try {
            jdbcTemplate.execute("ALTER TABLE system_maintenance ADD COLUMN email_subject VARCHAR(255)");
        } catch (Exception e) {
            // Column might already exist
        }
        try {
            jdbcTemplate.execute("ALTER TABLE system_maintenance ADD COLUMN email_template TEXT");
        } catch (Exception e) {
            // Column might already exist
        }

        // Ensure default record exists
        String checkSql = "SELECT count(*) FROM system_maintenance WHERE id = 1";
        Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class);
        if (count == null || count == 0) {
            String insertSql = "INSERT INTO system_maintenance (id, enabled, content, maintenance_time, start_time, email_subject, email_template) " +
                    "VALUES (1, false, '系统正在维护中，请稍后访问。', '待定', '', '系统维护通知', '系统将于 {time} 进行维护，预计维护时间 {duration}，请提前做好准备。')";
            jdbcTemplate.update(insertSql);
        }
    }

    public MaintenanceSettings getSettings() {
        String sql = "SELECT * FROM system_maintenance WHERE id = 1";
        List<MaintenanceSettings> results = jdbcTemplate.query(sql, new MaintenanceRowMapper());
        return results.isEmpty() ? null : results.get(0);
    }

    public void updateSettings(MaintenanceSettings settings) {
        String sql = "UPDATE system_maintenance SET enabled = ?, content = ?, maintenance_time = ?, start_time = ?, email_subject = ?, email_template = ? WHERE id = 1";
        jdbcTemplate.update(sql, settings.getEnabled(), settings.getContent(), settings.getMaintenanceTime(), settings.getStartTime(), settings.getEmailSubject(), settings.getEmailTemplate());
    }

    private static class MaintenanceRowMapper implements RowMapper<MaintenanceSettings> {
        @Override
        public MaintenanceSettings mapRow(ResultSet rs, int rowNum) throws SQLException {
            MaintenanceSettings settings = new MaintenanceSettings();
            settings.setId(rs.getInt("id"));
            settings.setEnabled(rs.getBoolean("enabled"));
            settings.setContent(rs.getString("content"));
            settings.setMaintenanceTime(rs.getString("maintenance_time"));
            try {
                settings.setStartTime(rs.getString("start_time"));
                settings.setEmailSubject(rs.getString("email_subject"));
                settings.setEmailTemplate(rs.getString("email_template"));
            } catch (SQLException e) {
                // Ignore if columns missing (should be handled by initTable but just in case)
            }
            return settings;
        }
    }
}
