package org.xxg.backend.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.xxg.backend.backend.service.StatsService;

import java.util.Map;

/**
 * 统计控制器
 */
@RestController
@RequestMapping("/stats")
public class StatsController {

    @Autowired
    private StatsService statsService;

    /**
     * 获取仪表盘统计数据
     */
    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        return ResponseEntity.ok(statsService.getDashboardStats());
    }

    /**
     * 获取用户活跃度统计
     * @param days 统计天数
     */
    @GetMapping("/user-activity")
    public ResponseEntity<Map<String, Integer>> getUserActivityStats(@RequestParam(defaultValue = "7") String days) {
        // 处理可能带"d"后缀的参数
        int daysInt;
        try {
            String cleanDays = days.replace("d", "");
            daysInt = Integer.parseInt(cleanDays);
        } catch (NumberFormatException e) {
            daysInt = 7;
        }
        
        return ResponseEntity.ok(statsService.getUserActivityStats(daysInt));
    }
}
