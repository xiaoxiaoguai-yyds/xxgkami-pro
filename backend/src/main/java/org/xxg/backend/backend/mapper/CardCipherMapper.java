package org.xxg.backend.backend.mapper;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.CardCipher;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

@Repository
public class CardCipherMapper {

    private final JdbcTemplate jdbcTemplate;

    public CardCipherMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void insert(CardCipher cardCipher) {
        String sql = "INSERT INTO card_cipher (card_hash, cipher_data, sign_data, salt, iv, create_time) VALUES (?, ?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql, 
            cardCipher.getCardHash(),
            cardCipher.getCipherData(),
            cardCipher.getSignData(),
            cardCipher.getSalt(),
            cardCipher.getIv(),
            Timestamp.valueOf(cardCipher.getCreateTime())
        );
    }

    public CardCipher findByCardHash(String cardHash) {
        String sql = "SELECT * FROM card_cipher WHERE card_hash = ?";
        try {
            return jdbcTemplate.queryForObject(sql, new RowMapper<CardCipher>() {
                @Override
                public CardCipher mapRow(ResultSet rs, int rowNum) throws SQLException {
                    CardCipher c = new CardCipher();
                    c.setId(rs.getLong("id"));
                    c.setCardHash(rs.getString("card_hash"));
                    c.setCipherData(rs.getString("cipher_data"));
                    c.setSignData(rs.getString("sign_data"));
                    c.setSalt(rs.getString("salt"));
                    c.setIv(rs.getString("iv"));
                    c.setCreateTime(rs.getTimestamp("create_time").toLocalDateTime());
                    return c;
                }
            }, cardHash);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null;
        }
    }
}
