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

 Date: 09/02/2026 11:36:00
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
  `totp_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `totp_enabled` tinyint(1) NULL DEFAULT 0,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of admins
-- ----------------------------
INSERT INTO `admins` VALUES (2, 'admin', '$2a$10$Z9RAmlKbGpvbKMtKblOjFe.KrsHYE2pG/IaSJLAjiUvKZnGMYTr.K', '2025-05-20 08:18:44', '2026-02-08 20:38:06', 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYWRtaW4iLCJ0eXBlIjoiYWNjZXNzIiwic3ViIjoiYWRtaW4iLCJpYXQiOjE3NzA1NTQyODUsImV4cCI6MTc3MDU1Nzg4NX0.8DUrP1IwiwS70xRkTv7By_KQzNKjqeaeN5bbIb42dOw', 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYWRtaW4iLCJ0eXBlIjoicmVmcmVzaCIsInN1YiI6ImFkbWluIiwiaWF0IjoxNzcwNTU0Mjg1LCJleHAiOjE3NzExNTkwODV9.qAbh-7rgvahfBUphKLzDokW7z8iyxuz9Ur8pA0_KSlU', NULL, 0, NULL);

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
  `enable_card_encryption` tinyint(1) NULL DEFAULT 0 COMMENT '???????????????',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `api_key`(`api_key` ASC) USING BTREE,
  UNIQUE INDEX `idx_api_key_value`(`key_value` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of api_keys
-- ----------------------------

-- ----------------------------
-- Table structure for card_cipher
-- ----------------------------
DROP TABLE IF EXISTS `card_cipher`;
CREATE TABLE `card_cipher`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `card_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Argon2id hash of cardId + salt',
  `cipher_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Base64 of Encrypted Payload',
  `sign_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Base64 of ECC Signature',
  `salt` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Salt for Argon2id',
  `iv` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Base64 of AES-GCM IV',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `card_hash`(`card_hash` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of card_cipher
