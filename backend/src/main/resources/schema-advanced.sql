CREATE TABLE IF NOT EXISTS card_cipher (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    card_hash VARCHAR(255) NOT NULL UNIQUE COMMENT 'Argon2id hash of cardId + salt',
    cipher_data TEXT NOT NULL COMMENT 'Base64 of Encrypted Payload',
    sign_data TEXT NOT NULL COMMENT 'Base64 of ECC Signature',
    salt VARCHAR(64) NOT NULL COMMENT 'Salt for Argon2id',
    iv VARCHAR(64) NOT NULL COMMENT 'Base64 of AES-GCM IV',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS card_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    card_hash VARCHAR(255) NOT NULL UNIQUE,
    remain_count INT NOT NULL DEFAULT 0,
    total_count INT NOT NULL DEFAULT 0,
    expire_time DATETIME,
    last_use_time DATETIME,
    is_valid TINYINT(1) DEFAULT 1,
    INDEX idx_card_hash (card_hash),
    CONSTRAINT fk_card_status_hash FOREIGN KEY (card_hash) REFERENCES card_cipher(card_hash) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Update existing cards table to support advanced keys
ALTER TABLE cards MODIFY COLUMN card_key VARCHAR(512);
ALTER TABLE cards MODIFY COLUMN encrypted_key VARCHAR(255);
ALTER TABLE cards MODIFY COLUMN encryption_type VARCHAR(50);

