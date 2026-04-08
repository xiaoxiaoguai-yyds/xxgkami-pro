-- 卡密表新增 machine_code（机器码）字段，用于一机一码绑定
ALTER TABLE cards ADD COLUMN machine_code VARCHAR(255) DEFAULT NULL COMMENT '绑定的机器码（一机一码）' AFTER ip_address;

-- 为机器码添加索引，方便查询
ALTER TABLE cards ADD INDEX idx_machine_code (machine_code);
