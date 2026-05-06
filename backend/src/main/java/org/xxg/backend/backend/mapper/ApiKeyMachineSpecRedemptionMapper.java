package org.xxg.backend.backend.mapper;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import jakarta.annotation.PostConstruct;

/**
 * 记录某 API 密钥下某机器码已核销过的卡密「规格」，用于「同机同规格仅一次」限制。
 */
@Repository
public class ApiKeyMachineSpecRedemptionMapper {

    private final JdbcTemplate jdbcTemplate;

    public ApiKeyMachineSpecRedemptionMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    public void initSchema() {
        jdbcTemplate.execute("CREATE TABLE IF NOT EXISTS api_key_machine_spec_redemption (" +
                "id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                "api_key_id BIGINT NOT NULL," +
                "machine_code VARCHAR(255) NOT NULL," +
                "spec_key VARCHAR(128) NOT NULL," +
                "create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
                "UNIQUE KEY uk_api_mc_spec (api_key_id, machine_code(96), spec_key(64))" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    }

    public boolean exists(Long apiKeyId, String machineCode, String specKey) {
        if (apiKeyId == null || machineCode == null || machineCode.isBlank() || specKey == null || specKey.isBlank()) {
            return false;
        }
        Integer n = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM api_key_machine_spec_redemption WHERE api_key_id = ? AND machine_code = ? AND spec_key = ?",
                Integer.class, apiKeyId, machineCode, specKey);
        return n != null && n > 0;
    }

    /**
     * @return false 若已存在（唯一约束）
     */
    public boolean tryInsert(Long apiKeyId, String machineCode, String specKey) {
        if (apiKeyId == null || machineCode == null || machineCode.isBlank() || specKey == null || specKey.isBlank()) {
            return true;
        }
        try {
            jdbcTemplate.update(
                    "INSERT INTO api_key_machine_spec_redemption (api_key_id, machine_code, spec_key) VALUES (?, ?, ?)",
                    apiKeyId, machineCode, specKey);
            return true;
        } catch (DuplicateKeyException e) {
            return false;
        }
    }

    /** 解绑设备后清除该机器在本 API Key 下的「同机同规格」核销记录，否则换绑后可能仍无法再次核销 */
    public int deleteByApiKeyAndMachine(Long apiKeyId, String machineCode) {
        if (apiKeyId == null || machineCode == null || machineCode.isBlank()) {
            return 0;
        }
        return jdbcTemplate.update(
                "DELETE FROM api_key_machine_spec_redemption WHERE api_key_id = ? AND machine_code = ?",
                apiKeyId, machineCode);
    }
}
