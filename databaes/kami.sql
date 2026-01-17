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

 Date: 16/01/2026 12:09:30
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
INSERT INTO `admins` VALUES (2, 'admin', '123456', '2025-05-20 08:18:44', '2026-01-16 10:37:40', 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYWRtaW4iLCJ0eXBlIjoiYWNjZXNzIiwic3ViIjoiYWRtaW4iLCJpYXQiOjE3Njg1MzEwNTksImV4cCI6MTc2ODUzNDY1OX0.4LlyJ14HoDDbtu4RY9zUH35lO4PqcW3L0snFHCjQDOk', 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYWRtaW4iLCJ0eXBlIjoicmVmcmVzaCIsInN1YiI6ImFkbWluIiwiaWF0IjoxNzY4NTMxMDYwLCJleHAiOjE3NjkxMzU4NjB9.1Ck4w_z-Iw2HboE-IOuYwykI6ZgPvViqDfxyQY2F3do');

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
  `webhook_config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `api_key`(`api_key` ASC) USING BTREE,
  UNIQUE INDEX `idx_api_key_value`(`key_value` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_keys
-- ----------------------------
INSERT INTO `api_keys` VALUES (3, '123', '8WAD3TN9YCUZivmDAdicvYs5Q7Hj0zcB', 1, '2025-05-13 15:44:55', '2025-05-13 17:42:27', 5, '123', '89c13e4b-ee08-11f0-bbca-088fc3fb7e69', 'API Key', '2026-01-10 17:47:21');
INSERT INTO `api_keys` VALUES (4, '456', '1jTQXXpBBRMgdPjv63QpU29k4tUwCY78', 1, '2025-05-13 16:56:51', NULL, 0, '456', '89c14863-ee08-11f0-bbca-088fc3fb7e69', 'API Key', '2026-01-10 17:47:21');

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
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `cards` VALUES (33, '5YuOiG1XqfI0WxMZTMki', '06807a70b85a77746c3052067dec9c0091048edb', 1, '2025-05-13 18:06:58', NULL, NULL, 30, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'admin', 1, '123', NULL);
INSERT INTO `cards` VALUES (34, '2vGa8kN0Zy1S5uvGBxq9', '8ae5443059f81cb79e437b315384ea175aa78e0f', 1, '2025-05-13 18:06:58', NULL, NULL, 30, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'admin', 1, '123', NULL);
INSERT INTO `cards` VALUES (35, 'XUensLpopa5vmkQYmPcS', '5b87fc13a67d2c8d21816343877d4b8a33cdd28e', 1, '2025-05-13 18:06:58', NULL, NULL, 30, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'admin', 1, '123', NULL);
INSERT INTO `cards` VALUES (36, '5AalGilBh2K41VysoorW', '9a1e75a8ba87eef8c10bc735c6f76900e7d17656', 1, '2025-05-13 18:06:58', NULL, NULL, 30, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'admin', 1, '123', NULL);
INSERT INTO `cards` VALUES (37, 'okvbwDm1av7dnBqaOfda', 'f03670f414711057a31ae35d2661f8a4ac647fa3', 1, '2025-05-13 18:06:58', NULL, NULL, 30, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'admin', 1, '123', NULL);
INSERT INTO `cards` VALUES (39, '65510424E62C497B', '07d3147eae1243c4fa6c5a8f15cd99ed1415cda5', 0, '2026-01-10 17:12:34', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (40, 'A6886D90BC114B7C', '3be8632380e59c20f3cd9dde3bd59524a95e91d7', 1, '2026-01-10 17:58:03', '2026-01-10 18:15:40', NULL, 60, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (41, 'CA14BA7A0B084133', 'e926c0f16f59e72778b864d7832dcd168fecdbf1', 0, '2026-01-10 20:03:02', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 5, 'xxg', NULL);
INSERT INTO `cards` VALUES (42, 'E821BB8A582D4C64', '9949f7a48dfd22a4038a8a6f45dc22915507c6ad', 0, '2026-01-16 10:54:53', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (43, 'A44649A288C441CD', '4b4f6861ca4c883bd8ff197b6aace92e62b395a6', 0, '2026-01-16 11:00:13', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (44, '322FA33298504FFF', 'c8bb5eacc87e659c0a551f9471c910edadf84baf', 0, '2026-01-16 11:00:54', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (45, '9CDE1463F0994750', '70e2f0f8f0a8163a919961880d09af073b796662', 0, '2026-01-16 11:01:23', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (46, '45F7822122FD4591', '09f292cc937b16da5e1bd0510ae10e4c6fdf22d3', 0, '2026-01-16 11:04:55', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (47, '84F73BF3D6344138', '726bab1c4ccbd18ff5d35694bc204aa8f4778dfe', 0, '2026-01-16 11:06:25', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (48, '2C2D162A75C34619', 'b6176792de0c1de26a5260916deb1e0259519d1b', 0, '2026-01-16 11:09:41', NULL, NULL, 15, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (49, '68C4EAD34D044AA8', 'b584727db2da10dd5065787a4429f3683a23b857', 0, '2026-01-16 11:13:58', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (50, '3B70396E10D34F16', 'a56875eeec32b3d35d1e63fe9cb54a5d3d6137d1', 0, '2026-01-16 11:18:55', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (51, '19131BBC6B964A94', 'b44d4399a4c44e659538122f6f729603fbb8a1cc', 0, '2026-01-16 11:22:15', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (52, '594C4442526A43A3', '8d04796f5372de574e55fc480e7b18c2b8717a3d', 0, '2026-01-16 11:37:45', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (53, 'FFE90A3183AF428D', '190b429b63bffc4ea2202af751ccdb6339e918d0', 0, '2026-01-16 11:39:17', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (54, 'FDE73AEF252B4C96', '3a4bc32cf86c823e94f4b85420183591d05f0258', 0, '2026-01-16 11:40:58', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (55, 'BD006EFBED894D0E', '7d09b7bb7fba77865875160b81949e2bf2136ae2', 0, '2026-01-16 11:43:25', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (56, '277A8182793C4BCA', '3e4070dcdcb66e1fadb7a346de577a2c33db10bd', 0, '2026-01-16 11:44:33', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (57, '6B7C23E016BF40BE', '6366d37db095b5bafa29013c25e40fd604b99e5b', 0, '2026-01-16 11:48:02', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (58, 'A94FFD2E8B754B1A', 'de2693e09747b61800bb6244568dc9ae1e84c44b', 0, '2026-01-16 11:48:32', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (59, 'C401BDB19AA54430', '5d2a04e57ad7357a143584083aed6e1e04dea5be', 0, '2026-01-16 11:52:52', NULL, NULL, 15, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (60, '65DC985AA1CC4B32', '2cdcba2687ea1c04893399dd585a99faaa0a1eb5', 0, '2026-01-16 11:59:37', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (61, 'DAD940D051544A91', '9f636862eefd006aad03455804564b94476e5831', 0, '2026-01-16 12:02:22', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);
INSERT INTO `cards` VALUES (62, '8F1D74C104DA42AC', 'f01f674a0effc8a72724c803a4752ac5cb3df020', 0, '2026-01-16 12:03:35', NULL, NULL, 7, 'web', 1, NULL, 'sha1', 'time', 0, 0, 'user', 2, 'demo', NULL);

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
INSERT INTO `orders` VALUES (1, 'ORD20260110153702367', 1, 'demo', 'time', '30天时间卡', 1, 35.00, 35.00, 'completed', 'wechat', '2026-01-10 15:37:02', NULL, NULL, '5YuOiG1XqfI0WxMZTMki');
INSERT INTO `orders` VALUES (2, 'ORD20260110154049791', 1, 'demo', 'time', '30天时间卡', 1, 35.00, 35.00, 'completed', 'wechat', '2026-01-10 15:40:49', NULL, NULL, '2vGa8kN0Zy1S5uvGBxq9');
INSERT INTO `orders` VALUES (3, 'ORD20260110154451742', 2, 'demo', 'time', '30?', 1, 35.00, 35.00, 'completed', 'alipay', '2026-01-10 15:44:51', NULL, NULL, 'XUensLpopa5vmkQYmPcS');
INSERT INTO `orders` VALUES (4, 'ORD20260110154623436', 1, 'demo', 'time', '30天时间卡', 1, 35.00, 35.00, 'completed', 'wechat', '2026-01-10 15:46:23', NULL, NULL, '5AalGilBh2K41VysoorW');
INSERT INTO `orders` VALUES (5, 'ORD20260110154650650', 1, 'xxg', 'time', '30天时间卡', 1, 35.00, 35.00, 'completed', 'wechat', '2026-01-10 15:46:50', NULL, NULL, 'okvbwDm1av7dnBqaOfda');
INSERT INTO `orders` VALUES (6, 'ORD20260110162159505', 1, 'demo', 'time', '7天时间卡', 1, 9.90, 9.90, 'completed', 'wechat', '2026-01-10 16:22:00', NULL, NULL, '389A3D2CA4934175');
INSERT INTO `orders` VALUES (7, 'ORD20260110171234155', 2, 'demo', 'time', '7天时间卡', 1, 9.90, 9.90, 'completed', 'wechat', '2026-01-10 17:12:34', NULL, NULL, '65510424E62C497B');
INSERT INTO `orders` VALUES (8, 'ORD20260110175803992', 2, 'demo', 'time', '60天时间卡', 1, 65.00, 65.00, 'completed', 'wechat', '2026-01-10 17:58:03', NULL, NULL, 'A6886D90BC114B7C');
INSERT INTO `orders` VALUES (9, 'ORD20260110200301719', 5, 'xxg', 'time', '7天时间卡', 1, 9.90, 9.90, 'completed', 'wechat', '2026-01-10 20:03:02', NULL, NULL, 'CA14BA7A0B084133');
INSERT INTO `orders` VALUES (10, 'ORD20260116105453388', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'pending', 'wechat', '2026-01-16 10:54:53', NULL, NULL, 'E821BB8A582D4C64');
INSERT INTO `orders` VALUES (11, 'ORD20260116110013387', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'pending', 'wechat', '2026-01-16 11:00:13', NULL, NULL, 'A44649A288C441CD');
INSERT INTO `orders` VALUES (12, 'ORD20260116110053887', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'failed', 'wechat', '2026-01-16 11:00:54', '2026-01-16 11:10:10', NULL, '322FA33298504FFF');
INSERT INTO `orders` VALUES (13, 'ORD20260116110122115', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'failed', 'wechat', '2026-01-16 11:01:23', '2026-01-16 11:10:08', NULL, '9CDE1463F0994750');
INSERT INTO `orders` VALUES (14, 'ORD20260116110455978', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'failed', 'wechat', '2026-01-16 11:04:55', '2026-01-16 11:10:06', NULL, '45F7822122FD4591');
INSERT INTO `orders` VALUES (15, 'ORD20260116110625133', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'failed', 'wechat', '2026-01-16 11:06:25', '2026-01-16 11:10:04', NULL, '84F73BF3D6344138');
INSERT INTO `orders` VALUES (16, 'ORD20260116110940143', 2, 'demo', 'time', '15天时间卡', 1, 18.80, 18.80, 'failed', 'wechat', '2026-01-16 11:09:41', '2026-01-16 11:10:02', NULL, '2C2D162A75C34619');
INSERT INTO `orders` VALUES (17, 'ORD20260116111358341', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'pending', 'alipay', '2026-01-16 11:13:58', NULL, NULL, '68C4EAD34D044AA8');
INSERT INTO `orders` VALUES (18, 'ORD20260116111855562', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'pending', 'alipay', '2026-01-16 11:18:55', NULL, NULL, '3B70396E10D34F16');
INSERT INTO `orders` VALUES (19, 'ORD20260116112215346', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'pending', 'alipay', '2026-01-16 11:22:15', NULL, NULL, '19131BBC6B964A94');
INSERT INTO `orders` VALUES (20, 'ORD20260116113744831', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'pending', 'alipay', '2026-01-16 11:37:45', NULL, NULL, '594C4442526A43A3');
INSERT INTO `orders` VALUES (21, 'ORD20260116113917529', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'pending', 'alipay', '2026-01-16 11:39:18', NULL, NULL, 'FFE90A3183AF428D');
INSERT INTO `orders` VALUES (22, 'ORD20260116114058906', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'pending', 'alipay', '2026-01-16 11:40:58', NULL, NULL, 'FDE73AEF252B4C96');
INSERT INTO `orders` VALUES (23, 'ORD20260116114325322', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'pending', 'alipay', '2026-01-16 11:43:25', NULL, NULL, 'BD006EFBED894D0E');
INSERT INTO `orders` VALUES (24, 'ORD20260116114432105', 2, 'demo', 'time', '7天时间卡', 1, 10.90, 10.90, 'pending', 'alipay', '2026-01-16 11:44:33', NULL, NULL, '277A8182793C4BCA');
INSERT INTO `orders` VALUES (25, 'ORD20260116114802818', 2, 'demo', 'time', '7天时间卡', 1, 0.01, 0.01, 'pending', 'alipay', '2026-01-16 11:48:02', NULL, NULL, '6B7C23E016BF40BE');
INSERT INTO `orders` VALUES (26, 'ORD20260116114831763', 2, 'demo', 'time', '7天时间卡', 1, 0.01, 0.01, 'pending', 'alipay', '2026-01-16 11:48:32', NULL, NULL, 'A94FFD2E8B754B1A');
INSERT INTO `orders` VALUES (27, 'ORD20260116115251119', 2, 'demo', 'time', '15天时间卡', 1, 0.02, 0.02, 'pending', 'alipay', '2026-01-16 11:52:52', NULL, NULL, 'C401BDB19AA54430');
INSERT INTO `orders` VALUES (28, 'ORD20260116115936134', 2, 'demo', 'time', '7天时间卡', 1, 0.01, 0.01, 'pending', 'alipay', '2026-01-16 11:59:37', NULL, NULL, '65DC985AA1CC4B32');
INSERT INTO `orders` VALUES (29, 'ORD20260116120221584', 2, 'demo', 'time', '7天时间卡', 1, 0.01, 0.01, 'pending', 'alipay', '2026-01-16 12:02:22', NULL, NULL, 'DAD940D051544A91');
INSERT INTO `orders` VALUES (30, 'ORD20260116120334217', 2, 'demo', 'time', '7天时间卡', 1, 0.01, 0.01, 'pending', 'alipay', '2026-01-16 12:03:35', NULL, NULL, '8F1D74C104DA42AC');

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_maintenance
-- ----------------------------
INSERT INTO `system_maintenance` VALUES (1, 0, '系统正在维护中，请稍后访问。', '待定', '', '系统维护通知', '系统将于 {time} 进行维护，预计维护时间 {duration}，请提前做好准备。');

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of verification_codes
-- ----------------------------
INSERT INTO `verification_codes` VALUES (2, '3162396861@qq.com', '704051', 'reset_password', '2026-01-10 14:44:59', '2026-01-10 14:39:59');

SET FOREIGN_KEY_CHECKS = 1;
