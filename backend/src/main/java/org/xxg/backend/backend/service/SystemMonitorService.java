package org.xxg.backend.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.xxg.backend.backend.filter.RequestMonitorFilter;

import java.io.File;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.OperatingSystemMXBean;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 系统监控服务
 */
@Service
public class SystemMonitorService {

    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Autowired
    private OnlineUserService onlineUserService;

    @Autowired
    private RequestMonitorFilter requestMonitorFilter;

    // 用于计算QPS
    private long lastQuestionsCount = 0;
    private long lastCheckTime = 0;

    /**
     * 获取数据库状态信息
     */
    public Map<String, Object> getDatabaseStatus() {
        Map<String, Object> status = new HashMap<>();
        
        try {
            // 测试数据库连接
            long startTime = System.currentTimeMillis();
            jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            long responseTime = System.currentTimeMillis() - startTime;
            
            status.put("status", "online");
            status.put("responseTime", responseTime);
            
            // 获取数据库信息
            try (Connection connection = jdbcTemplate.getDataSource().getConnection()) {
                DatabaseMetaData metaData = connection.getMetaData();
                status.put("databaseName", metaData.getDatabaseProductName());
                status.put("databaseVersion", metaData.getDatabaseProductVersion());
                status.put("driverName", metaData.getDriverName());
                status.put("driverVersion", metaData.getDriverVersion());
                status.put("url", metaData.getURL());
            }
            
            // 获取活跃连接数
            try {
                String connectionSql = "SHOW STATUS LIKE 'Threads_connected'";
                List<Map<String, Object>> result = jdbcTemplate.queryForList(connectionSql);
                if (!result.isEmpty()) {
                    String value = result.get(0).get("Value").toString();
                    status.put("activeConnections", Integer.parseInt(value));
                } else {
                    status.put("activeConnections", 0);
                }
            } catch (Exception e) {
                status.put("activeConnections", 0);
            }
            
            // 获取最大连接数
             try {
                String maxConnectionSql = "SHOW VARIABLES LIKE 'max_connections'";
                List<Map<String, Object>> result = jdbcTemplate.queryForList(maxConnectionSql);
                if (!result.isEmpty()) {
                    String value = result.get(0).get("Value").toString();
                    status.put("maxConnections", Integer.parseInt(value));
                } else {
                    status.put("maxConnections", 100);
                }
            } catch (Exception e) {
                status.put("maxConnections", 100);
            }
            
            // 获取QPS (Queries per second)
            try {
                 String qpsSql = "SHOW STATUS LIKE 'Questions'";
                 List<Map<String, Object>> result = jdbcTemplate.queryForList(qpsSql);
                 if (!result.isEmpty()) {
                     long currentQuestions = Long.parseLong(result.get(0).get("Value").toString());
                     long currentTime = System.currentTimeMillis();
                     
                     if (lastCheckTime > 0 && currentTime > lastCheckTime) {
                         long timeDiff = currentTime - lastCheckTime; // ms
                         long countDiff = currentQuestions - lastQuestionsCount;
                         
                         // 避免负数（如果数据库重启了）
                         if (countDiff < 0) countDiff = 0;
                         
                         double qps = (double) countDiff * 1000 / timeDiff;
                         status.put("qps", String.format("%.2f", qps));
                     } else {
                         status.put("qps", "Calculated next time");
                     }
                     
                     lastQuestionsCount = currentQuestions;
                     lastCheckTime = currentTime;
                 } else {
                     status.put("qps", "N/A");
                 }
            } catch (Exception e) {
                status.put("qps", "N/A");
            }
            
            // 获取数据库大小信息
            try {
                // 查询数据库大小（MySQL）
                String sizeQuery = "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'DB Size in MB' " +
                                 "FROM information_schema.tables WHERE table_schema = DATABASE()";
                Double dbSize = jdbcTemplate.queryForObject(sizeQuery, Double.class);
                status.put("databaseSize", dbSize != null ? dbSize + " MB" : "Unknown");
            } catch (Exception e) {
                status.put("databaseSize", "Unknown");
            }
            
            // 获取表数量
            try {
                String tableCountQuery = "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()";
                Integer tableCount = jdbcTemplate.queryForObject(tableCountQuery, Integer.class);
                status.put("tableCount", tableCount);
            } catch (Exception e) {
                status.put("tableCount", 0);
            }
            
        } catch (Exception e) {
            status.put("status", "offline");
            status.put("error", e.getMessage());
            status.put("responseTime", "N/A");
            status.put("activeConnections", 0);
            status.put("maxConnections", 0);
        }
        
        status.put("lastCheck", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        return status;
    }

    /**
     * 获取系统资源状态
     */
    public Map<String, Object> getSystemStatus() {
        Map<String, Object> status = new HashMap<>();
        
        try {
            // 获取操作系统信息
            OperatingSystemMXBean osBean = ManagementFactory.getOperatingSystemMXBean();
            status.put("osName", osBean.getName());
            status.put("osVersion", osBean.getVersion());
            status.put("osArch", osBean.getArch());
            status.put("availableProcessors", osBean.getAvailableProcessors());
            
            // CPU使用率
            double cpuUsage = 0;
            if (osBean instanceof com.sun.management.OperatingSystemMXBean) {
                cpuUsage = ((com.sun.management.OperatingSystemMXBean) osBean).getCpuLoad() * 100;
            }
            // 如果获取失败（返回负数），则保留为0或之前的逻辑
            if (cpuUsage < 0) cpuUsage = 0;
            status.put("cpuUsage", Math.round(cpuUsage * 100.0) / 100.0);
            
            // 内存信息
            MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
            long usedMemory = memoryBean.getHeapMemoryUsage().getUsed();
            long maxMemory = memoryBean.getHeapMemoryUsage().getMax();
            double memoryUsage = (double) usedMemory / maxMemory * 100;
            
            status.put("memoryUsage", Math.round(memoryUsage * 100.0) / 100.0);
            status.put("usedMemory", formatBytes(usedMemory));
            status.put("maxMemory", formatBytes(maxMemory));
            
            // 磁盘使用率
            File root = new File(".");
            long totalSpace = root.getTotalSpace();
            long freeSpace = root.getFreeSpace();
            double diskUsage = 0;
            if (totalSpace > 0) {
                diskUsage = (double)(totalSpace - freeSpace) / totalSpace * 100;
            }
            status.put("diskUsage", Math.round(diskUsage * 100.0) / 100.0);
            
            // JVM信息
            status.put("javaVersion", System.getProperty("java.version"));
            status.put("jvmName", System.getProperty("java.vm.name"));
            
        } catch (Exception e) {
            status.put("error", e.getMessage());
        }
        
        status.put("lastCheck", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        return status;
    }

    /**
     * 获取API服务状态
     */
    public Map<String, Object> getApiStatus() {
        Map<String, Object> status = new HashMap<>();
        
        status.put("status", "online");
        status.put("uptime", getUptime());
        
        // 使用RequestMonitorFilter获取真实数据
        long totalRequests = requestMonitorFilter.getTotalRequests();
        long totalErrors = requestMonitorFilter.getTotalErrors();
        double avgResponseTime = requestMonitorFilter.getAvgResponseTime();
        
        status.put("requestCount", totalRequests);
        
        double errorRate = 0;
        if (totalRequests > 0) {
            errorRate = (double) totalErrors / totalRequests * 100;
        }
        
        // 成功率 = 100 - 错误率
        status.put("successRate", Math.round((100 - errorRate) * 100.0) / 100.0);
        status.put("errorRate", Math.round(errorRate * 100.0) / 100.0);
        status.put("errorCount", totalErrors);
        status.put("avgResponseTime", Math.round(avgResponseTime * 100.0) / 100.0);
        
        status.put("lastCheck", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        
        return status;
    }

    /**
     * 获取在线用户信息
     */
    public Map<String, Object> getOnlineUsers() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 使用OnlineUserService获取真实的在线用户信息
            Map<String, Object> onlineInfo = onlineUserService.getOnlineUsersInfo();
            result.putAll(onlineInfo);
            
            // 查询总用户数
            String totalUsersQuery = "SELECT COUNT(*) FROM users WHERE status = 1";
            Integer totalUsers = jdbcTemplate.queryForObject(totalUsersQuery, Integer.class);
            result.put("totalUsers", totalUsers != null ? totalUsers : 0);
            
            // 获取最近活跃的用户列表（从数据库）
            String recentUsersQuery = "SELECT username, nickname, last_login_time FROM users " +
                                    "WHERE last_login_time > DATE_SUB(NOW(), INTERVAL 2 HOUR) " +
                                    "ORDER BY last_login_time DESC LIMIT 10";
            
            List<Map<String, Object>> recentUsers = jdbcTemplate.queryForList(recentUsersQuery);
            result.put("recentUsers", recentUsers);
            
        } catch (Exception e) {
            result.put("onlineCount", 0);
            result.put("totalUsers", 0);
            result.put("onlineUsers", new ArrayList<>());
            result.put("recentUsers", new ArrayList<>());
            result.put("error", e.getMessage());
        }
        
        result.put("lastCheck", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        return result;
    }

    /**
     * 获取所有监控数据
     */
    public Map<String, Object> getAllMonitorData() {
        Map<String, Object> allData = new HashMap<>();
        
        allData.put("database", getDatabaseStatus());
        allData.put("system", getSystemStatus());
        allData.put("api", getApiStatus());
        allData.put("users", getOnlineUsers());
        allData.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        
        return allData;
    }

    /**
     * 格式化字节数
     */
    private String formatBytes(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.2f KB", bytes / 1024.0);
        if (bytes < 1024 * 1024 * 1024) return String.format("%.2f MB", bytes / (1024.0 * 1024));
        return String.format("%.2f GB", bytes / (1024.0 * 1024 * 1024));
    }

    /**
     * 获取系统运行时间
     */
    private String getUptime() {
        long uptime = ManagementFactory.getRuntimeMXBean().getUptime();
        long seconds = uptime / 1000;
        long minutes = seconds / 60;
        long hours = minutes / 60;
        long days = hours / 24;
        
        if (days > 0) {
            return String.format("%d天 %d小时", days, hours % 24);
        } else if (hours > 0) {
            return String.format("%d小时 %d分钟", hours, minutes % 60);
        } else {
            return String.format("%d分钟", minutes);
        }
    }

    /**
     * 生成随机数
     */
    private int getRandomNumber(int min, int max) {
        return (int) (Math.random() * (max - min + 1)) + min;
    }
}