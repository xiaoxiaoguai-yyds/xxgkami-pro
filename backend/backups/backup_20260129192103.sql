-- MySQL dump 10.13  Distrib 9.3.0, for Win64 (x86_64)
--
-- Host: localhost    Database: kami
-- ------------------------------------------------------
-- Server version	9.3.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `kami`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `kami` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `kami`;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login` datetime DEFAULT NULL,
  `access_token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `refresh_token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `totp_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `totp_enabled` tinyint(1) DEFAULT '0',
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (2,'admin','123456','2025-05-20 08:18:44','2026-01-26 18:05:27','eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYWRtaW4iLCJ0eXBlIjoiYWNjZXNzIiwic3ViIjoiYWRtaW4iLCJpYXQiOjE3Njk0MjE5MjYsImV4cCI6MTc2OTQyNTUyNn0.vQVW0uQRJkJq2XZSfg1z8gYY-0gziQ-HpukyN58nD0s','eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYWRtaW4iLCJ0eXBlIjoicmVmcmVzaCIsInN1YiI6ImFkbWluIiwiaWF0IjoxNzY5NDIxOTI2LCJleHAiOjE3NzAwMjY3MjZ9.AiNbxzSs1pI6E_WusuSiKMSVL0YfCgp1EmVgB0IyNNA',NULL,0,NULL);
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'API密钥名称',
  `api_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'API密钥',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态:0禁用,1启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_use_time` datetime DEFAULT NULL COMMENT '最后使用时间',
  `use_count` int NOT NULL DEFAULT '0' COMMENT '使用次数',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '备注说明',
  `key_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'API Key',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `webhook_config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `api_key` (`api_key`) USING BTREE,
  UNIQUE KEY `idx_api_key_value` (`key_value`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_keys`
--

LOCK TABLES `api_keys` WRITE;
/*!40000 ALTER TABLE `api_keys` DISABLE KEYS */;
INSERT INTO `api_keys` VALUES (5,'ces ','55af1f6cc69e4729bc7bf45fa9123fd5',1,'2026-01-26 18:20:31',NULL,0,'ces ','be7ff332-de0b-45ca-84a7-6ad206a29b45','API Key','2026-01-26 19:09:21','{\"url\":\"http://localhost:5173/api/custom/55af1f6cc69e4729bc7bf45fa9123fd5/use\",\"method\":\"GET\",\"isCustomUrl\":true,\"params\":[{\"key\":\"1\",\"type\":\"variable\",\"value\":\"card_key\"},{\"key\":\"2\",\"type\":\"variable\",\"value\":\"time\"},{\"key\":\"3\",\"type\":\"variable\",\"value\":\"api_key\"}],\"response\":[{\"key\":\"code\",\"type\":\"variable\",\"value\":\"status_code\"},{\"key\":\"msg\",\"type\":\"variable\",\"value\":\"message\"},{\"key\":\"\",\"type\":\"variable\",\"value\":\"remaining_time\"}],\"statusCodes\":[{\"key\":\"success\",\"label\":\"验证成功\",\"value\":\"200\"},{\"key\":\"not_found\",\"label\":\"卡密不存在\",\"value\":\"404\"},{\"key\":\"expired\",\"label\":\"卡密已过期\",\"value\":\"401\"},{\"key\":\"used\",\"label\":\"卡密已使用/停用\",\"value\":\"402\"},{\"key\":\"no_count\",\"label\":\"次数已用尽\",\"value\":\"403\"},{\"key\":\"error\",\"label\":\"其他错误\",\"value\":\"500\"}]}'),(6,'次数','43ccb3112a4e412eb2b8a5406dbdf049',1,'2026-01-26 19:11:48',NULL,0,'','0ff92f1d-3a6b-465b-aaed-bcce102bfea2','API Key','2026-01-26 19:12:25','{\"url\":\"http://localhost:5173/api/custom/43ccb3112a4e412eb2b8a5406dbdf049/use\",\"method\":\"GET\",\"isCustomUrl\":true,\"params\":[{\"key\":\"1\",\"type\":\"variable\",\"value\":\"card_key\"},{\"key\":\"2\",\"type\":\"variable\",\"value\":\"api_key\"}],\"response\":[{\"key\":\"code\",\"type\":\"variable\",\"value\":\"status_code\"},{\"key\":\"msg\",\"type\":\"variable\",\"value\":\"message\"},{\"key\":\"data\",\"type\":\"variable\",\"value\":\"remaining_count\"}],\"statusCodes\":[{\"key\":\"success\",\"label\":\"验证成功\",\"value\":\"200\"},{\"key\":\"not_found\",\"label\":\"卡密不存在\",\"value\":\"404\"},{\"key\":\"expired\",\"label\":\"卡密已过期\",\"value\":\"401\"},{\"key\":\"used\",\"label\":\"卡密已使用/停用\",\"value\":\"402\"},{\"key\":\"no_count\",\"label\":\"次数已用尽\",\"value\":\"403\"},{\"key\":\"error\",\"label\":\"其他错误\",\"value\":\"500\"}]}');
/*!40000 ALTER TABLE `api_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `card_cipher`
--

DROP TABLE IF EXISTS `card_cipher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `card_cipher` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `card_hash` varchar(255) NOT NULL COMMENT 'Argon2id hash of cardId + salt',
  `cipher_data` text NOT NULL COMMENT 'Base64 of Encrypted Payload',
  `sign_data` text NOT NULL COMMENT 'Base64 of ECC Signature',
  `salt` varchar(64) NOT NULL COMMENT 'Salt for Argon2id',
  `iv` varchar(64) NOT NULL COMMENT 'Base64 of AES-GCM IV',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `card_hash` (`card_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `card_cipher`
--

LOCK TABLES `card_cipher` WRITE;
/*!40000 ALTER TABLE `card_cipher` DISABLE KEYS */;
INSERT INTO `card_cipher` VALUES (6,'dWZWu3nVJO8+TrqPvSlUqFJt3gIUDDlp/k1+k7po51A=','gjEGtbyP/oUXUhifunQ6ptubXTqw8tRwBiB3flU1g1dqHEuvqkUrwd+wACXOBqZNK05YtY/dz8tpBeLzfTRrEv5VqlXLdJlsJEHAPnzcsW96Ee1dtTUDk3ciJuV//ORNrK63cNDDL8C1tmYyBv6L1u0g5nT+vxZzobv8QKf0kkDR8eoQFZOAheGFoqth760Bz2GYf3QWSQnfzU8qRWmpqOLCJmiWVcA=','MGUCMGHiwvakWR7sxhu3Nh+iRm6UaJA6TpLQa6asDu61eAui8J+w8o1aEkXK1akY2gkyMwIxAOM1i3iyON1hEisIoK5k9O/otRvPa/bX3Q5VvONoKeLSaP0MIqYQMzfAZO1jqMMTJg==','global','5p13CzgiwGz4dKAV','2026-01-26 18:51:46'),(7,'WqERZeEcMkU1ejLaxUM1F9CMB3RUfA3zE4lvdGc4Tnc=','Cknim8Xtjav/s368oxSDf0NACrwDWVDPC2hySjKfpcphP616N1foHzzX1TdrZ3uT1t9YCivFhQAweZbJbNHB6l5QVmHnl3BFxytec+5czfoOTgMvmbfNisC0HFZRw8gYM+5e/72oExgykPL+2rjIQR+BvfE0/wuxz94vrfA+/iHYxQVL2Yrt4ykohfQ/WHMGIZKboy0QaYNh3SmKsrRaL7NgihMH','MGUCMFmN0+TvhoKf8mCWc7gHguHaGvyRUOI1cQ1eUNzMOXUYiAhQX+/rnTonMecEUJoXSQIxAPhfzyRDXlilsNxYA+BvG3Z+UBYUgpp/zUzscxw6kc19TNhCR+ETJ2ZDjA6rAJgFAQ==','global','LvloItyC8sC1DljE','2026-01-26 18:53:17'),(8,'0i+OhlHEHDFJGGSRYwO/MdjzCMjaL3KkF9Cvhr1P74U=','ECgRfVNgsRHBP/tjtaYch5/7yLq7au/nQsIT5w7fbSQh7rnSkm9jjt8TQT+hl7z1k3T4/MMxlYngFXjtHYLRIO5b60RvjbiXwl14oq4pUBFA7OE7aRITHvZoXL9DnU3CBM7l7yumwr2CpPPXmGYD+6WfzIB8ONIzKc374YZkmLZqRm6iXgdnns7amXe13bgumdV9pHlmH30fli7/uwpD2u0JmUm/','MGUCMGB2JmrqI/5LklIYcQE5/Jr9S16nFNPdHdcRiMcMIfx9Bp1t/3t+6FsGhvF1fUumawIxAJjSjnVGcH3afjzc+oDlUmHQSPrPCxxBD03OsFVBxaCEIjlIcPa6OUiP8UsYpF87Qg==','global','1ZURZMddf/fNTnO4','2026-01-26 19:11:12'),(9,'nKjTplUGjlldJ8ea9039Q1UW1w0qSohz3OLbDLBuDDU=','spHBL9EtqcRLI4cEzNyd0M8KMTIr+RM0eME2t4HLQHe965Xru/TGYBmS21ZEqXZUN8ht2+h0W+5fvcHPpCxrJFj6JRY5d2oK0QIYVD/gSxtsYB8lmG4LcoHlnwUQWP0of5xwQ1uuBH4SwCKSN3TKULVZvtTL4NVrut+GuQsRYQkjF0tlEysD4c+DtlhfHjEBPJHdfJdXPs+dh21HXcgYvyegDkWB','MGYCMQC66WVAh/MzeFJmQ3XfWz3lWzkjFWnexE/R5wCM2Zu3J4zPvHpZxOdFj2DTBGnG448CMQDaW6vDfM1tCP9BGhXwYShYXzXB70/LyNrNK3pdORsR5d7qJoYno1R83GhINe6tkXE=','global','E6bdSkoi7VX3sanc','2026-01-26 19:11:12'),(10,'edwBgIhfQzyDIqbdy6zszwSMzSTHs8ERZS2TGMsg4q0=','vxDS1fiwrAQmx9vvSoTiH9trpkikmJ6gqwKjaANfMz8vXPlyprgaaxBlqTcSgav88YkkT4xMU6PvtEtK86EkzNGTz+kGQg0L9s243Olj6xyNlAce8zmdVmdTsY6U2vPnYHX66nFDPR/w/mg07p8ndvSOexQcu0UoPhOpD4DGkNqUOrE7knGqIdZh902isfiEIUe/BpSAnMvjZVc5BuwIlBpOZUPqBQ==','MGYCMQD0mz1nkSBPlKuEkWxgzb4ahrHA9jyfdM+d3LpmmKgGH8qJO5qhk/rCxXxi44aG8ZQCMQDHmjXpNl2Sdt1gpz/90yWgBYiucsHdA4mjLmSBIsC/RY/qYvbtuPNSRcN9HWvTMYs=','global','qu6J1aqF06rua6pu','2026-01-26 19:11:53'),(11,'i5CChtmh4NXPf1lUH/NKOMgjLHRwdoKK5Y6wfqNjzRI=','lpnQ4XcFQSQP1yn3110yaQWlLjI8+tvV81aNP1HzTUv1v7Don5yqra9E+Xmh2PKL6SDOCSXyB+LW45f+F3YLicmCU3vWsUA17lnqwjN4TEqqLbc9J6OJl3GPTa6QUwmZWVp/Fda/p3AWId9jv2QBFP8OwISbjxqbnDULKKkO3QFDXoyNt8iZoyZ0LY/obpZimDK0MV0FumK8V6xqmObDy6rR4GEo2A==','MGUCMQDzlnS26NSBpkIjeLZ1fmBLON8zieU7FxwQ8tuhqMomL9Wk0V+w4fZkFrBgzJAaQ70CME0trvZCHkXBfrRIOQTuiVN/bCY4XBks7QwofyQef5SN0jBYGWib07E8phq8GGvdTw==','global','nhGYUAj525ilI0jC','2026-01-26 19:11:53');
/*!40000 ALTER TABLE `card_cipher` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `card_pricing`
--

DROP TABLE IF EXISTS `card_pricing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `card_pricing` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'time or count',
  `value` int NOT NULL COMMENT 'duration or count',
  `price` decimal(10,2) NOT NULL,
  `description` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `card_pricing`
--

LOCK TABLES `card_pricing` WRITE;
/*!40000 ALTER TABLE `card_pricing` DISABLE KEYS */;
INSERT INTO `card_pricing` VALUES (1,'time',7,0.01,'7天时间卡','2026-01-14 20:01:56','2026-01-16 11:47:56'),(2,'time',15,0.02,'15天时间卡','2026-01-14 20:01:56','2026-01-16 11:52:46'),(3,'time',30,35.00,'30天时间卡','2026-01-14 20:01:56','2026-01-14 20:01:56'),(4,'time',60,65.00,'60天时间卡','2026-01-14 20:01:56','2026-01-14 20:01:56'),(5,'time',90,90.00,'90天时间卡','2026-01-14 20:01:56','2026-01-14 20:01:56'),(6,'time',180,168.00,'180天时间卡','2026-01-14 20:01:56','2026-01-14 20:01:56'),(7,'count',50,12.00,'50次使用卡','2026-01-14 20:01:56','2026-01-14 20:01:56'),(8,'count',100,22.00,'100次使用卡','2026-01-14 20:01:56','2026-01-14 20:01:56'),(9,'count',200,40.00,'200次使用卡','2026-01-14 20:01:56','2026-01-14 20:01:56'),(10,'count',500,95.00,'500次使用卡','2026-01-14 20:01:56','2026-01-14 20:01:56'),(11,'count',1000,180.00,'1000次使用卡','2026-01-14 20:01:56','2026-01-14 20:01:56');
/*!40000 ALTER TABLE `card_pricing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `card_status`
--

DROP TABLE IF EXISTS `card_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `card_status` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `card_hash` varchar(255) NOT NULL,
  `remain_count` int NOT NULL DEFAULT '0',
  `total_count` int NOT NULL DEFAULT '0',
  `expire_time` datetime DEFAULT NULL,
  `last_use_time` datetime DEFAULT NULL,
  `is_valid` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `card_hash` (`card_hash`),
  KEY `idx_card_hash` (`card_hash`),
  CONSTRAINT `fk_card_status_hash` FOREIGN KEY (`card_hash`) REFERENCES `card_cipher` (`card_hash`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `card_status`
--

LOCK TABLES `card_status` WRITE;
/*!40000 ALTER TABLE `card_status` DISABLE KEYS */;
INSERT INTO `card_status` VALUES (6,'dWZWu3nVJO8+TrqPvSlUqFJt3gIUDDlp/k1+k7po51A=',100,100,'2026-02-25 18:51:46',NULL,1),(7,'WqERZeEcMkU1ejLaxUM1F9CMB3RUfA3zE4lvdGc4Tnc=',0,0,'2026-02-25 18:53:17','2026-01-26 19:17:04',1),(8,'0i+OhlHEHDFJGGSRYwO/MdjzCMjaL3KkF9Cvhr1P74U=',0,0,'2026-02-25 19:11:12',NULL,1),(9,'nKjTplUGjlldJ8ea9039Q1UW1w0qSohz3OLbDLBuDDU=',0,0,'2026-02-25 19:11:12',NULL,1),(10,'edwBgIhfQzyDIqbdy6zszwSMzSTHs8ERZS2TGMsg4q0=',27,30,NULL,'2026-01-26 19:18:43',1),(11,'i5CChtmh4NXPf1lUH/NKOMgjLHRwdoKK5Y6wfqNjzRI=',30,30,NULL,NULL,1);
/*!40000 ALTER TABLE `card_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cards`
--

DROP TABLE IF EXISTS `cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cards` (
  `id` int NOT NULL AUTO_INCREMENT,
  `card_key` varchar(512) DEFAULT NULL,
  `encrypted_key` varchar(255) DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0:未使用 1:已使用 2:已停用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `use_time` datetime DEFAULT NULL,
  `expire_time` datetime DEFAULT NULL,
  `duration` int NOT NULL DEFAULT '0',
  `verify_method` enum('web','post','get') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `allow_reverify` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否允许同设备重复验证(1:允许, 0:不允许)',
  `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `encryption_type` varchar(50) DEFAULT NULL,
  `card_type` enum('time','count') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'time' COMMENT '卡密类型：time-时间卡密，count-次数卡密',
  `total_count` int NOT NULL DEFAULT '0' COMMENT '总次数（次数卡密专用）',
  `remaining_count` int NOT NULL DEFAULT '0' COMMENT '剩余次数（次数卡密专用）',
  `creator_type` enum('admin','user') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'admin' COMMENT '创建者类型：admin-管理员，user-普通用户',
  `creator_id` int NOT NULL COMMENT '创建者ID（对应admins表或users表的id）',
  `creator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '创建者用户名',
  `ip_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `api_key_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `card_key` (`card_key`) USING BTREE,
  UNIQUE KEY `encrypted_key` (`encrypted_key`) USING BTREE,
  KEY `device_id` (`device_id`) USING BTREE,
  KEY `creator_type` (`creator_type`) USING BTREE,
  KEY `creator_id` (`creator_id`) USING BTREE,
  KEY `creator_name` (`creator_name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cards`
--

LOCK TABLES `cards` WRITE;
/*!40000 ALTER TABLE `cards` DISABLE KEYS */;
INSERT INTO `cards` VALUES (67,'5p13CzgiwGz4dKAV$gjEGtbyP/oUXUhifunQ6ptubXTqw8tRwBiB3flU1g1dqHEuvqkUrwd+wACXOBqZNK05YtY/dz8tpBeLzfTRrEv5VqlXLdJlsJEHAPnzcsW96Ee1dtTUDk3ciJuV//ORNrK63cNDDL8C1tmYyBv6L1u0g5nT+vxZzobv8QKf0kkDR8eoQFZOAheGFoqth760Bz2GYf3QWSQnfzU8qRWmpqOLCJmiWVcA=$MGUCMGHiwvakWR7sxhu3Nh+iRm6UaJA6TpLQa6asDu61eAui8J+w8o1aEkXK1akY2gkyMwIxAOM1i3iyON1hEisIoK5k9O/otRvPa/bX3Q5VvONoKeLSaP0MIqYQMzfAZO1jqMMTJg==','dWZWu3nVJO8+TrqPvSlUqFJt3gIUDDlp/k1+k7po51A=',0,'2026-01-26 18:51:46',NULL,NULL,30,'web',1,NULL,'advanced','count',100,100,'admin',2,'admin',NULL,NULL),(68,'LvloItyC8sC1DljE$Cknim8Xtjav/s368oxSDf0NACrwDWVDPC2hySjKfpcphP616N1foHzzX1TdrZ3uT1t9YCivFhQAweZbJbNHB6l5QVmHnl3BFxytec+5czfoOTgMvmbfNisC0HFZRw8gYM+5e/72oExgykPL+2rjIQR+BvfE0/wuxz94vrfA+/iHYxQVL2Yrt4ykohfQ/WHMGIZKboy0QaYNh3SmKsrRaL7NgihMH$MGUCMFmN0+TvhoKf8mCWc7gHguHaGvyRUOI1cQ1eUNzMOXUYiAhQX+/rnTonMecEUJoXSQIxAPhfzyRDXlilsNxYA+BvG3Z+UBYUgpp/zUzscxw6kc19TNhCR+ETJ2ZDjA6rAJgFAQ==','WqERZeEcMkU1ejLaxUM1F9CMB3RUfA3zE4lvdGc4Tnc=',1,'2026-01-26 18:53:17','2026-01-26 19:17:04',NULL,30,'web',1,NULL,'advanced','time',0,0,'admin',2,'admin',NULL,5),(69,'1ZURZMddf/fNTnO4$ECgRfVNgsRHBP/tjtaYch5/7yLq7au/nQsIT5w7fbSQh7rnSkm9jjt8TQT+hl7z1k3T4/MMxlYngFXjtHYLRIO5b60RvjbiXwl14oq4pUBFA7OE7aRITHvZoXL9DnU3CBM7l7yumwr2CpPPXmGYD+6WfzIB8ONIzKc374YZkmLZqRm6iXgdnns7amXe13bgumdV9pHlmH30fli7/uwpD2u0JmUm/$MGUCMGB2JmrqI/5LklIYcQE5/Jr9S16nFNPdHdcRiMcMIfx9Bp1t/3t+6FsGhvF1fUumawIxAJjSjnVGcH3afjzc+oDlUmHQSPrPCxxBD03OsFVBxaCEIjlIcPa6OUiP8UsYpF87Qg==','0i+OhlHEHDFJGGSRYwO/MdjzCMjaL3KkF9Cvhr1P74U=',0,'2026-01-26 19:11:12',NULL,NULL,30,'web',1,NULL,'advanced','time',0,0,'admin',2,'admin',NULL,5),(70,'E6bdSkoi7VX3sanc$spHBL9EtqcRLI4cEzNyd0M8KMTIr+RM0eME2t4HLQHe965Xru/TGYBmS21ZEqXZUN8ht2+h0W+5fvcHPpCxrJFj6JRY5d2oK0QIYVD/gSxtsYB8lmG4LcoHlnwUQWP0of5xwQ1uuBH4SwCKSN3TKULVZvtTL4NVrut+GuQsRYQkjF0tlEysD4c+DtlhfHjEBPJHdfJdXPs+dh21HXcgYvyegDkWB$MGYCMQC66WVAh/MzeFJmQ3XfWz3lWzkjFWnexE/R5wCM2Zu3J4zPvHpZxOdFj2DTBGnG448CMQDaW6vDfM1tCP9BGhXwYShYXzXB70/LyNrNK3pdORsR5d7qJoYno1R83GhINe6tkXE=','nKjTplUGjlldJ8ea9039Q1UW1w0qSohz3OLbDLBuDDU=',0,'2026-01-26 19:11:12',NULL,NULL,30,'web',1,NULL,'advanced','time',0,0,'admin',2,'admin',NULL,5),(71,'qu6J1aqF06rua6pu$vxDS1fiwrAQmx9vvSoTiH9trpkikmJ6gqwKjaANfMz8vXPlyprgaaxBlqTcSgav88YkkT4xMU6PvtEtK86EkzNGTz+kGQg0L9s243Olj6xyNlAce8zmdVmdTsY6U2vPnYHX66nFDPR/w/mg07p8ndvSOexQcu0UoPhOpD4DGkNqUOrE7knGqIdZh902isfiEIUe/BpSAnMvjZVc5BuwIlBpOZUPqBQ==$MGYCMQD0mz1nkSBPlKuEkWxgzb4ahrHA9jyfdM+d3LpmmKgGH8qJO5qhk/rCxXxi44aG8ZQCMQDHmjXpNl2Sdt1gpz/90yWgBYiucsHdA4mjLmSBIsC/RY/qYvbtuPNSRcN9HWvTMYs=','edwBgIhfQzyDIqbdy6zszwSMzSTHs8ERZS2TGMsg4q0=',1,'2026-01-26 19:11:53','2026-01-26 19:18:43',NULL,0,'web',1,NULL,'advanced','count',30,27,'admin',2,'admin',NULL,6),(72,'nhGYUAj525ilI0jC$lpnQ4XcFQSQP1yn3110yaQWlLjI8+tvV81aNP1HzTUv1v7Don5yqra9E+Xmh2PKL6SDOCSXyB+LW45f+F3YLicmCU3vWsUA17lnqwjN4TEqqLbc9J6OJl3GPTa6QUwmZWVp/Fda/p3AWId9jv2QBFP8OwISbjxqbnDULKKkO3QFDXoyNt8iZoyZ0LY/obpZimDK0MV0FumK8V6xqmObDy6rR4GEo2A==$MGUCMQDzlnS26NSBpkIjeLZ1fmBLON8zieU7FxwQ8tuhqMomL9Wk0V+w4fZkFrBgzJAaQ70CME0trvZCHkXBfrRIOQTuiVN/bCY4XBks7QwofyQef5SN0jBYGWib07E8phq8GGvdTw==','i5CChtmh4NXPf1lUH/NKOMgjLHRwdoKK5Y6wfqNjzRI=',0,'2026-01-26 19:11:53',NULL,NULL,0,'web',1,NULL,'advanced','count',30,30,'admin',2,'admin',NULL,6);
/*!40000 ALTER TABLE `cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `features`
--

DROP TABLE IF EXISTS `features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `features` (
  `id` int NOT NULL AUTO_INCREMENT,
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `features`
--

LOCK TABLES `features` WRITE;
/*!40000 ALTER TABLE `features` DISABLE KEYS */;
INSERT INTO `features` VALUES (1,'fas fa-shield-alt','安全可靠','采用先进的加密技术，确保卡密数据安全\n数据加密存储\n防暴力破解\n安全性验证',1,1),(2,'fas fa-code','API接口','提供完整的API接口，支持多种验证方式\nRESTful API\n多种验证方式\n详细接口文档',2,1),(3,'fas fa-tachometer-alt','高效稳定','系统运行稳定，响应迅速\n快速响应\n稳定运行\n性能优化',3,1),(4,'fas fa-chart-line','数据统计','详细的数据统计和分析功能\n实时统计\n数据分析\n图表展示',4,1);
/*!40000 ALTER TABLE `features` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operation_logs`
--

DROP TABLE IF EXISTS `operation_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `operation_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int NOT NULL,
  `admin_username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `operation_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型',
  `operation_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作内容',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'IP地址',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `admin_id` (`admin_id`) USING BTREE,
  KEY `operation_type` (`operation_type`) USING BTREE,
  KEY `create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operation_logs`
--

LOCK TABLES `operation_logs` WRITE;
/*!40000 ALTER TABLE `operation_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `operation_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Order No',
  `user_id` int NOT NULL COMMENT 'User ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'Username',
  `card_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Card Type',
  `card_spec` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Specification',
  `quantity` int NOT NULL DEFAULT '1' COMMENT 'Quantity',
  `unit_price` decimal(10,2) DEFAULT '0.00' COMMENT 'Unit Price',
  `total_price` decimal(10,2) NOT NULL COMMENT 'Total Price',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'pending' COMMENT 'Status: pending, completed, failed',
  `payment_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'wechat' COMMENT 'Payment Method',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `pay_time` datetime DEFAULT NULL COMMENT 'Payment Time',
  `card_keys` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Allocated Card Keys',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `order_no` (`order_no`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (31,'ORD20260126193233602',1,'testuser','time','7天时间卡',1,0.01,0.01,'failed','alipay','2026-01-26 19:32:34','2026-01-26 19:33:20',NULL,'');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=429 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'site_title','小小怪卡密验证系统'),(2,'site_subtitle','专业的卡密验证解决方案'),(3,'copyright_text','小小怪卡密系统 - All Rights Reserved'),(4,'contact_qq_group','123456789'),(5,'contact_wechat_qr','assets/images/wechat-qr.jpg'),(6,'contact_email','support@example.com'),(7,'api_enabled','1'),(8,'api_key',''),(9,'smtp_server',''),(10,'smtp_port',''),(11,'smtp_email',''),(12,'smtp_password',''),(13,'smtp_ssl','true'),(14,'sender_name','XXG卡密系统'),(15,'notify_user_reg','true'),(16,'notify_order_create','true'),(17,'notify_key_used','true'),(18,'notify_sys_maint','true'),(19,'notify_sec_alert','true'),(20,'tpl_user_reg','欢迎注册XXG卡密系统！您的账户已成功创建。'),(21,'tpl_order_notify','您的订单已创建成功，订单号：{orderNumber}，请及时查看。'),(22,'tpl_sys_maint','系统将于{time}进行维护，预计维护时间{duration}，请提前做好准备。'),(65,'systemName','XXG卡密系统'),(66,'systemDescription','专业的卡密管理系统'),(67,'defaultLanguage','zh-CN'),(68,'timezone','Asia/Shanghai'),(69,'autoBackup','true'),(70,'backupFrequency','daily'),(71,'backupRetention','7'),(72,'dataCompression','true'),(73,'payment_enabled','true'),(74,'epay_api_url','https://www.ezfpy.cn/'),(75,'epay_pid','146'),(76,'epay_key','mbYgrDma0JUlpfVsJogxKz6fka0qNSEE'),(77,'epay_notify_url',''),(78,'epay_return_url',''),(79,'site_url','http://localhost:5173'),(80,'oauth_url','https://baoxian18.com'),(81,'oauth_appid',''),(82,'oauth_appkey',''),(83,'oauth_login_types','qq,wx,alipay'),(84,'oauth_callback_domain',''),(260,'qqLogin','false'),(261,'authenticatorLogin','false'),(262,'aggregatedLogin','true');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `slides`
--

DROP TABLE IF EXISTS `slides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `slides` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `slides`
--

LOCK TABLES `slides` WRITE;
/*!40000 ALTER TABLE `slides` DISABLE KEYS */;
INSERT INTO `slides` VALUES (1,'安全可靠的验证系统','采用先进的加密技术，确保您的数据安全','assets/images/slide1.jpg',1,1,'2025-05-06 09:13:25'),(2,'便捷高效的验证流程','支持多种验证方式，快速响应','assets/images/slide2.jpg',2,1,'2025-05-06 09:13:25'),(3,'完整的API接口','提供丰富的接口，便于集成','assets/images/slide3.jpg',3,1,'2025-05-06 09:13:25');
/*!40000 ALTER TABLE `slides` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `social_users`
--

DROP TABLE IF EXISTS `social_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `social_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `social_uid` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `social_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `social_uid` (`social_uid`,`social_type`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_users`
--

LOCK TABLES `social_users` WRITE;
/*!40000 ALTER TABLE `social_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `social_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `spring_session`
--

DROP TABLE IF EXISTS `spring_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `spring_session` (
  `PRIMARY_ID` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `SESSION_ID` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `CREATION_TIME` bigint NOT NULL,
  `LAST_ACCESS_TIME` bigint NOT NULL,
  `MAX_INACTIVE_INTERVAL` int NOT NULL,
  `EXPIRY_TIME` bigint NOT NULL,
  `PRINCIPAL_NAME` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`PRIMARY_ID`) USING BTREE,
  UNIQUE KEY `SPRING_SESSION_IX1` (`SESSION_ID`) USING BTREE,
  KEY `SPRING_SESSION_IX2` (`EXPIRY_TIME`) USING BTREE,
  KEY `SPRING_SESSION_IX3` (`PRINCIPAL_NAME`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `spring_session`
--

LOCK TABLES `spring_session` WRITE;
/*!40000 ALTER TABLE `spring_session` DISABLE KEYS */;
INSERT INTO `spring_session` VALUES ('9e67e883-da1b-427f-932d-cf01f89e17db','9a6a6a81-2ee7-4cc5-9ff9-fa74933d7d22',1769685591995,1769685591997,1800,1769687391997,NULL);
/*!40000 ALTER TABLE `spring_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `spring_session_attributes`
--

DROP TABLE IF EXISTS `spring_session_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `spring_session_attributes` (
  `SESSION_PRIMARY_ID` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ATTRIBUTE_NAME` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ATTRIBUTE_BYTES` blob NOT NULL,
  PRIMARY KEY (`SESSION_PRIMARY_ID`,`ATTRIBUTE_NAME`) USING BTREE,
  CONSTRAINT `SPRING_SESSION_ATTRIBUTES_FK` FOREIGN KEY (`SESSION_PRIMARY_ID`) REFERENCES `spring_session` (`PRIMARY_ID`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `spring_session_attributes`
--

LOCK TABLES `spring_session_attributes` WRITE;
/*!40000 ALTER TABLE `spring_session_attributes` DISABLE KEYS */;
INSERT INTO `spring_session_attributes` VALUES ('9e67e883-da1b-427f-932d-cf01f89e17db','SPRING_SECURITY_SAVED_REQUEST',_binary '�\�\0sr\0Aorg.springframework.security.web.savedrequest.DefaultSavedRequest\0\0\0\0\0\0l\0I\0\nserverPortL\0contextPatht\0Ljava/lang/String;L\0cookiest\0Ljava/util/ArrayList;L\0headerst\0Ljava/util/Map;L\0localesq\0~\0L\0matchingRequestParameterNameq\0~\0L\0methodq\0~\0L\0\nparametersq\0~\0L\0pathInfoq\0~\0L\0queryStringq\0~\0L\0\nrequestURIq\0~\0L\0\nrequestURLq\0~\0L\0schemeq\0~\0L\0\nserverNameq\0~\0L\0servletPathq\0~\0xp\0\0�t\0/apisr\0java.util.ArrayListx�\��\�a�\0I\0sizexp\0\0\0\0w\0\0\0\0xsr\0java.util.TreeMap�\�>-%j\�\0L\0\ncomparatort\0Ljava/util/Comparator;xpsr\0*java.lang.String$CaseInsensitiveComparatorw\\}\\P\�\�\0\0xpw\0\0\0t\0acceptsq\0~\0\0\0\0w\0\0\0t\0*/*xt\0accept-encodingsq\0~\0\0\0\0w\0\0\0t\0gzip, deflate, br, zstdxt\0accept-languagesq\0~\0\0\0\0w\0\0\0t\0/zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6xt\0\rauthorizationsq\0~\0\0\0\0w\0\0\0t\0�Bearer eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYWRtaW4iLCJ0eXBlIjoiYWNjZXNzIiwic3ViIjoiYWRtaW4iLCJpYXQiOjE3Njk0MjU2MzUsImV4cCI6MTc2OTQyOTIzNX0.OjovGDHwLnL2JxfYyIuHqmKlHlYkrByeZlehBnb1Kzwxt\0\nconnectionsq\0~\0\0\0\0w\0\0\0t\0\nkeep-alivext\0content-typesq\0~\0\0\0\0w\0\0\0t\0application/jsonxt\0hostsq\0~\0\0\0\0w\0\0\0t\0localhost:8080xt\0originsq\0~\0\0\0\0w\0\0\0t\0http://localhost:5173xt\0referersq\0~\0\0\0\0w\0\0\0t\0http://localhost:5173/xt\0	sec-ch-uasq\0~\0\0\0\0w\0\0\0t\0A\"Not(A:Brand\";v=\"8\", \"Chromium\";v=\"144\", \"Microsoft Edge\";v=\"144\"xt\0sec-ch-ua-mobilesq\0~\0\0\0\0w\0\0\0t\0?0xt\0sec-ch-ua-platformsq\0~\0\0\0\0w\0\0\0t\0	\"Windows\"xt\0sec-fetch-destsq\0~\0\0\0\0w\0\0\0t\0emptyxt\0sec-fetch-modesq\0~\0\0\0\0w\0\0\0t\0corsxt\0sec-fetch-sitesq\0~\0\0\0\0w\0\0\0t\0	same-sitext\0\nuser-agentsq\0~\0\0\0\0w\0\0\0t\0}Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0xxsq\0~\0\0\0\0w\0\0\0sr\0java.util.Locale~�`�0�\�\0I\0hashcodeL\0countryq\0~\0L\0\nextensionsq\0~\0L\0languageq\0~\0L\0scriptq\0~\0L\0variantq\0~\0xp����t\0CNt\0\0t\0zhq\0~\0Aq\0~\0Axsq\0~\0>����q\0~\0Aq\0~\0Aq\0~\0Bq\0~\0Aq\0~\0Axsq\0~\0>����q\0~\0Aq\0~\0At\0enq\0~\0Aq\0~\0Axsq\0~\0>����t\0GBq\0~\0Aq\0~\0Eq\0~\0Aq\0~\0Axsq\0~\0>����t\0USq\0~\0Aq\0~\0Eq\0~\0Aq\0~\0Axxt\0continuet\0GETsq\0~\0pw\0\0\0t\0pageur\0[Ljava.lang.String;�\�V\�\�{G\0\0xp\0\0\0t\01t\0sizeuq\0~\0N\0\0\0t\010xpt\0page=1&size=10t\0/api/admin/userst\0%http://localhost:8080/api/admin/userst\0httpt\0	localhostt\0/admin/users');
/*!40000 ALTER TABLE `spring_session_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_maintenance`
--

DROP TABLE IF EXISTS `system_maintenance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_maintenance` (
  `id` int NOT NULL,
  `enabled` tinyint(1) DEFAULT '0',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `maintenance_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `start_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `email_subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `email_template` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_maintenance`
--

LOCK TABLES `system_maintenance` WRITE;
/*!40000 ALTER TABLE `system_maintenance` DISABLE KEYS */;
INSERT INTO `system_maintenance` VALUES (1,0,'系统正在维护中，请稍后访问。','8小时','','小小怪卡密系统维护通知','');
/*!40000 ALTER TABLE `system_maintenance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_api_keys`
--

DROP TABLE IF EXISTS `user_api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_api_keys` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `api_key_id` bigint NOT NULL,
  `assign_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `user_id` (`user_id`,`api_key_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_api_keys`
--

LOCK TABLES `user_api_keys` WRITE;
/*!40000 ALTER TABLE `user_api_keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_api_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sessions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户ID',
  `session_token` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会话令牌',
  `device_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '设备信息',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'IP地址',
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '用户代理',
  `expires_at` datetime NOT NULL COMMENT '过期时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `last_activity` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后活动时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `session_token` (`session_token`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `expires_at` (`expires_at`) USING BTREE,
  CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户会话表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sessions`
--

LOCK TABLES `user_sessions` WRITE;
/*!40000 ALTER TABLE `user_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '邮箱',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码（加密存储）',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '头像URL',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '手机号',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态：0-禁用，1-启用',
  `email_verified` tinyint(1) NOT NULL DEFAULT '0' COMMENT '邮箱是否验证：0-未验证，1-已验证',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '最后登录IP',
  `login_count` int NOT NULL DEFAULT '0' COMMENT '登录次数',
  `register_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '注册IP',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `access_token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `refresh_token` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `username` (`username`) USING BTREE,
  UNIQUE KEY `email` (`email`) USING BTREE,
  KEY `status` (`status`) USING BTREE,
  KEY `create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='普通用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'testuser','test@example.com','$2y$10$gxgRAiv63rkmLDQcg1WcdumpGSKoia1pt5hVYsK2cJSpcwzVRFnjq','测试用户',NULL,NULL,1,0,'2026-01-26 19:32:26','127.0.0.1',2,'127.0.0.1','2025-09-22 03:35:00','2026-01-26 19:32:26','eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidXNlciIsInR5cGUiOiJhY2Nlc3MiLCJzdWIiOiJ0ZXN0dXNlciIsImlhdCI6MTc2OTQyNzE0NiwiZXhwIjoxNzY5NDMwNzQ2fQ.sqypypWaznmwK-P3kTEfW_jzTISKDFqVXo151VnenN0','eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidXNlciIsInR5cGUiOiJyZWZyZXNoIiwic3ViIjoidGVzdHVzZXIiLCJpYXQiOjE3Njk0MjcxNDYsImV4cCI6MTc3MDAzMTk0Nn0.7JxmmWfvYVab3H3x-ImUng1soidLmqz2ILZUDTHdNto');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `verification_codes`
--

DROP TABLE IF EXISTS `verification_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `verification_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'register' COMMENT 'register, reset_password',
  `expire_time` datetime NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `email` (`email`) USING BTREE,
  KEY `code` (`code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `verification_codes`
--

LOCK TABLES `verification_codes` WRITE;
/*!40000 ALTER TABLE `verification_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `verification_codes` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-29 19:21:06
