package org.xxg.backend.backend.mapper;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.xxg.backend.backend.entity.SocialUser;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public class SocialUserMapper {

    private final JdbcTemplate jdbcTemplate;

    public SocialUserMapper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        initTable();
    }

    private void initTable() {
        try {
            String sql = "CREATE TABLE IF NOT EXISTS `social_users` (" +
                    "`id` int NOT NULL AUTO_INCREMENT," +
                    "`user_id` int NOT NULL," +
                    "`social_uid` varchar(100) NOT NULL," +
                    "`social_type` varchar(20) NOT NULL," +
                    "`create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP," +
                    "PRIMARY KEY (`id`)," +
                    "UNIQUE INDEX `social_uid`(`social_uid`, `social_type`)," +
                    "INDEX `user_id`(`user_id`)" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
            jdbcTemplate.execute(sql);
        } catch (Exception e) {
            // Ignore
        }
    }

    public SocialUser findBySocialUidAndType(String socialUid, String socialType) {
        String sql = "SELECT * FROM social_users WHERE social_uid = ? AND social_type = ?";
        List<SocialUser> list = jdbcTemplate.query(sql, new SocialUserRowMapper(), socialUid, socialType);
        return list.isEmpty() ? null : list.get(0);
    }

    public List<SocialUser> findByUserId(Long userId) {
        String sql = "SELECT * FROM social_users WHERE user_id = ?";
        return jdbcTemplate.query(sql, new SocialUserRowMapper(), userId);
    }

    public void insert(SocialUser socialUser) {
        String sql = "INSERT INTO social_users (user_id, social_uid, social_type, create_time) VALUES (?, ?, ?, ?)";
        jdbcTemplate.update(sql, socialUser.getUserId(), socialUser.getSocialUid(), socialUser.getSocialType(), LocalDateTime.now());
    }

    public void deleteByUserIdAndType(Long userId, String socialType) {
        String sql = "DELETE FROM social_users WHERE user_id = ? AND social_type = ?";
        jdbcTemplate.update(sql, userId, socialType);
    }

    private static class SocialUserRowMapper implements RowMapper<SocialUser> {
        @Override
        public SocialUser mapRow(ResultSet rs, int rowNum) throws SQLException {
            SocialUser u = new SocialUser();
            u.setId(rs.getLong("id"));
            u.setUserId(rs.getLong("user_id"));
            u.setSocialUid(rs.getString("social_uid"));
            u.setSocialType(rs.getString("social_type"));
            if (rs.getTimestamp("create_time") != null) {
                u.setCreateTime(rs.getTimestamp("create_time").toLocalDateTime());
            }
            return u;
        }
    }
}
