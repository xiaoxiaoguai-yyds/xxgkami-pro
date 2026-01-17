package org.xxg.backend.backend.mapper;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.CardPricing;

import java.util.List;

@Repository
public class CardPricingMapper {

    private final JdbcTemplate jdbcTemplate;

    public CardPricingMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        ensureTableExists();
    }

    private void ensureTableExists() {
        try {
            jdbcTemplate.execute("""
                CREATE TABLE IF NOT EXISTS card_pricing (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    type VARCHAR(20) NOT NULL COMMENT 'time or count',
                    value INT NOT NULL COMMENT 'duration or count',
                    price DECIMAL(10, 2) NOT NULL,
                    description VARCHAR(100) NOT NULL,
                    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
                    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """);
            
            // Initial data population if empty
            if (countAll() == 0) {
                 jdbcTemplate.execute("INSERT INTO card_pricing (type, value, price, description) VALUES " +
                        "('time', 7, 9.9, '7天时间卡')," +
                        "('time', 15, 18.8, '15天时间卡')," +
                        "('time', 30, 35.0, '30天时间卡')," +
                        "('time', 60, 65.0, '60天时间卡')," +
                        "('time', 90, 90.0, '90天时间卡')," +
                        "('time', 180, 168.0, '180天时间卡')," +
                        "('count', 50, 12.0, '50次使用卡')," +
                        "('count', 100, 22.0, '100次使用卡')," +
                        "('count', 200, 40.0, '200次使用卡')," +
                        "('count', 500, 95.0, '500次使用卡')," +
                        "('count', 1000, 180.0, '1000次使用卡')");
            }
            
        } catch (Exception e) {
            System.err.println("Failed to create card_pricing table: " + e.getMessage());
        }
    }

    private int countAll() {
        try {
            Integer count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM card_pricing", Integer.class);
            return count != null ? count : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    private final RowMapper<CardPricing> rowMapper = (rs, rowNum) -> {
        CardPricing pricing = new CardPricing();
        pricing.setId(rs.getInt("id"));
        pricing.setType(rs.getString("type"));
        pricing.setValue(rs.getInt("value"));
        pricing.setPrice(rs.getBigDecimal("price"));
        pricing.setDescription(rs.getString("description"));
        pricing.setCreateTime(rs.getTimestamp("create_time").toLocalDateTime());
        if (rs.getTimestamp("update_time") != null) {
            pricing.setUpdateTime(rs.getTimestamp("update_time").toLocalDateTime());
        }
        return pricing;
    };

    public List<CardPricing> findAll() {
        return jdbcTemplate.query("SELECT * FROM card_pricing ORDER BY type, value", rowMapper);
    }
    
    public List<CardPricing> findByType(String type) {
        return jdbcTemplate.query("SELECT * FROM card_pricing WHERE type = ? ORDER BY value", rowMapper, type);
    }

    public CardPricing findById(Integer id) {
        try {
            return jdbcTemplate.queryForObject("SELECT * FROM card_pricing WHERE id = ?", rowMapper, id);
        } catch (Exception e) {
            return null;
        }
    }

    public void insert(CardPricing pricing) {
        jdbcTemplate.update("INSERT INTO card_pricing (type, value, price, description) VALUES (?, ?, ?, ?)",
                pricing.getType(), pricing.getValue(), pricing.getPrice(), pricing.getDescription());
    }

    public void update(CardPricing pricing) {
        jdbcTemplate.update("UPDATE card_pricing SET type = ?, value = ?, price = ?, description = ? WHERE id = ?",
                pricing.getType(), pricing.getValue(), pricing.getPrice(), pricing.getDescription(), pricing.getId());
    }

    public void delete(Integer id) {
        jdbcTemplate.update("DELETE FROM card_pricing WHERE id = ?", id);
    }
}