-- ----------------------------

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
-- Table structure for card_status
-- ----------------------------
DROP TABLE IF EXISTS `card_status`;
CREATE TABLE `card_status`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `card_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `remain_count` int NOT NULL DEFAULT 0,
  `total_count` int NOT NULL DEFAULT 0,
  `expire_time` datetime NULL DEFAULT NULL,
  `last_use_time` datetime NULL DEFAULT NULL,
  `is_valid` tinyint(1) NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `card_hash`(`card_hash` ASC) USING BTREE,
  INDEX `idx_card_hash`(`card_hash` ASC) USING BTREE,
  CONSTRAINT `fk_card_status_hash` FOREIGN KEY (`card_hash`) REFERENCES `card_cipher` (`card_hash`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of card_status
-- ----------------------------

-- ----------------------------
-- Table structure for cards
-- ----------------------------
DROP TABLE IF EXISTS `cards`;
CREATE TABLE `cards`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `card_key` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `encrypted_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0:未使用 1:已使用 2:已停用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `use_time` datetime NULL DEFAULT NULL,
  `expire_time` datetime NULL DEFAULT NULL,
  `duration` int NOT NULL DEFAULT 0,
  `verify_method` enum('web','post','get') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `allow_reverify` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否允许同设备重复验证(1:允许, 0:不允许)',
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `encryption_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
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
) ENGINE = InnoDB AUTO_INCREMENT = 79 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cards
-- ----------------------------
INSERT INTO `cards` VALUES (73, '+LPvEOy4gTgt4NHV$m6y1H3qzfpB7kzTmGaiQbV9Y8gJNi3vGdBGPKRE7oT3F4sv278azbn45vGnQ3K36EwP1QZDWN2L6SXbayEyvMB8u2NOaqU27pSc+nXmopSlPiGGUOfAsf5JDeJDJBymtx+KGIOLhCz8/FMsMxcm+LnVDgoECGsxVpZvCQ+JM6LTxcFpdnk+C9jctJQbFrLv7LyEPyNIEYchqs8Bhxkq5vlhGogSMAN4=$MGUCMQDAaUb+cHYFdnC3yKUMLedXLTNQZOsqPLsSfHrUHcLKKvzN9trHjmIjZ09POzxkfw0CMHNRoK+2ekbQ1raTG/ft9yddOTAf8bSbVXi3k1RWltNm9AzzvzYRbQBu9RiwFmwbyQ==', 'wrcRrQQHTqdkaqhdQmWu3+RpVpGIi4V95sJRqrRmA1Y=', 1, '2026-02-08 19:57:38', '2026-02-08 20:08:50', NULL, 30, 'web', 1, NULL, 'advanced', 'count', 100, 100, 'admin', 2, 'admin', NULL, NULL);
INSERT INTO `cards` VALUES (74, 'JBNsnh2/GT1jO27l$pPARlplITSsNvjXZUaKnLZepOwrqCJBGQjObkgLpsNV7KlhtLroaYA7ba1/XqT11DSQTlITSoPMV/y0PnodKq5E7BMpXRc1AHzIaySYKXGvkPLKQwr+RvgiIqwNXwRIbtmKD1BG3z+uaIqGGqqLrQiFIaAdUaRrJX3UZaihjy3KTNYrR7x3n/+X/FMmYKJ3Qejl3i9eS6yXxWCiGah55G2xf++M6$MGUCMQDUNCGbcQ8BhHg7zFGzEB8KvWo3Eu+LN+2XmUAivtcP7mA2KlZ5sTv/aqpbyTpCqEQCMCskwXyEvliUfj1IdQ93Hbt6b71P4WYFJypTpUf+DyyQCwT0S3iU/j3WHlU4BTHb2w==', 'YcQPxy3vuUMPhyHHf3/JIX5sGgR96FhOGWGlqRM5kV0=', 1, '2026-02-08 20:02:53', '2026-02-08 20:03:19', NULL, 30, 'web', 1, NULL, 'advanced', 'time', 0, 0, 'admin', 2, 'admin', NULL, 7);
INSERT INTO `cards` VALUES (75, 'XNgOS4saxILUrKss$Xb2bajK2WF8/JKnRvQyWKSQUyr4+lcqKph1gzeK0D5NFnu24YexLAPCekgqBGoP6K+icORymAvZoIg9zsCrvYXhyIY4iDeue+ppO0QiJApZezfl29+7ExCR8skbcyNawMYuk4g1LRL8xGxhtkbVpW5mtGcsvE4lMDUTAPWUSda6mQDE+9o7qJTEvW2h3ygafeIo6SGmcYDPMBImbn8NWFhzxR2YY$MGYCMQDfu9/lDaKDAyhIUlWdQhuf9GOUC00S3hea4Zd8BuHC+18ew9LbGVaOnxMz2KmK6/wCMQD2/Ysdd+G7j8H5+AlcK7NXmZaazx66+uGHCeAiiOl7GPG/x3QAaIn0uHM5cZCDhuM=', 'fMNZd1nV434dIpDG47Hx2cscQF1Yejvb60/koR7tagQ=', 1, '2026-02-08 20:09:11', '2026-02-08 20:09:41', NULL, 30, 'web', 1, NULL, 'advanced', 'time', 0, 0, 'admin', 2, 'admin', NULL, 8);
INSERT INTO `cards` VALUES (76, '6ykiDDUbvO3JQKvu$IhNueM/FXOUzel8zEBZCHSM9zCn/MfBtnM/07SJhs3qZQJVixTKQtB9eKY3Fh1+KL4AMaLcX9trlLSQGbbjorAr0VVfUbs6ISLPXxLTy0oKcwY9mWg/ohgzgRSgNTGtd7LK/GgYCbY02gT+qbPt4Ch8e9sOaxe+bM0NyDi6qZtp35WKaw4a9+27tiz6X/+AsGSS6eu1qt82mPxFigAfjj6xHPmGa$MGQCMGrzjT9XkryiWSqCZr9dTgvQ7gb31+h5NepBHS+b9hXNWqMI3onxbGG36/nbz8oqewIwNAX5pkHdPhH4PfL/UI0Nvo38eLg+iz/zo9l8J3njpCcKFtLXPUpksFY/RbmNvYmc', 'xdXCKkyH541M5cGMkcXXsubLUIzZnp+TZIJXESv26Mg=', 1, '2026-02-08 20:12:03', '2026-02-08 20:56:58', NULL, 30, 'web', 1, NULL, 'advanced', 'time', 0, 0, 'admin', 2, 'admin', NULL, 8);
INSERT INTO `cards` VALUES (77, 'ZlKYiB+uVnLmumFH$WfCV1/lyqqEj/m0RDxKWEbbuIolUipSsPHClsBGnew6biBzvG5KCyIEzkAOoKJ9quwSRQo2wOwgXu7fYqE9/B4Yk9jIo45/MAvn13LG72ZYzGI3+royXIBE9j1LsCHdkRfFCAczH05bCWC2czrYRRmYCWGx7AhKXWSjFewtZMLsBr/MDOgKun8v6BeTPpTsFU9T3L9nyhNtctpy3ooBhpOHcDbHw$MGUCMQDrdU769E7wCuu4mUctdoB7e8swY4gZ6eXjdlq8458cmKI2y55ZSYvm8kxAbi+4Y+MCMDJU0ui0rZe65xllQquQmuc+vYmERs2o0ZZ4eX0ByocfYG5Mjrq3MK2HLHXbhb321g==', 'viGTCJeZzvUl1oSM/x0t2JuB2o4tbkBfEBudbaYzVzk=', 1, '2026-02-08 20:26:02', '2026-02-08 20:57:50', NULL, 30, 'web', 1, NULL, 'advanced', 'time', 0, 0, 'admin', 2, 'admin', NULL, 8);
INSERT INTO `cards` VALUES (78, 'Rz6DMLxZ28tSnMfX$v4TaFp4/SNCIu2kyon+1z5Mojc4fbAmhAoUyowmJrNNypyZ7/ojkWT/pPX2UlXDb80AvseXyQPXShoAVQi2a+IzzfYeIfjllolOqYW4Ixze+JqxSiSuGjtzq0ByFBVBfKKDrEsT9PZC6SW7Qgc0SzciPlkjeNO9INDHpuRuyQuQaGq0Mk7tfYOQpPnacLUGT2GWQ2Nw5Ls1AZG1Q3WeR9iPJ+acD$MGUCMQDeVTQpdfQQts9gkJGYO0LJPhWSb+Usu4XGueA+MxgTx1S1jkHsBG6D35aNGPpnBtkCMCmVWY608EvBTTAjSF/VsusHX32J6StVSwVD+M7qB2Fi1TeDe64mdytXnXci/MVWSw==', 'sVgu8gjEP9lNtD/atjh6e6v59+icP12dCzgYoTOtksE=', 0, '2026-02-08 20:57:19', NULL, NULL, 30, 'web', 1, NULL, 'advanced', 'time', 0, 0, 'admin', 2, 'admin', NULL, 7);

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
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 554 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
INSERT INTO `settings` VALUES (8, 'api_key', '');
INSERT INTO `settings` VALUES (9, 'smtp_server', 'smtp.qq.com');
INSERT INTO `settings` VALUES (10, 'smtp_port', '587');
INSERT INTO `settings` VALUES (11, 'smtp_email', 'admin@example.com');
INSERT INTO `settings` VALUES (12, 'smtp_password', '123');
INSERT INTO `settings` VALUES (13, 'smtp_ssl', 'true');
INSERT INTO `settings` VALUES (14, 'sender_name', 'XXG卡密系统');
INSERT INTO `settings` VALUES (15, 'notify_user_reg', 'true');
INSERT INTO `settings` VALUES (16, 'notify_order_create', 'true');
INSERT INTO `settings` VALUES (17, 'notify_key_used', 'false');
INSERT INTO `settings` VALUES (18, 'notify_sys_maint', 'true');
INSERT INTO `settings` VALUES (19, 'notify_sec_alert', 'true');
INSERT INTO `settings` VALUES (20, 'tpl_user_reg', 'ces ');
INSERT INTO `settings` VALUES (21, 'tpl_order_notify', '您的订单已创建成功，订单号：{orderNumber}，请及时查看。123');
INSERT INTO `settings` VALUES (22, 'tpl_sys_maint', '系统将于{time}进行维护，预计维护时间{duration}，请提前做好准备。');
INSERT INTO `settings` VALUES (65, 'systemName', 'XXG卡密系统');
INSERT INTO `settings` VALUES (66, 'systemDescription', '专业的卡密管理系统');
INSERT INTO `settings` VALUES (67, 'defaultLanguage', 'zh-CN');
INSERT INTO `settings` VALUES (68, 'timezone', 'Asia/Shanghai');
INSERT INTO `settings` VALUES (69, 'autoBackup', 'true');
INSERT INTO `settings` VALUES (70, 'backupFrequency', 'daily');
INSERT INTO `settings` VALUES (71, 'backupRetention', '8');
INSERT INTO `settings` VALUES (72, 'dataCompression', 'true');
INSERT INTO `settings` VALUES (73, 'payment_enabled', 'true');
INSERT INTO `settings` VALUES (74, 'epay_api_url', 'https://www.ezfpy.cn/');
INSERT INTO `settings` VALUES (75, 'epay_pid', 'F2338');
INSERT INTO `settings` VALUES (76, 'epay_key', 'wzz908.');
INSERT INTO `settings` VALUES (77, 'epay_notify_url', '');
INSERT INTO `settings` VALUES (78, 'epay_return_url', '');
INSERT INTO `settings` VALUES (79, 'site_url', 'http://localhost:5173');
INSERT INTO `settings` VALUES (80, 'oauth_url', 'https://baoxian18.com');
INSERT INTO `settings` VALUES (81, 'oauth_appid', '');
INSERT INTO `settings` VALUES (82, 'oauth_appkey', '');
INSERT INTO `settings` VALUES (83, 'oauth_login_types', 'qq,wx,alipay');
INSERT INTO `settings` VALUES (84, 'oauth_callback_domain', '');
INSERT INTO `settings` VALUES (260, 'qqLogin', 'false');
INSERT INTO `settings` VALUES (261, 'authenticatorLogin', 'false');
INSERT INTO `settings` VALUES (262, 'aggregatedLogin', 'false');

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
-- Table structure for social_users
-- ----------------------------
DROP TABLE IF EXISTS `social_users`;
CREATE TABLE `social_users`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `social_uid` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `social_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `social_uid`(`social_uid` ASC, `social_type` ASC) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of social_users
-- ----------------------------

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
INSERT INTO `spring_session` VALUES ('613af0d3-f3c2-48ce-a705-5159aee02958', 'e7bd201d-5f0c-4846-af10-3ddf4da521e3', 1770605261727, 1770607588354, 1800, 1770609388354, NULL);

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
INSERT INTO `spring_session_attributes` VALUES ('613af0d3-f3c2-48ce-a705-5159aee02958', 'SPRING_SECURITY_SAVED_REQUEST', 0xACED0005737200416F72672E737072696E676672616D65776F726B2E73656375726974792E7765622E7361766564726571756573742E44656661756C74536176656452657175657374000000000000026C02000F49000A736572766572506F72744C000B636F6E74657874506174687400124C6A6176612F6C616E672F537472696E673B4C0007636F6F6B6965737400154C6A6176612F7574696C2F41727261794C6973743B4C00076865616465727374000F4C6A6176612F7574696C2F4D61703B4C00076C6F63616C657371007E00024C001C6D61746368696E6752657175657374506172616D657465724E616D6571007E00014C00066D6574686F6471007E00014C000A706172616D657465727371007E00034C000870617468496E666F71007E00014C000B7175657279537472696E6771007E00014C000A7265717565737455524971007E00014C000A7265717565737455524C71007E00014C0006736368656D6571007E00014C000A7365727665724E616D6571007E00014C000B736572766C65745061746871007E0001787000001F907400042F617069737200136A6176612E7574696C2E41727261794C6973747881D21D99C7619D03000149000473697A65787000000007770400000007737200396F72672E737072696E676672616D65776F726B2E73656375726974792E7765622E7361766564726571756573742E5361766564436F6F6B6965000000000000026C0200084900066D61784167655A000673656375726549000776657273696F6E4C0007636F6D6D656E7471007E00014C0006646F6D61696E71007E00014C00046E616D6571007E00014C00047061746871007E00014C000576616C756571007E00017870FFFFFFFF000000000070707400035F67617074001B4741312E312E313830383736323837352E313735323637333439307371007E0008FFFFFFFF0000000000707074000E5F67615F4C3756454448533647387074002D4753322E312E7331373532363733343839246F31246731247431373532363733363332246A3537246C302468307371007E0008FFFFFFFF0000000000707074000D496465612D66333135333834627074002465323831353162382D623764332D346233302D616264642D6138396133653339616664357371007E0008FFFFFFFF0000000000707074000E5F67615F5A344B584542593456507074002D4753322E312E7331373630353037333434246F31246731247431373630353037343137246A3438246C302468307371007E0008FFFFFFFF0000000000707074000963737266746F6B656E707400206F706C54386F534B754B4463664A5364375543324679324C52457861357951787371007E0008FFFFFFFF0000000000707074000F6931386E5F72656469726563746564707400027A687371007E0008FFFFFFFF0000000000707074000E5F67615F3733594A50584A544C587074002D4753322E312E7331373634303431323834246F32246730247431373634303431323834246A3630246C3024683078737200116A6176612E7574696C2E547265654D61700CC1F63E2D256AE60300014C000A636F6D70617261746F727400164C6A6176612F7574696C2F436F6D70617261746F723B78707372002A6A6176612E6C616E672E537472696E672443617365496E73656E736974697665436F6D70617261746F7277035C7D5C50E5CE02000078707704000000107400066163636570747371007E0006000000017704000000017400032A2F2A7874000F6163636570742D656E636F64696E677371007E000600000001770400000001740017677A69702C206465666C6174652C2062722C207A7374647874000F6163636570742D6C616E67756167657371007E00060000000177040000000174002F7A682D434E2C7A683B713D302E392C656E3B713D302E382C656E2D47423B713D302E372C656E2D55533B713D302E367874000D617574686F72697A6174696F6E7371007E0006000000017704000000017400B34265617265722065794A68624763694F694A49557A49314E694A392E65794A796232786C496A6F6959575274615734694C434A306558426C496A6F6959574E6A5A584E7A4969776963335669496A6F6959575274615734694C434A70595851694F6A45334E7A41314E5451794F445573496D5634634349364D5463334D4455314E7A67344E58302E3844557250314977697753373078526B54763742795F4B517A4E4B6A716561654E35626249623432644F777874000A636F6E6E656374696F6E7371007E000600000001770400000001740005636C6F73657874000C636F6E74656E742D747970657371007E0006000000017704000000017400106170706C69636174696F6E2F6A736F6E78740006636F6F6B69657371007E00060000000177040000000174018C5F67613D4741312E312E313830383736323837352E313735323637333439303B205F67615F4C3756454448533647383D4753322E312E7331373532363733343839246F31246731247431373532363733363332246A3537246C302468303B20496465612D66333135333834623D65323831353162382D623764332D346233302D616264642D6138396133653339616664353B20486D5F6C76745F61316666383832356261613733633361373865623936616134303332356162633D313735383530393934322C313735383534303036303B205F67615F5A344B584542593456503D4753322E312E7331373630353037333434246F31246731247431373630353037343137246A3438246C302468303B2063737266746F6B656E3D6F706C54386F534B754B4463664A5364375543324679324C52457861357951783B206931386E5F726564697265637465643D7A683B205F67615F3733594A50584A544C583D4753322E312E7331373634303431323834246F32246730247431373634303431323834246A3630246C3024683078740004686F73747371007E00060000000177040000000174000E6C6F63616C686F73743A3830383078740007726566657265727371007E000600000001770400000001740016687474703A2F2F6C6F63616C686F73743A353137332F787400097365632D63682D75617371007E000600000001770400000001740041224E6F7428413A4272616E64223B763D2238222C20224368726F6D69756D223B763D22313434222C20224D6963726F736F66742045646765223B763D2231343422787400107365632D63682D75612D6D6F62696C657371007E0006000000017704000000017400023F30787400127365632D63682D75612D706C6174666F726D7371007E0006000000017704000000017400092257696E646F7773227874000E7365632D66657463682D646573747371007E000600000001770400000001740005656D7074797874000E7365632D66657463682D6D6F64657371007E000600000001770400000001740004636F72737874000E7365632D66657463682D736974657371007E00060000000177040000000174000B73616D652D6F726967696E7874000A757365722D6167656E747371007E00060000000177040000000174007D4D6F7A696C6C612F352E30202857696E646F7773204E542031302E303B2057696E36343B2078363429204170706C655765624B69742F3533372E333620284B48544D4C2C206C696B65204765636B6F29204368726F6D652F3134342E302E302E30205361666172692F3533372E3336204564672F3134342E302E302E3078787371007E000600000005770400000005737200106A6176612E7574696C2E4C6F63616C657EF811609C30F9EC03000649000868617368636F64654C0007636F756E74727971007E00014C000A657874656E73696F6E7371007E00014C00086C616E677561676571007E00014C000673637269707471007E00014C000776617269616E7471007E00017870FFFFFFFF740002434E7400007400027A6871007E005771007E0057787371007E0054FFFFFFFF71007E005771007E005771007E005871007E005771007E0057787371007E0054FFFFFFFF71007E005771007E0057740002656E71007E005771007E0057787371007E0054FFFFFFFF740002474271007E005771007E005B71007E005771007E0057787371007E0054FFFFFFFF740002555371007E005771007E005B71007E005771007E00577878740008636F6E74696E75657400034745547371007E001E7077040000000274000470616765757200135B4C6A6176612E6C616E672E537472696E673BADD256E7E91D7B470200007870000000017400013174000473697A657571007E0064000000017400023130787074000E706167653D312673697A653D31307400102F6170692F61646D696E2F7573657273740025687474703A2F2F6C6F63616C686F73743A383038302F6170692F61646D696E2F7573657273740004687474707400096C6F63616C686F737474000C2F61646D696E2F7573657273);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

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
INSERT INTO `users` VALUES (1, 'testuser', 'test@example.com', '$2y$10$gxgRAiv63rkmLDQcg1WcdumpGSKoia1pt5hVYsK2cJSpcwzVRFnjq', '测试用户', NULL, NULL, 1, 0, '2026-01-29 20:52:25', '127.0.0.1', 4, '127.0.0.1', '2025-09-22 03:35:00', '2026-01-29 20:58:32', NULL, NULL);

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

SET FOREIGN_KEY_CHECKS = 1;
