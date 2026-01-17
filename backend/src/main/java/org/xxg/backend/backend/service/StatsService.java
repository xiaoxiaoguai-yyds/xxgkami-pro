package org.xxg.backend.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.xxg.backend.backend.mapper.CardMapper;
import org.xxg.backend.backend.mapper.UserMapper;

import java.util.HashMap;
import java.util.Map;

@Service
public class StatsService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private CardMapper cardMapper;

    /**
     * 获取仪表盘统计数据
     */
    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("totalKeys", cardMapper.countTotalCards());
        stats.put("usedKeys", cardMapper.countUsedCards());
        stats.put("activeKeys", cardMapper.countActiveCards());
        stats.put("totalUsers", userMapper.countTotalUsers());
        
        return stats;
    }

    /**
     * 获取用户活跃度统计
     * @param days 天数
     * @return 活跃和非活跃用户数量
     */
    public Map<String, Integer> getUserActivityStats(int days) {
        int active = userMapper.countActiveUsers(days);
        int inactive = userMapper.countInactiveUsers(days);
        
        Map<String, Integer> stats = new HashMap<>();
        stats.put("active", active);
        stats.put("inactive", inactive);
        return stats;
    }
}
