package org.xxg.backend.backend.mapper;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.ApiKey;
import org.xxg.backend.backend.entity.User;

import jakarta.annotation.PostConstruct;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public class ApiKeyMapper {

    private final JdbcTemplate jdbcTemplate;

    public ApiKeyMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private static final org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger(ApiKeyMapper.class);

    @PostConstruct
    public void initSchema() {
        logger.info("Initializing ApiKey schema...");
        
        // 1. Create api_keys table
        try {
            jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS api_keys (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "key_name VARCHAR(50) NOT NULL COMMENT 'API密钥名称', " +
                    "api_key VARCHAR(32) NOT NULL COMMENT 'API密钥', " +
                    "status TINYINT(1) NOT NULL DEFAULT 1 COMMENT '状态:0禁用,1启用', " +
                    "create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                    "last_use_time DATETIME NULL DEFAULT NULL COMMENT '最后使用时间', " +
                    "use_count INT NOT NULL DEFAULT 0 COMMENT '使用次数', " +
                    "description VARCHAR(255) NULL DEFAULT NULL COMMENT '备注说明', " +
                    "key_value VARCHAR(255) NOT NULL, " +
                    "name VARCHAR(100) NOT NULL DEFAULT 'API Key', " +
                    "update_time DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, " +
                    "UNIQUE INDEX `api_key`(`api_key` ASC), " +
                    "UNIQUE INDEX `idx_api_key_value`(`key_value` ASC)" +
                    ")");
        } catch (Exception e) {
            logger.error("Failed to create api_keys table", e);
        }

        // 2. Create user_api_keys table
        try {
            jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS user_api_keys (" +
                    "id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                    "user_id BIGINT NOT NULL, " +
                    "api_key_id BIGINT NOT NULL, " +
                    "assign_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "UNIQUE(user_id, api_key_id)" +
                    ")");
        } catch (Exception e) {
            logger.error("Failed to create user_api_keys table", e);
        }

        // 3. Migrations
        runMigrations();
        
        logger.info("ApiKey schema initialized successfully.");
    }

    private void runMigrations() {
        try {
            // Migration: Ensure update_time column exists
            try {
                jdbcTemplate.execute("SELECT update_time FROM api_keys LIMIT 1");
            } catch (Exception e) {
                logger.info("Column update_time missing, attempting to add it...");
                jdbcTemplate.execute("ALTER TABLE api_keys ADD COLUMN update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP");
            }

            // Migration: Ensure key_value column exists
            try {
                jdbcTemplate.execute("SELECT key_value FROM api_keys LIMIT 1");
            } catch (Exception e) {
                logger.info("Column key_value missing, attempting to add it...");
                // If adding key_value, we might need to populate it. For now allow NULL or set default.
                // But schema says NOT NULL. Let's make it nullable first or provide default.
                // Since it is UUID, hard to provide default in SQL. 
                // We'll set it to a dummy UUID if adding.
                jdbcTemplate.execute("ALTER TABLE api_keys ADD COLUMN key_value VARCHAR(255) NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'");
            }
            
            // Migration: Ensure name column exists
            try {
                jdbcTemplate.execute("SELECT name FROM api_keys LIMIT 1");
            } catch (Exception e) {
                logger.info("Column name missing, attempting to add it...");
                jdbcTemplate.execute("ALTER TABLE api_keys ADD COLUMN name VARCHAR(100) NOT NULL DEFAULT 'API Key'");
            }

            // Migration: Fix column mismatch (key_value -> api_key, name -> key_name) if coming from old version
            // But wait, key_value IS in the new schema. 
            // In old version we had `key` mapping to `api_key` and `name` mapping to `key_name`.
            // We should check if `api_key` column exists.
            try {
                jdbcTemplate.execute("SELECT api_key FROM api_keys LIMIT 1");
            } catch (Exception e) {
                // api_key missing. 
                // Maybe it was named 'key' or 'key_value' in previous erroneous versions?
                // If 'key_value' exists but 'api_key' doesn't, AND we need both...
                // It's complicated. Let's assume standard migration: Add missing columns.
                logger.info("Column api_key missing, attempting to add it...");
                jdbcTemplate.execute("ALTER TABLE api_keys ADD COLUMN api_key VARCHAR(32) NOT NULL DEFAULT ''");
            }
            
            // Ensure key_name exists
             try {
                jdbcTemplate.execute("SELECT key_name FROM api_keys LIMIT 1");
            } catch (Exception e) {
                 logger.info("Column key_name missing, attempting to add it...");
                 jdbcTemplate.execute("ALTER TABLE api_keys ADD COLUMN key_name VARCHAR(50) NOT NULL DEFAULT 'API Key'");
            }

            // Migration: Ensure webhook_config exists
            try {
                jdbcTemplate.execute("SELECT webhook_config FROM api_keys LIMIT 1");
            } catch (Exception e) {
                 logger.info("Column webhook_config missing, attempting to add it...");
                 jdbcTemplate.execute("ALTER TABLE api_keys ADD COLUMN webhook_config TEXT NULL");
            }

            // Migration: Ensure create_time exists (just in case)
            try {
                jdbcTemplate.execute("SELECT create_time FROM api_keys LIMIT 1");
            } catch (Exception e) {
                 logger.info("Column create_time missing, attempting to add it...");
                 jdbcTemplate.execute("ALTER TABLE api_keys ADD COLUMN create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP");
            }

        } catch (Exception e) {
            logger.error("Failed to run migrations", e);
        }
    }

    public List<ApiKey> findAll() {
        String sql = "SELECT * FROM api_keys ORDER BY create_time DESC";
        return jdbcTemplate.query(sql, new ApiKeyRowMapper());
    }

    public ApiKey findById(Long id) {
        String sql = "SELECT * FROM api_keys WHERE id = ?";
        List<ApiKey> list = jdbcTemplate.query(sql, new ApiKeyRowMapper(), id);
        return list.isEmpty() ? null : list.get(0);
    }

    public ApiKey findByApiKey(String apiKey) {
        String sql = "SELECT * FROM api_keys WHERE api_key = ?";
        List<ApiKey> list = jdbcTemplate.query(sql, new ApiKeyRowMapper(), apiKey);
        return list.isEmpty() ? null : list.get(0);
    }

    public void updateUsage(Long id) {
        String sql = "UPDATE api_keys SET use_count = IFNULL(use_count, 0) + 1, last_use_time = NOW() WHERE id = ?";
        jdbcTemplate.update(sql, id);
    }

    public void insert(ApiKey apiKey) {
        String sql = "INSERT INTO api_keys (key_name, api_key, key_value, name, description, status, create_time, webhook_config) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, 
            apiKey.getKeyName(), 
            apiKey.getApiKey(), 
            apiKey.getKeyValue(), 
            apiKey.getName(), 
            apiKey.getDescription(), 
            apiKey.getStatus(), 
            LocalDateTime.now(),
            apiKey.getWebhookConfig()
        );
    }

    public void update(ApiKey apiKey) {
        String sql = "UPDATE api_keys SET key_name = ?, description = ?, status = ?, webhook_config = ? WHERE id = ?";
        jdbcTemplate.update(sql, apiKey.getKeyName(), apiKey.getDescription(), apiKey.getStatus(), apiKey.getWebhookConfig(), apiKey.getId());
    }

    public void delete(Long id) {
        jdbcTemplate.update("DELETE FROM user_api_keys WHERE api_key_id = ?", id);
        jdbcTemplate.update("DELETE FROM api_keys WHERE id = ?", id);
    }

    public void assignUser(Long apiKeyId, Long userId) {
        String sql = "INSERT INTO user_api_keys (user_id, api_key_id) VALUES (?, ?)";
        jdbcTemplate.update(sql, userId, apiKeyId);
    }

    public void unassignUser(Long apiKeyId, Long userId) {
        String sql = "DELETE FROM user_api_keys WHERE user_id = ? AND api_key_id = ?";
        jdbcTemplate.update(sql, userId, apiKeyId);
    }

    public List<User> getAssignedUsers(Long apiKeyId) {
        String sql = "SELECT u.* FROM users u JOIN user_api_keys uak ON u.id = uak.user_id WHERE uak.api_key_id = ?";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            User user = new User();
            user.setId(rs.getLong("id"));
            user.setUsername(rs.getString("username"));
            user.setEmail(rs.getString("email"));
            user.setNickname(rs.getString("nickname"));
            return user;
        }, apiKeyId);
    }

    public Integer countAssignedUsers(Long apiKeyId) {
        String sql = "SELECT COUNT(*) FROM user_api_keys WHERE api_key_id = ?";
        return jdbcTemplate.queryForObject(sql, Integer.class, apiKeyId);
    }

    public ApiKey findFirstUnassignedKey() {
        String sql = "SELECT * FROM api_keys WHERE id NOT IN (SELECT DISTINCT api_key_id FROM user_api_keys) LIMIT 1";
        List<ApiKey> list = jdbcTemplate.query(sql, new ApiKeyRowMapper());
        return list.isEmpty() ? null : list.get(0);
    }

    private static class ApiKeyRowMapper implements RowMapper<ApiKey> {
        @Override
        public ApiKey mapRow(ResultSet rs, int rowNum) throws SQLException {
            ApiKey apiKey = new ApiKey();
            apiKey.setId(rs.getLong("id"));
            apiKey.setKeyName(rs.getString("key_name"));
            apiKey.setApiKey(rs.getString("api_key"));
            apiKey.setKeyValue(rs.getString("key_value"));
            apiKey.setName(rs.getString("name"));
            apiKey.setDescription(rs.getString("description"));
            apiKey.setStatus(rs.getInt("status"));
            apiKey.setWebhookConfig(rs.getString("webhook_config"));
            
            if (rs.getTimestamp("create_time") != null) {
                apiKey.setCreateTime(rs.getTimestamp("create_time").toLocalDateTime());
            }
            
            try {
                if (rs.getObject("update_time") != null) {
                    apiKey.setUpdateTime(rs.getTimestamp("update_time").toLocalDateTime());
                }
            } catch (SQLException e) {}

            try {
                if (rs.getObject("last_use_time") != null) {
                    apiKey.setLastUseTime(rs.getTimestamp("last_use_time").toLocalDateTime());
                }
            } catch (SQLException e) {}

            try {
                apiKey.setUseCount(rs.getInt("use_count"));
            } catch (SQLException e) {}

            return apiKey;
        }
    }
}
