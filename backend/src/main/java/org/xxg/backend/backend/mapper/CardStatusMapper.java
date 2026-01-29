package org.xxg.backend.backend.mapper;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.CardStatus;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

@Repository
public class CardStatusMapper {

    private final JdbcTemplate jdbcTemplate;

    public CardStatusMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void insert(CardStatus cardStatus) {
        String sql = "INSERT INTO card_status (card_hash, remain_count, total_count, expire_time, is_valid) VALUES (?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, 
            cardStatus.getCardHash(),
            cardStatus.getRemainCount(),
            cardStatus.getTotalCount(),
            cardStatus.getExpireTime() != null ? Timestamp.valueOf(cardStatus.getExpireTime()) : null,
            cardStatus.getIsValid()
        );
    }

    public CardStatus findByCardHash(String cardHash) {
        String sql = "SELECT * FROM card_status WHERE card_hash = ?";
        try {
            return jdbcTemplate.queryForObject(sql, new RowMapper<CardStatus>() {
                @Override
                public CardStatus mapRow(ResultSet rs, int rowNum) throws SQLException {
                    CardStatus c = new CardStatus();
                    c.setId(rs.getLong("id"));
                    c.setCardHash(rs.getString("card_hash"));
                    c.setRemainCount(rs.getInt("remain_count"));
                    c.setTotalCount(rs.getInt("total_count"));
                    if (rs.getTimestamp("expire_time") != null) {
                        c.setExpireTime(rs.getTimestamp("expire_time").toLocalDateTime());
                    }
                    if (rs.getTimestamp("last_use_time") != null) {
                        c.setLastUseTime(rs.getTimestamp("last_use_time").toLocalDateTime());
                    }
                    c.setIsValid(rs.getInt("is_valid"));
                    return c;
                }
            }, cardHash);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null;
        }
    }

    public void updateUsage(String cardHash, int newCount, java.time.LocalDateTime useTime) {
        String sql = "UPDATE card_status SET remain_count = ?, last_use_time = ? WHERE card_hash = ?";
        jdbcTemplate.update(sql, newCount, Timestamp.valueOf(useTime), cardHash);
    }
}
