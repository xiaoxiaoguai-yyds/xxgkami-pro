CREATE TABLE IF NOT EXISTS `orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(64) NOT NULL,
  `user_id` int DEFAULT NULL,
  `username` varchar(64) DEFAULT NULL,
  `card_type` varchar(32) DEFAULT NULL,
  `card_spec` varchar(64) DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `unit_price` decimal(10,2) DEFAULT NULL,
  `total_price` decimal(10,2) DEFAULT NULL,
  `payment_method` varchar(32) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `pay_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
