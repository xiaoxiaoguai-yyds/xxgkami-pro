/*
 Navicat Premium Dump SQL

 Source Server         : 小小怪
 Source Server Type    : MySQL
 Source Server Version : 90300 (9.3.0)
 Source Host           : localhost:3306
 Source Schema         : kami

 Target Server Type    : MySQL
 Target Server Version : 90300 (9.3.0)
 File Encoding         : 65001

 Date: 18/01/2026 10:26:53
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admins
-- ----------------------------
DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` datetime NULL DEFAULT NULL,
  `access_token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `refresh_token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admins
-- ----------------------------
INSERT INTO `admins` VALUES (2, 'admin', '123456', '2025-05-20 08:18:44', '2026-01-16 10:37:40', NULL, NULL);

-- ----------------------------
-- Table structure for api_keys
-- ----------------------------
DROP TABLE IF EXISTS `api_keys`;
CREATE TABLE `api_keys`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `key_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'API密钥名称',
  `api_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'API密钥',
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态:0禁用,1启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_use_time` datetime NULL DEFAULT NULL COMMENT '最后使用时间',
  `use_count` int NOT NULL DEFAULT 0 COMMENT '使用次数',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注说明',
  `key_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'API Key',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `webhook_config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `api_key`(`api_key` ASC) USING BTREE,
  UNIQUE INDEX `idx_api_key_value`(`key_value` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_keys
-- ----------------------------
INSERT INTO `api_keys` VALUES (3, '123', '8WAD3TN9YCUZivmDAdicvYs5Q7Hj0zcB', 1, '2025-05-13 15:44:55', '2025-05-13 17:42:27', 5, '123', '89c13e4b-ee08-11f0-bbca-088fc3fb7e69', 'API Key', '2026-01-10 17:47:21', NULL);
INSERT INTO `api_keys` VALUES (4, '456', '1jTQXXpBBRMgdPjv63QpU29k4tUwCY78', 1, '2025-05-13 16:56:51', NULL, 0, '456', '89c14863-ee08-11f0-bbca-088fc3fb7e69', 'API Key', '2026-01-17 21:36:55', NULL);

-- ----------------------------
-- Table structure for card_pricing
-- ----------------------------
DROP TABLE IF EXISTS `card_pricing`;
CREATE TABLE `card_pricing`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'time or count',
  `value` int NOT NULL COMMENT 'duration or count',
  `price` decimal(10, 2) NOT NULL,
  `description` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of card_pricing
-- ----------------------------
INSERT INTO `card_pricing` VALUES (1, 'time', 7, 0.01, '7天时间卡', '2026-01-14 20:01:56', '2026-01-16 11:47:56');
INSERT INTO `card_pricing` VALUES (2, 'time', 15, 0.02, '15天时间卡', '2026-01-14 20:01:56', '2026-01-16 11:52:46');
INSERT INTO `card_pricing` VALUES (3, 'time', 30, 35.00, '30天时间卡', '2026-01-14 20:01:56', '2026-01-14 20:01:56');
INSERT INTO `card_pricing` VALUES (4, 'time', 60, 65.00, '60天时间卡', '2026-01-14 20:01:56', '2026-01-14 20:01:56');
INSERT INTO `card_pricing` VALUES (5, 'time', 90, 90.00, '90天时间卡', '2026-01-14 20:01:56', '2026-01-14 20:01:56');
INSERT INTO `card_pricing` VALUES (6, 'time', 180, 168.00, '180天时间卡', '2026-01-14 20:01:56', '2026-01-14 20:01:56');
INSERT INTO `card_pricing` VALUES (7, 'count', 50, 12.00, '50次使用卡', '2026-01-14 20:01:56', '2026-01-14 20:01:56');
INSERT INTO `card_pricing` VALUES (8, 'count', 100, 22.00, '100次使用卡', '2026-01-14 20:01:56', '2026-01-14 20:01:56');
INSERT INTO `card_pricing` VALUES (9, 'count', 200, 40.00, '200次使用卡', '2026-01-14 20:01:56', '2026-01-14 20:01:56');
INSERT INTO `card_pricing` VALUES (10, 'count', 500, 95.00, '500次使用卡', '2026-01-14 20:01:56', '2026-01-14 20:01:56');
INSERT INTO `card_pricing` VALUES (11, 'count', 1000, 180.00, '1000次使用卡', '2026-01-14 20:01:56', '2026-01-14 20:01:56');

-- ----------------------------
-- Table structure for cards
-- ----------------------------
DROP TABLE IF EXISTS `cards`;
CREATE TABLE `cards`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `card_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '原始卡密',
  `encrypted_key` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '加密后的卡密',
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:未使用 1:已使用 2:已停用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `use_time` datetime NULL DEFAULT NULL,
  `expire_time` datetime NULL DEFAULT NULL,
  `duration` int NOT NULL DEFAULT 0,
  `verify_method` enum('web','post','get') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `allow_reverify` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否允许同设备重复验证(1:允许, 0:不允许)',
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `encryption_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'sha1' COMMENT '加密类型 (sha1, rc4)',
  `card_type` enum('time','count') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'time' COMMENT '卡密类型：time-时间卡密，count-次数卡密',
  `total_count` int NOT NULL DEFAULT 0 COMMENT '总次数（次数卡密专用）',
  `remaining_count` int NOT NULL DEFAULT 0 COMMENT '剩余次数（次数卡密专用）',
  `creator_type` enum('admin','user') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'admin' COMMENT '创建者类型：admin-管理员，user-普通用户',
  `creator_id` int NOT NULL COMMENT '创建者ID（对应admins表或users表的id）',
  `creator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建者用户名',
  `ip_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `api_key_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `card_key`(`card_key` ASC) USING BTREE,
  UNIQUE INDEX `encrypted_key`(`encrypted_key` ASC) USING BTREE,
  INDEX `device_id`(`device_id` ASC) USING BTREE,
  INDEX `creator_type`(`creator_type` ASC) USING BTREE,
  INDEX `creator_id`(`creator_id` ASC) USING BTREE,
  INDEX `creator_name`(`creator_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 63 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cards
-- ----------------------------

-- ----------------------------
-- Table structure for features
-- ----------------------------
DROP TABLE IF EXISTS `features`;
CREATE TABLE `features`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of features
-- ----------------------------
INSERT INTO `features` VALUES (1, 'fas fa-shield-alt', '安全可靠', '采用先进的加密技术，确保卡密数据安全\n数据加密存储\n防暴力破解\n安全性验证', 1, 1);
INSERT INTO `features` VALUES (2, 'fas fa-code', 'API接口', '提供完整的API接口，支持多种验证方式\nRESTful API\n多种验证方式\n详细接口文档', 2, 1);
INSERT INTO `features` VALUES (3, 'fas fa-tachometer-alt', '高效稳定', '系统运行稳定，响应迅速\n快速响应\n稳定运行\n性能优化', 3, 1);
INSERT INTO `features` VALUES (4, 'fas fa-chart-line', '数据统计', '详细的数据统计和分析功能\n实时统计\n数据分析\n图表展示', 4, 1);

-- ----------------------------
-- Table structure for operation_logs
-- ----------------------------
DROP TABLE IF EXISTS `operation_logs`;
CREATE TABLE `operation_logs`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int NOT NULL,
  `admin_username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `operation_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型',
  `operation_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作内容',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `admin_id`(`admin_id` ASC) USING BTREE,
  INDEX `operation_type`(`operation_type` ASC) USING BTREE,
  INDEX `create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of operation_logs
-- ----------------------------

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Order No',
  `user_id` int NOT NULL COMMENT 'User ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Username',
  `card_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Card Type',
  `card_spec` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Specification',
  `quantity` int NOT NULL DEFAULT 1 COMMENT 'Quantity',
  `unit_price` decimal(10, 2) NULL DEFAULT 0.00 COMMENT 'Unit Price',
  `total_price` decimal(10, 2) NOT NULL COMMENT 'Total Price',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT 'Status: pending, completed, failed',
  `payment_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'wechat' COMMENT 'Payment Method',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `pay_time` datetime NULL DEFAULT NULL COMMENT 'Payment Time',
  `card_keys` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'Allocated Card Keys',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `order_no`(`order_no` ASC) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of orders
-- ----------------------------

-- ----------------------------
-- Table structure for settings
-- ----------------------------
DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 245 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of settings
-- ----------------------------
INSERT INTO `settings` VALUES (1, 'site_title', '小小怪卡密验证系统');
INSERT INTO `settings` VALUES (2, 'site_subtitle', '专业的卡密验证解决方案');
INSERT INTO `settings` VALUES (3, 'copyright_text', '小小怪卡密系统 - All Rights Reserved');
INSERT INTO `settings` VALUES (4, 'contact_qq_group', '123456789');
INSERT INTO `settings` VALUES (5, 'contact_wechat_qr', 'assets/images/wechat-qr.jpg');
INSERT INTO `settings` VALUES (6, 'contact_email', 'support@example.com');
INSERT INTO `settings` VALUES (7, 'api_enabled', '1');
INSERT INTO `settings` VALUES (8, 'api_key', 'c3d01e574865a180a20f71c4a0e41c07');
INSERT INTO `settings` VALUES (9, 'smtp_server', 'smtp.qq.com');
INSERT INTO `settings` VALUES (10, 'smtp_port', '465');
INSERT INTO `settings` VALUES (11, 'smtp_email', 'xxgyyds@vip.qq.com');
INSERT INTO `settings` VALUES (12, 'smtp_password', 'zhckdqaqydmddjgb');
INSERT INTO `settings` VALUES (13, 'smtp_ssl', 'true');
INSERT INTO `settings` VALUES (14, 'sender_name', 'XXG卡密系统');
INSERT INTO `settings` VALUES (15, 'notify_user_reg', 'true');
INSERT INTO `settings` VALUES (16, 'notify_order_create', 'true');
INSERT INTO `settings` VALUES (17, 'notify_key_used', 'true');
INSERT INTO `settings` VALUES (18, 'notify_sys_maint', 'true');
INSERT INTO `settings` VALUES (19, 'notify_sec_alert', 'true');
INSERT INTO `settings` VALUES (20, 'tpl_user_reg', '欢迎注册XXG卡密系统！您的账户已成功创建。');
INSERT INTO `settings` VALUES (21, 'tpl_order_notify', '您的订单已创建成功，订单号：{orderNumber}，请及时查看。');
INSERT INTO `settings` VALUES (22, 'tpl_sys_maint', '系统将于{time}进行维护，预计维护时间{duration}，请提前做好准备。');
INSERT INTO `settings` VALUES (65, 'systemName', 'XXG卡密系统');
INSERT INTO `settings` VALUES (66, 'systemDescription', '专业的卡密管理系统');
INSERT INTO `settings` VALUES (67, 'defaultLanguage', 'zh-CN');
INSERT INTO `settings` VALUES (68, 'timezone', 'Asia/Shanghai');
INSERT INTO `settings` VALUES (69, 'autoBackup', 'true');
INSERT INTO `settings` VALUES (70, 'backupFrequency', 'daily');
INSERT INTO `settings` VALUES (71, 'backupRetention', '7');
INSERT INTO `settings` VALUES (72, 'dataCompression', 'true');
INSERT INTO `settings` VALUES (73, 'payment_enabled', 'true');
INSERT INTO `settings` VALUES (74, 'epay_api_url', 'https://www.ezfpy.cn/');
INSERT INTO `settings` VALUES (75, 'epay_pid', '146');
INSERT INTO `settings` VALUES (76, 'epay_key', 'mbYgrDma0JUlpfVsJogxKz6fka0qNSEE');
INSERT INTO `settings` VALUES (77, 'epay_notify_url', '');
INSERT INTO `settings` VALUES (78, 'epay_return_url', '');
INSERT INTO `settings` VALUES (79, 'site_url', 'http://localhost:5173');

-- ----------------------------
-- Table structure for slides
-- ----------------------------
DROP TABLE IF EXISTS `slides`;
CREATE TABLE `slides`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 1,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of slides
-- ----------------------------
INSERT INTO `slides` VALUES (1, '安全可靠的验证系统', '采用先进的加密技术，确保您的数据安全', 'assets/images/slide1.jpg', 1, 1, '2025-05-06 09:13:25');
INSERT INTO `slides` VALUES (2, '便捷高效的验证流程', '支持多种验证方式，快速响应', 'assets/images/slide2.jpg', 2, 1, '2025-05-06 09:13:25');
INSERT INTO `slides` VALUES (3, '完整的API接口', '提供丰富的接口，便于集成', 'assets/images/slide3.jpg', 3, 1, '2025-05-06 09:13:25');

-- ----------------------------
-- Table structure for spring_session
-- ----------------------------
DROP TABLE IF EXISTS `spring_session`;
CREATE TABLE `spring_session`  (
  `PRIMARY_ID` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `SESSION_ID` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `CREATION_TIME` bigint NOT NULL,
  `LAST_ACCESS_TIME` bigint NOT NULL,
  `MAX_INACTIVE_INTERVAL` int NOT NULL,
  `EXPIRY_TIME` bigint NOT NULL,
  `PRINCIPAL_NAME` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`PRIMARY_ID`) USING BTREE,
  UNIQUE INDEX `SPRING_SESSION_IX1`(`SESSION_ID` ASC) USING BTREE,
  INDEX `SPRING_SESSION_IX2`(`EXPIRY_TIME` ASC) USING BTREE,
  INDEX `SPRING_SESSION_IX3`(`PRINCIPAL_NAME` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of spring_session
-- ----------------------------

-- ----------------------------
-- Table structure for spring_session_attributes
-- ----------------------------
DROP TABLE IF EXISTS `spring_session_attributes`;
CREATE TABLE `spring_session_attributes`  (
  `SESSION_PRIMARY_ID` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ATTRIBUTE_NAME` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ATTRIBUTE_BYTES` blob NOT NULL,
  PRIMARY KEY (`SESSION_PRIMARY_ID`, `ATTRIBUTE_NAME`) USING BTREE,
  CONSTRAINT `SPRING_SESSION_ATTRIBUTES_FK` FOREIGN KEY (`SESSION_PRIMARY_ID`) REFERENCES `spring_session` (`PRIMARY_ID`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of spring_session_attributes
-- ----------------------------

-- ----------------------------
-- Table structure for system_maintenance
-- ----------------------------
DROP TABLE IF EXISTS `system_maintenance`;
CREATE TABLE `system_maintenance`  (
  `id` int NOT NULL,
  `enabled` tinyint(1) NULL DEFAULT 0,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `maintenance_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `start_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email_subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `email_template` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of system_maintenance
-- ----------------------------
INSERT INTO `system_maintenance` VALUES (1, 0, '系统正在维护中，请稍后访问。', '8小时', '', '小小怪卡密系统维护通知', '');

-- ----------------------------
-- Table structure for user_api_keys
-- ----------------------------
DROP TABLE IF EXISTS `user_api_keys`;
CREATE TABLE `user_api_keys`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `api_key_id` bigint NOT NULL,
  `assign_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id` ASC, `api_key_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_api_keys
-- ----------------------------

-- ----------------------------
-- Table structure for user_sessions
-- ----------------------------
DROP TABLE IF EXISTS `user_sessions`;
CREATE TABLE `user_sessions`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `session_token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会话令牌',
  `device_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备信息',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '用户代理',
  `expires_at` datetime NOT NULL COMMENT '过期时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `last_activity` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后活动时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `session_token`(`session_token` ASC) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `expires_at`(`expires_at` ASC) USING BTREE,
  CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户会话表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_sessions
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '邮箱',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码（加密存储）',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `email_verified` tinyint(1) NOT NULL DEFAULT 0 COMMENT '邮箱是否验证：0-未验证，1-已验证',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `login_count` int NOT NULL DEFAULT 0 COMMENT '登录次数',
  `register_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '注册IP',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `access_token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `refresh_token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE,
  INDEX `status`(`status` ASC) USING BTREE,
  INDEX `create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '普通用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'testuser', 'test@example.com', '$2y$10$gxgRAiv63rkmLDQcg1WcdumpGSKoia1pt5hVYsK2cJSpcwzVRFnjq', '测试用户', NULL, NULL, 1, 0, NULL, NULL, 0, '127.0.0.1', '2025-09-22 03:35:00', '2025-09-22 03:35:00', NULL, NULL);
INSERT INTO `users` VALUES (2, 'demo', '3162396861@qq.com', '$2y$10$gxgRAiv63rkmLDQcg1WcdumpGSKoia1pt5hVYsK2cJSpcwzVRFnjq', '演示用户', 'http://localhost:8080/api/uploads/avatars/8d16f607-7913-4d7c-9b95-1b8a2ad43b65.png', '19912345678', 1, 0, '2026-01-14 19:54:49', '127.0.0.1', 12, '127.0.0.1', '2025-09-22 03:35:00', '2026-01-14 19:54:48', 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidXNlciIsInR5cGUiOiJhY2Nlc3MiLCJzdWIiOiJkZW1vIiwiaWF0IjoxNzY4MzkxNjg4LCJleHAiOjE3NjgzOTUyODh9.e71QxuNCH7b-udXCln4kxfRXzfWJ3q1PB7EDE9tD3g4', 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidXNlciIsInR5cGUiOiJyZWZyZXNoIiwic3ViIjoiZGVtbyIsImlhdCI6MTc2ODM5MTY4OCwiZXhwIjoxNzY4OTk2NDg4fQ.OcXguBpUg9Jqjjfg32zsuLCNB-OWtLBwWIpsOyJ-qHk');
INSERT INTO `users` VALUES (5, 'xxg', 'xxg_temp@example.com', '$2a$10$Vt3i1mxQ5NHZ3qOEaxCPx.4iTGc6OND..BpQQVWU2bfStRlxmHUw6', 'xxg', NULL, '19983066553', 1, 1, '2026-01-10 20:02:55', '127.0.0.1', 3, '127.0.0.1', '2026-01-10 15:07:25', '2026-01-10 20:03:10', NULL, NULL);

-- ----------------------------
-- Table structure for verification_codes
-- ----------------------------
DROP TABLE IF EXISTS `verification_codes`;
CREATE TABLE `verification_codes`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'register' COMMENT 'register, reset_password',
  `expire_time` datetime NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `email`(`email` ASC) USING BTREE,
  INDEX `code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of verification_codes
-- ----------------------------
INSERT INTO `verification_codes` VALUES (2, '3162396861@qq.com', '704051', 'reset_password', '2026-01-10 14:44:59', '2026-01-10 14:39:59');

SET FOREIGN_KEY_CHECKS = 1;
