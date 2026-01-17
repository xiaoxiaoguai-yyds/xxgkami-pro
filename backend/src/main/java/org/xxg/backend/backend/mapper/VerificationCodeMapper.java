package org.xxg.backend.backend.mapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.VerificationCode;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public class VerificationCodeMapper {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final RowMapper<VerificationCode> rowMapper = (rs, rowNum) -> {
        VerificationCode vc = new VerificationCode();
        vc.setId(rs.getLong("id"));
        vc.setEmail(rs.getString("email"));
        vc.setCode(rs.getString("code"));
        vc.setType(rs.getString("type"));
        vc.setExpireTime(rs.getTimestamp("expire_time").toLocalDateTime());
        vc.setCreateTime(rs.getTimestamp("create_time").toLocalDateTime());
        return vc;
    };

    public void insert(VerificationCode verificationCode) {
        String sql = "INSERT INTO verification_codes (email, code, type, expire_time) VALUES (?, ?, ?, ?)";
        jdbcTemplate.update(sql, verificationCode.getEmail(), verificationCode.getCode(), verificationCode.getType(), verificationCode.getExpireTime());
    }

    public VerificationCode findLatestByEmailAndType(String email, String type) {
        String sql = "SELECT * FROM verification_codes WHERE email = ? AND type = ? ORDER BY create_time DESC LIMIT 1";
        List<VerificationCode> results = jdbcTemplate.query(sql, rowMapper, email, type);
        return results.isEmpty() ? null : results.get(0);
    }

    public int countCodesInLastHour(String email) {
        String sql = "SELECT COUNT(*) FROM verification_codes WHERE email = ? AND create_time > DATE_SUB(NOW(), INTERVAL 1 HOUR)";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, email);
        return count != null ? count : 0;
    }
    
    public void deleteByEmailAndType(String email, String type) {
        String sql = "DELETE FROM verification_codes WHERE email = ? AND type = ?";
        jdbcTemplate.update(sql, email, type);
    }
}
