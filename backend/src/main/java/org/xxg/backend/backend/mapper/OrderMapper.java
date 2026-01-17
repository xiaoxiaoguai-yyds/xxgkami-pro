package org.xxg.backend.backend.mapper;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.Order;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@Repository
public class OrderMapper {

    private final JdbcTemplate jdbcTemplate;

    public OrderMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public int insert(Order order) {
        String sql = "INSERT INTO orders (order_no, user_id, username, card_type, card_spec, quantity, unit_price, total_price, status, payment_method, card_keys, create_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();
        
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, order.getOrderNo());
            ps.setObject(2, order.getUserId());
            ps.setString(3, order.getUsername());
            ps.setString(4, order.getCardType());
            ps.setString(5, order.getCardSpec());
            ps.setInt(6, order.getQuantity());
            ps.setBigDecimal(7, order.getUnitPrice());
            ps.setBigDecimal(8, order.getTotalPrice());
            ps.setString(9, order.getStatus());
            ps.setString(10, order.getPaymentMethod());
            ps.setString(11, order.getCardKeys());
            ps.setTimestamp(12, Timestamp.valueOf(order.getCreateTime()));
            return ps;
        }, keyHolder);

        return keyHolder.getKey().intValue();
    }
    
    private org.springframework.jdbc.core.RowMapper<Order> rowMapper = (rs, rowNum) -> {
        Order order = new Order();
        order.setId(rs.getInt("id"));
        order.setOrderNo(rs.getString("order_no"));
        order.setUserId(rs.getInt("user_id"));
        order.setUsername(rs.getString("username"));
        order.setCardType(rs.getString("card_type"));
        order.setCardSpec(rs.getString("card_spec"));
        order.setQuantity(rs.getInt("quantity"));
        order.setUnitPrice(rs.getBigDecimal("unit_price"));
        order.setTotalPrice(rs.getBigDecimal("total_price"));
        order.setStatus(rs.getString("status"));
        order.setPaymentMethod(rs.getString("payment_method"));
        order.setCardKeys(rs.getString("card_keys"));
        
        Timestamp createTime = rs.getTimestamp("create_time");
        if (createTime != null) {
            order.setCreateTime(createTime.toLocalDateTime());
        }
        Timestamp payTime = rs.getTimestamp("pay_time");
        if (payTime != null) {
            order.setPayTime(payTime.toLocalDateTime());
        }
        return order;
    };

    public Order findByOrderNo(String orderNo) {
        String sql = "SELECT * FROM orders WHERE order_no = ?";
        try {
            return jdbcTemplate.queryForObject(sql, rowMapper, orderNo);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null;
        }
    }

    public List<Order> search(String orderNo, String username, String status, String cardType, String startTime, String endTime) {
        StringBuilder sql = new StringBuilder("SELECT * FROM orders WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (orderNo != null && !orderNo.isEmpty()) {
            sql.append(" AND order_no LIKE ?");
            params.add("%" + orderNo + "%");
        }
        if (username != null && !username.isEmpty()) {
            sql.append(" AND username LIKE ?");
            params.add("%" + username + "%");
        }
        if (status != null && !status.isEmpty() && !"all".equals(status)) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        if (cardType != null && !cardType.isEmpty() && !"all".equals(cardType)) {
            sql.append(" AND card_type = ?");
            params.add(cardType);
        }
        if (startTime != null && !startTime.isEmpty()) {
            sql.append(" AND create_time >= ?");
            params.add(Timestamp.valueOf(startTime + " 00:00:00"));
        }
        if (endTime != null && !endTime.isEmpty()) {
            sql.append(" AND create_time <= ?");
            params.add(Timestamp.valueOf(endTime + " 23:59:59"));
        }

        sql.append(" ORDER BY create_time DESC");

        return jdbcTemplate.query(sql.toString(), rowMapper, params.toArray());
    }

    public List<Order> findByUserId(Integer userId) {
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY create_time DESC";
        return jdbcTemplate.query(sql, rowMapper, userId);
    }

    public List<Order> findAll() {
        String sql = "SELECT * FROM orders ORDER BY create_time DESC";
        return jdbcTemplate.query(sql, rowMapper);
    }

    public int updateStatus(String orderNo, String status) {
        String sql = "UPDATE orders SET status = ? WHERE order_no = ?";
        return jdbcTemplate.update(sql, status, orderNo);
    }

    public Order findByCardKey(String cardKey) {
        String sql = "SELECT * FROM orders WHERE card_keys LIKE ? LIMIT 1";
        try {
            return jdbcTemplate.queryForObject(sql, rowMapper, "%" + cardKey + "%");
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            return null;
        }
    }
}
