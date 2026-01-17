package org.xxg.backend.backend.mapper;

import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.Card;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;

/**
 * 卡密数据访问层
 */
@Repository
public class CardMapper {

    private final JdbcTemplate jdbcTemplate;

    public CardMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        ensureColumnsExist();
    }

    private void ensureColumnsExist() {
        try {
            jdbcTemplate.execute("ALTER TABLE cards ADD COLUMN device_id VARCHAR(255)");
        } catch (Exception e) {
            // Ignore if column exists
        }
        try {
            jdbcTemplate.execute("ALTER TABLE cards ADD COLUMN ip_address VARCHAR(255)");
        } catch (Exception e) {
            // Ignore if column exists
        }
        try {
            jdbcTemplate.execute("ALTER TABLE cards ADD COLUMN api_key_id BIGINT");
        } catch (Exception e) {
            // Ignore if column exists
        }
    }

    /**
     * 更新卡密状态
     * @param ids 卡密ID列表
     * @param status 新状态
     */
    public void updateStatus(List<Long> ids, int status) {
        if (ids == null || ids.isEmpty()) return;
        
        String sql = "UPDATE cards SET status = ? WHERE id IN (" + 
                     String.join(",", java.util.Collections.nCopies(ids.size(), "?")) + ")";
        
        Object[] args = new Object[ids.size() + 1];
        args[0] = status;
        for (int i = 0; i < ids.size(); i++) {
            args[i + 1] = ids.get(i);
        }
        
        jdbcTemplate.update(sql, args);
    }

    /**
     * 统计所有卡密数量
     */
    public int countTotalCards() {
        String sql = "SELECT COUNT(*) FROM cards";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class);
        return count != null ? count : 0;
    }

    /**
     * 统计已使用卡密数量
     */
    public int countUsedCards() {
        String sql = "SELECT COUNT(*) FROM cards WHERE status = 1";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class);
        return count != null ? count : 0;
    }

    /**
     * 统计有效卡密数量
     */
    public int countActiveCards() {
        String sql = "SELECT COUNT(*) FROM cards WHERE status = 0";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class);
        return count != null ? count : 0;
    }

    /**
     * 获取最近N天的卡密使用趋势
     * @param days 天数
     * @return 每日使用数量列表
     */
    public List<Map<String, Object>> getUsageTrend(int days) {
        String sql = "SELECT DATE(use_time) as date, COUNT(*) as count " +
                     "FROM cards " +
                     "WHERE use_time >= DATE_SUB(CURDATE(), INTERVAL ? DAY) " +
                     "AND status = 1 " + // 假设1是已使用，虽然use_time不为null也隐含已使用
                     "GROUP BY DATE(use_time) " +
                     "ORDER BY date ASC";
        
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("date", rs.getDate("date").toString());
            map.put("count", rs.getInt("count"));
            return map;
        }, days);
    }

    /**
     * 查找可用卡密
     * @param type 卡密类型 (time/count)
     * @param value 规格值 (duration or total_count)
     * @param limit 数量
     * @return 卡密列表
     */
    public List<Card> findAvailableCards(String type, int value, int limit) {
        String sql;
        if ("time".equals(type)) {
            sql = "SELECT * FROM cards WHERE card_type = ? AND duration = ? AND status = 0 LIMIT ?";
        } else {
            sql = "SELECT * FROM cards WHERE card_type = ? AND total_count = ? AND status = 0 LIMIT ?";
        }
        
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Card card = new Card();
            card.setId(rs.getLong("id"));
            card.setCardKey(rs.getString("card_key"));
            // ... other fields if needed
            return card;
        }, type, value, limit);
    }

    /**
     * 更新卡密使用信息
     * @param id 卡密ID
     * @param useTime 使用时间
     * @param deviceId 设备ID
     * @param ipAddress IP地址
     */
    public void updateUsage(Long id, java.time.LocalDateTime useTime, String deviceId, String ipAddress) {
        String sql = "UPDATE cards SET status = 1, use_time = ?, device_id = ?, ip_address = ? WHERE id = ?";
        jdbcTemplate.update(sql, Timestamp.valueOf(useTime), deviceId, ipAddress, id);
    }

    /**
     * 更新卡密信息
     */
    public void update(Card card) {
        String sql = "UPDATE cards SET status = ?, use_time = ?, expire_time = ?, remaining_count = ?, device_id = ?, ip_address = ? WHERE id = ?";
        jdbcTemplate.update(sql, 
            card.getStatus(),
            card.getUseTime() != null ? Timestamp.valueOf(card.getUseTime()) : null,
            card.getExpireTime() != null ? Timestamp.valueOf(card.getExpireTime()) : null,
            card.getRemainingCount(),
            card.getDeviceId(),
            card.getIpAddress(),
            card.getId()
        );
    }

    /**
     * 根据卡密查找
     * @param cardKey 卡密
     * @return Card对象
     */
    public Card findByCardKey(String cardKey) {
        String sql = "SELECT * FROM cards WHERE card_key = ?";
        try {
            return jdbcTemplate.queryForObject(sql, new CardRowMapper(), cardKey);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null;
        }
    }

    /**
     * 根据卡密列表查找
     * @param cardKeys 卡密列表
     * @return Card对象列表
     */
    public List<Card> findByCardKeys(List<String> cardKeys) {
        if (cardKeys == null || cardKeys.isEmpty()) {
            return new ArrayList<>();
        }
        String sql = "SELECT * FROM cards WHERE card_key IN (" + 
                     String.join(",", Collections.nCopies(cardKeys.size(), "?")) + ")";
        return jdbcTemplate.query(sql, new CardRowMapper(), cardKeys.toArray());
    }

    /**
     * 批量插入卡密
     */
    public void batchInsert(List<Card> cards) {
        String sql = "INSERT INTO cards (card_key, encrypted_key, card_type, duration, total_count, remaining_count, status, verify_method, encryption_type, allow_reverify, create_time, creator_type, creator_id, creator_name, api_key_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        jdbcTemplate.batchUpdate(sql, new BatchPreparedStatementSetter() {
            @Override
            public void setValues(PreparedStatement ps, int i) throws SQLException {
                Card card = cards.get(i);
                ps.setString(1, card.getCardKey());
                ps.setString(2, card.getEncryptedKey());
                ps.setString(3, card.getCardType());
                ps.setInt(4, card.getDuration());
                ps.setInt(5, card.getTotalCount());
                ps.setInt(6, card.getRemainingCount());
                ps.setInt(7, card.getStatus());
                ps.setString(8, card.getVerifyMethod());
                ps.setString(9, card.getEncryptionType());
                ps.setInt(10, card.getAllowReverify());
                ps.setTimestamp(11, Timestamp.valueOf(card.getCreateTime()));
                ps.setString(12, card.getCreatorType());
                ps.setLong(13, card.getCreatorId());
                ps.setString(14, card.getCreatorName());
                if (card.getApiKeyId() != null) {
                    ps.setLong(15, card.getApiKeyId());
                } else {
                    ps.setNull(15, java.sql.Types.BIGINT);
                }
            }

            @Override
            public int getBatchSize() {
                return cards.size();
            }
        });
    }

    /**
     * 获取所有卡密
     */
    public List<Card> findByApiKeyId(Long apiKeyId) {
        String sql = "SELECT * FROM cards WHERE api_key_id = ? ORDER BY create_time DESC";
        return jdbcTemplate.query(sql, new CardRowMapper(), apiKeyId);
    }

    public List<Card> findAll() {
        String sql = "SELECT * FROM cards ORDER BY create_time DESC";
        return jdbcTemplate.query(sql, new CardRowMapper());
    }

    private static class CardRowMapper implements RowMapper<Card> {
        @Override
        public Card mapRow(ResultSet rs, int rowNum) throws SQLException {
            Card card = new Card();
            card.setId(rs.getLong("id"));
            card.setCardKey(rs.getString("card_key"));
            card.setEncryptedKey(rs.getString("encrypted_key"));
            card.setCardType(rs.getString("card_type"));
            card.setDuration(rs.getInt("duration"));
            card.setTotalCount(rs.getInt("total_count"));
            card.setRemainingCount(rs.getInt("remaining_count"));
            card.setStatus(rs.getInt("status"));
            card.setVerifyMethod(rs.getString("verify_method"));
            card.setEncryptionType(rs.getString("encryption_type"));
            card.setAllowReverify(rs.getInt("allow_reverify"));
            if (rs.getTimestamp("create_time") != null) {
                card.setCreateTime(rs.getTimestamp("create_time").toLocalDateTime());
            }
            if (rs.getTimestamp("use_time") != null) {
                card.setUseTime(rs.getTimestamp("use_time").toLocalDateTime());
            }
            if (rs.getTimestamp("expire_time") != null) {
                card.setExpireTime(rs.getTimestamp("expire_time").toLocalDateTime());
            }
            card.setCreatorType(rs.getString("creator_type"));
            card.setCreatorId(rs.getLong("creator_id"));
            card.setCreatorName(rs.getString("creator_name"));
            try {
                card.setDeviceId(rs.getString("device_id"));
                card.setIpAddress(rs.getString("ip_address"));
            } catch (SQLException e) {
                // Ignore
            }
            try {
                long apiKeyId = rs.getLong("api_key_id");
                if (!rs.wasNull()) {
                    card.setApiKeyId(apiKeyId);
                }
            } catch (SQLException e) {
                // Ignore
            }
            return card;
        }
    }
}
