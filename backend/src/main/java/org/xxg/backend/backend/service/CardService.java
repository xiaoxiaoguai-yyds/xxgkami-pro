package org.xxg.backend.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.xxg.backend.backend.mapper.ApiKeyMapper;
import org.xxg.backend.backend.mapper.CardMapper;
import org.xxg.backend.backend.mapper.OrderMapper;
import org.xxg.backend.backend.mapper.UserMapper;
import org.xxg.backend.backend.entity.Card;
import org.xxg.backend.backend.entity.Order;
import org.xxg.backend.backend.entity.User;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

import org.xxg.backend.backend.util.AdvancedCryptoUtil;
import org.xxg.backend.backend.mapper.CardCipherMapper;
import org.xxg.backend.backend.mapper.CardStatusMapper;
import org.xxg.backend.backend.entity.CardCipher;
import org.xxg.backend.backend.entity.CardStatus;
import org.redisson.api.RedissonClient;
import org.redisson.api.RLock;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.concurrent.TimeUnit;

/**
 * 卡密服务层
 */
@Service
public class CardService {

    @Autowired
    private CardMapper cardMapper;
    @Autowired
    private OrderMapper orderMapper;
    @Autowired
    private UserMapper userMapper;
    @Autowired
    private EmailService emailService;
    @Autowired
    private WebhookService webhookService;
    @Autowired
    private ApiKeyMapper apiKeyMapper;
    
    @Autowired
    private AdvancedCryptoUtil advancedCryptoUtil;
    @Autowired
    private KeyManagerService keyManagerService;
    @Autowired
    private CardCipherMapper cardCipherMapper;
    @Autowired
    private CardStatusMapper cardStatusMapper;
    
    @Autowired(required = false)
    private RedissonClient redissonClient;
    
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 卡密核心载荷
     */
    private static class CardPayload {
        public String cardId;
        public Long expireTime;
        public Integer totalCount;
        public String nonce;
    }

    /**
     * 使用卡密
     * @param cardKey 卡密
     * @param deviceId 设备ID
     * @param ipAddress IP地址
     * @return 更新后的Card对象
     */
    @Transactional
    public Card useCard(String cardKey, String deviceId, String ipAddress, Long apiKeyId, String machineCode) {
        // Advanced Card Check
        if (cardKey != null && cardKey.contains("$")) {
             return useAdvancedCard(cardKey, deviceId, ipAddress, apiKeyId, machineCode);
        }

        Card card = cardMapper.findByCardKey(cardKey);
        if (card == null) {
            throw new RuntimeException("卡密不存在");
        }

        // Verify API Key binding
        if (card.getApiKeyId() != null) {
            if (apiKeyId == null || !card.getApiKeyId().equals(apiKeyId)) {
                throw new RuntimeException("该卡密为专属卡密，当前API密钥无法使用");
            }
        }

        if (card.getStatus() != null && card.getStatus() == 2) {
            boolean wasActivated = card.getUseTime() != null;
            throw new RuntimeException(wasActivated ? "卡密被停止使用" : "卡密已停用");
        }

        // 一机一码校验
        verifyMachineCode(card, machineCode);

        LocalDateTime now = LocalDateTime.now();
        boolean isUpdated = false;

        if ("time".equals(card.getCardType())) {
            if (card.getStatus() != 0) {
                if (card.getExpireTime() != null && card.getExpireTime().isBefore(now)) {
                    throw new RuntimeException("卡密已过期");
                }
                if (card.getAllowReverify() != null && card.getAllowReverify() == 0) {
                    throw new RuntimeException("该卡密不允许重复验证，验证次数已达上限(1次)");
                }
            } else {
                card.setUseTime(now);
                card.setExpireTime(now.plusDays(card.getDuration()));
                card.setStatus(1);
                card.setDeviceId(deviceId);
                card.setIpAddress(ipAddress);
                // 首次激活时绑定机器码
                if (machineCode != null && !machineCode.isEmpty()) {
                    card.setMachineCode(machineCode);
                }
                isUpdated = true;
            }
        } else {
            if (card.getStatus() == 1 || (card.getRemainingCount() != null && card.getRemainingCount() <= 0)) {
                 throw new RuntimeException("卡密次数已用尽");
            }

            int currentRemaining = card.getRemainingCount() != null ? card.getRemainingCount() : card.getTotalCount();
            if (currentRemaining <= 0) {
                 throw new RuntimeException("卡密次数已用尽");
            }

            card.setRemainingCount(currentRemaining - 1);
            card.setUseTime(now);
            card.setDeviceId(deviceId);
            card.setIpAddress(ipAddress);
            // 首次使用时绑定机器码
            if (card.getMachineCode() == null && machineCode != null && !machineCode.isEmpty()) {
                card.setMachineCode(machineCode);
            }

            if (card.getRemainingCount() <= 0) {
                card.setStatus(1);
            }
            isUpdated = true;
        }

        if (isUpdated) {
            cardMapper.update(card);
        }

        if (apiKeyId != null) {
            org.xxg.backend.backend.entity.ApiKey apiKey = apiKeyMapper.findById(apiKeyId);
            if (apiKey != null) {
                webhookService.triggerWebhook(apiKey, card, ipAddress);
            }
        }

        try {
            Order order = orderMapper.findByCardKey(cardKey);
            if (order != null && order.getUserId() != null) {
                User user = userMapper.findById(Long.valueOf(order.getUserId()));
                if (user != null && user.getEmail() != null) {
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                    emailService.sendCardUsedNotification(user.getEmail(), cardKey, now.format(formatter));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return card;
    }

    @Transactional
    public Card useCard(String cardKey, String deviceId, String ipAddress, Long apiKeyId) {
        return useCard(cardKey, deviceId, ipAddress, apiKeyId, null);
    }

    @Transactional
    public Card useCard(String cardKey, String deviceId, String ipAddress) {
        return useCard(cardKey, deviceId, ipAddress, null, null);
    }

    /**
     * 一机一码校验：卡密已绑定机器码时，传入的机器码必须匹配
     */
    private void verifyMachineCode(Card card, String machineCode) {
        if (card.getMachineCode() == null || card.getMachineCode().isEmpty()) {
            return;
        }
        if (machineCode == null || machineCode.isEmpty()) {
            throw new RuntimeException("该卡密已绑定机器，请提供机器码");
        }
        if (!card.getMachineCode().equals(machineCode)) {
            throw new RuntimeException("机器码不匹配，该卡密已绑定其他设备");
        }
    }

    /**
     * 获取用户的卡密
     * @param userId 用户ID
     * @return 卡密列表
     */
    public List<Card> getUserCards(Long userId) {
        // 1. 获取用户的所有订单
        List<Order> orders = orderMapper.findByUserId(userId.intValue());
        
        // 2. 提取所有卡密
        List<String> cardKeys = new ArrayList<>();
        for (Order order : orders) {
            if (order.getCardKeys() != null && !order.getCardKeys().isEmpty()) {
                String[] keys = order.getCardKeys().split(",");
                for (String key : keys) {
                    if (!key.trim().isEmpty()) {
                        cardKeys.add(key.trim());
                    }
                }
            }
        }
        
        // 3. 查询卡密详情
        if (cardKeys.isEmpty()) {
            return new ArrayList<>();
        }

        List<Card> list = cardMapper.findByCardKeys(cardKeys);
        enrichAdvancedTimeCardExpireFromStatus(list);
        return list;
    }

    /**
     * 批量创建卡密
     * @param count 创建数量
     * @param cardType 卡密类型
     * @param duration 持续时间
     * @param totalCount 总次数
     * @param verifyMethod 验证方式
     * @param encryptionType 加密类型
     * @param allowReverify 允许重复验证
     * @param creatorType 创建者类型
     * @param creatorId 创建者ID
     * @param creatorName 创建者名称
     * @return 创建的卡密列表
     */
    public List<Card> createCards(int count, String cardType, int duration, int totalCount, 
                                 String verifyMethod, String encryptionType, int allowReverify,
                                 String creatorType, Long creatorId, String creatorName, Long apiKeyId) {
        
        if ("advanced".equalsIgnoreCase(encryptionType)) {
            return createAdvancedCards(count, totalCount, duration, allowReverify, creatorId, creatorType, creatorName, apiKeyId);
        }
                                     
        List<Card> cards = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (int i = 0; i < count; i++) {
            Card card = new Card();
            String key = generateCardKey();
            card.setCardKey(key);
            
            // Generate encrypted key (SHA1)
            String encType = (encryptionType == null || encryptionType.isEmpty()) ? "sha1" : encryptionType;
            if ("sha1".equalsIgnoreCase(encType) || "plain".equalsIgnoreCase(encType)) {
                card.setEncryptedKey(sha1(key));
                // Force sha1 as we store hash
                encType = "sha1";
            } else {
                // Default to sha1
                card.setEncryptedKey(sha1(key));
                encType = "sha1";
            }
            
            card.setCardType(cardType);
            card.setDuration(duration);
            card.setTotalCount(totalCount);
            card.setRemainingCount(totalCount);
            card.setStatus(0); // 未使用
            card.setVerifyMethod(verifyMethod);
            card.setEncryptionType(encType);
            card.setAllowReverify(allowReverify);
            card.setCreateTime(now);
            
            card.setCreatorType(creatorType);
            card.setCreatorId(creatorId);
            card.setCreatorName(creatorName);
            card.setApiKeyId(apiKeyId);
            
            cards.add(card);
        }

        cardMapper.batchInsert(cards);
        return cards;
    }

    // Overload for backward compatibility
    public List<Card> createCards(int count, String cardType, int duration, int totalCount, 
                                 String verifyMethod, String encryptionType, int allowReverify,
                                 String creatorType, Long creatorId, String creatorName) {
        return createCards(count, cardType, duration, totalCount, verifyMethod, encryptionType, allowReverify, creatorType, creatorId, creatorName, null);
    }

    /**
     * SHA1 encryption
     */
    private String sha1(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-1");
            byte[] result = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : result) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("SHA-1 algorithm not found", e);
        }
    }

    /**
     * 生成随机卡密
     * @return 卡密字符串
     */
    private String generateCardKey() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase();
    }

    /**
     * 获取指定 API Key 下的卡密
     */
    public List<Card> getCardsByApiKey(Long apiKeyId) {
        List<Card> list = cardMapper.findByApiKeyId(apiKeyId);
        enrichAdvancedTimeCardExpireFromStatus(list);
        return list;
    }

    @Transactional
    public void deleteCard(Long id) {
        // Find card to get encrypted_key (card_hash)
        Card card = cardMapper.findById(id);
        if (card != null && card.getEncryptedKey() != null) {
            String cardHash = card.getEncryptedKey();
            // Delete from related tables
            cardStatusMapper.deleteByCardHash(cardHash);
            cardCipherMapper.deleteByCardHash(cardHash);
        }
        cardMapper.delete(id);
    }

    public List<Card> getAllCards() {
        List<Card> list = cardMapper.findAll();
        enrichAdvancedTimeCardExpireFromStatus(list);
        return list;
    }

    /**
     * 高级时间卡在核销时曾未把 card_status.expire_time 同步到 cards.expire_time，列表会误显「未激活」。
     * 从 card_status 补全内存中的过期时间（并尽量回写主表一行，修复历史脏数据）。
     */
    private void enrichAdvancedTimeCardExpireFromStatus(List<Card> cards) {
        if (cards == null || cards.isEmpty()) {
            return;
        }
        for (Card c : cards) {
            if (c.getEncryptionType() == null || !"advanced".equalsIgnoreCase(c.getEncryptionType())) {
                continue;
            }
            if (!"time".equals(c.getCardType())) {
                continue;
            }
            if (c.getEncryptedKey() == null || c.getEncryptedKey().isEmpty()) {
                continue;
            }
            if (c.getExpireTime() != null) {
                continue;
            }
            try {
                CardStatus st = cardStatusMapper.findByCardHash(c.getEncryptedKey());
                if (st != null && st.getExpireTime() != null) {
                    c.setExpireTime(st.getExpireTime());
                    try {
                        cardMapper.updateExpireTimeByHash(c.getEncryptedKey(), st.getExpireTime());
                    } catch (Exception ignored) {
                        // 列表展示已正确；回写失败不影响
                    }
                }
            } catch (Exception ignored) {
                // ignore per-row
            }
        }
    }

    /**
     * 管理员编辑卡密（含机器码重置、持续时间、次数等）
     */
    @Transactional
    public void adminUpdateCard(Long id, Map<String, Object> body) {
        Card card = cardMapper.findById(id);
        if (card == null) {
            throw new RuntimeException("卡密不存在");
        }

        if (body.containsKey("machine_code")) {
            Object mc = body.get("machine_code");
            card.setMachineCode(mc == null || mc.toString().isEmpty() ? null : mc.toString());
        }
        if (body.containsKey("duration")) {
            card.setDuration(Integer.parseInt(body.get("duration").toString()));
        }
        if (body.containsKey("total_count")) {
            card.setTotalCount(Integer.parseInt(body.get("total_count").toString()));
        }
        if (body.containsKey("remaining_count")) {
            card.setRemainingCount(Integer.parseInt(body.get("remaining_count").toString()));
        }
        if (body.containsKey("allow_reverify")) {
            card.setAllowReverify(Integer.parseInt(body.get("allow_reverify").toString()));
        }

        cardMapper.update(card);
    }

    /**
     * 管理员暂停(2)或恢复启用(请求体为 1：恢复为未使用 0 或已使用 1)
     */
    @Transactional
    public String updateAdminCardStatus(Long id, int targetStatus) {
        Card card = cardMapper.findById(id);
        if (card == null) {
            throw new RuntimeException("卡密不存在");
        }
        boolean advanced = card.getEncryptionType() != null && "advanced".equalsIgnoreCase(card.getEncryptionType());
        String hash = card.getEncryptedKey();

        if (targetStatus == 2) {
            if (Integer.valueOf(2).equals(card.getStatus())) {
                return "卡密已处于暂停状态";
            }
            boolean pausedAfterUse = Integer.valueOf(1).equals(card.getStatus()) || card.getUseTime() != null;
            cardMapper.updateStatusOnly(id, 2);
            if (advanced && hash != null) {
                try {
                    cardStatusMapper.updateIsValid(hash, 0);
                } catch (Exception e) {
                    // card_status 可能不存在，忽略
                }
            }
            return pausedAfterUse
                    ? "卡密已暂停；该卡密此前已激活，用户校验时将提示「卡密被停止使用」"
                    : "卡密已暂停";
        }

        if (targetStatus == 1) {
            if (!Integer.valueOf(2).equals(card.getStatus())) {
                throw new RuntimeException("仅暂停状态的卡密可恢复启用");
            }
            int restored = card.getUseTime() != null ? 1 : 0;
            cardMapper.updateStatusOnly(id, restored);
            if (advanced && hash != null) {
                try {
                    cardStatusMapper.updateIsValid(hash, 1);
                } catch (Exception e) {
                    // ignore
                }
            }
            return "卡密已恢复启用";
        }

        throw new RuntimeException("不支持的状态操作");
    }

    private List<Card> createAdvancedCards(int count, int totalCount, int duration, int allowReverify, Long creatorId, String creatorType, String creatorName, Long apiKeyId) {
        List<Card> result = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();
        
        try {
            for (int i = 0; i < count; i++) {
                // 1. Prepare Payload
                CardPayload payload = new CardPayload();
                payload.cardId = UUID.randomUUID().toString().replace("-", "") + UUID.randomUUID().toString().replace("-", ""); // 64 chars
                // 时间卡密过期时间由首次核销时动态计算，payload 仅作兜底上限
                // 设置为 duration 的 2 倍以确保首次核销不被 payload 校验拦截
                if (duration > 0) {
                     payload.expireTime = now.plusDays((long) duration * 2).atZone(java.time.ZoneId.systemDefault()).toEpochSecond();
                } else {
                     payload.expireTime = now.plusYears(100).atZone(java.time.ZoneId.systemDefault()).toEpochSecond();
                }
                payload.totalCount = totalCount;
                payload.nonce = advancedCryptoUtil.generateNonce();
                
                String jsonPayload = objectMapper.writeValueAsString(payload);
                
                // 2. Encrypt (AES-GCM)
                AdvancedCryptoUtil.EncryptedResult encResult = advancedCryptoUtil.encrypt(jsonPayload, keyManagerService.getAesKey());
                
                // 3. Sign (ECC) -> Sign(IV + Cipher)
                String dataToSign = encResult.iv + "." + encResult.cipherText;
                String signature = advancedCryptoUtil.sign(dataToSign, keyManagerService.getEccKeyPair().getPrivate());
                
                // 4. Build Final Key String: IV$Cipher$Sig
                String finalKey = encResult.iv + "$" + encResult.cipherText + "$" + signature;
                
                // 5. Hash for Storage (Argon2id)
                String cardHash = advancedCryptoUtil.hashArgon2id(payload.cardId, keyManagerService.getPepper());
                
                // 6. Save to DB
                CardCipher cipher = new CardCipher();
                cipher.setCardHash(cardHash);
                cipher.setCipherData(encResult.cipherText);
                cipher.setIv(encResult.iv);
                cipher.setSignData(signature);
                cipher.setSalt("global"); // Using global pepper
                cipher.setCreateTime(now);
                cardCipherMapper.insert(cipher);
                
                CardStatus status = new CardStatus();
                status.setCardHash(cardHash);
                status.setRemainCount(totalCount);
                status.setTotalCount(totalCount);
                // 时间卡密不在创建时设置过期时间，而是在首次核销时按 duration 计算
                status.setIsValid(1);
                cardStatusMapper.insert(status);
                
                // 7. Add to result AND insert into main cards table for UI compatibility
                Card card = new Card();
                card.setCardKey(finalKey);
                card.setEncryptedKey(cardHash); // Store hash for reference
                card.setCardType(totalCount > 0 ? "count" : "time"); 
                card.setDuration(duration);
                card.setTotalCount(totalCount);
                card.setRemainingCount(totalCount);
                card.setCreateTime(now);
                card.setStatus(0);
                card.setEncryptionType("advanced");
                card.setVerifyMethod("web");
                card.setAllowReverify(allowReverify);
                card.setCreatorId(creatorId);
                card.setCreatorType(creatorType);
                card.setCreatorName(creatorName);
                card.setApiKeyId(apiKeyId);
                
                result.add(card);
            }
            
            // Batch insert into main table
            cardMapper.batchInsert(result);
            
        } catch (Exception e) {
            throw new RuntimeException("Failed to create advanced cards: " + e.getMessage(), e);
        }
        
        return result;
    }

    private Card useAdvancedCard(String fullKey, String deviceId, String ipAddress, Long apiKeyId, String machineCode) {
        try {
            // Check for spaces and replace with + if necessary (common URL decoding issue)
            if (fullKey.contains(" ")) {
                fullKey = fullKey.replace(" ", "+");
            }
            
            String[] parts = fullKey.split("\\$");
            if (parts.length != 3) {
                 throw new RuntimeException("Invalid card format");
            }
            
            String ivB64 = parts[0];
            String cipherB64 = parts[1];
            String sigB64 = parts[2];
            
            // Verify Signature
            String dataToVerify = ivB64 + "." + cipherB64;
            boolean validSig = advancedCryptoUtil.verify(dataToVerify, sigB64, keyManagerService.getEccKeyPair().getPublic());
            if (!validSig) {
                throw new RuntimeException("卡密签名验证失败，可能已被篡改");
            }
            
            // Decrypt
            String json = advancedCryptoUtil.decrypt(cipherB64, ivB64, keyManagerService.getAesKey());
            CardPayload payload = objectMapper.readValue(json, CardPayload.class);
            
            // Hash Check
            String cardHash = advancedCryptoUtil.hashArgon2id(payload.cardId, keyManagerService.getPepper());
            
            // Verify API Key binding for Advanced Card
            // We need to look up the card metadata (apiKeyId) from the main cards table using the hash or key
            // Since we don't store apiKeyId in payload or card_status, we rely on cardMapper.findByEncryptedKey (if indexed) or similar.
            // But cardMapper.findByCardKey(fullKey) should work if the fullKey matches exactly.
            Card cardMetadata = cardMapper.findByCardKey(fullKey);
            if (cardMetadata != null && cardMetadata.getApiKeyId() != null) {
                 if (apiKeyId == null || !cardMetadata.getApiKeyId().equals(apiKeyId)) {
                     throw new RuntimeException("该卡密为专属卡密，当前API密钥无法使用");
                 }
            }

            // 一机一码校验（高级卡密）
            if (cardMetadata != null) {
                verifyMachineCode(cardMetadata, machineCode);
            }

            CardStatus statusRecord = cardStatusMapper.findByCardHash(cardHash);
            
            if (statusRecord == null) {
                throw new RuntimeException("卡密不存在或伪造");
            }

            if (cardMetadata != null && Integer.valueOf(2).equals(cardMetadata.getStatus())) {
                boolean wasActivated = cardMetadata.getUseTime() != null
                        || (statusRecord.getLastUseTime() != null);
                throw new RuntimeException(wasActivated ? "卡密被停止使用" : "卡密已停用");
            }

            if (statusRecord.getIsValid() != null && statusRecord.getIsValid() == 0) {
                boolean wasActivated = (cardMetadata != null && cardMetadata.getUseTime() != null)
                        || (statusRecord.getLastUseTime() != null);
                throw new RuntimeException(wasActivated ? "卡密被停止使用" : "卡密已停用");
            }
            
            if (payload.expireTime != null && System.currentTimeMillis() / 1000 > payload.expireTime) {
                throw new RuntimeException("卡密已过期");
            }
            
            if (statusRecord.getExpireTime() != null && LocalDateTime.now().isAfter(statusRecord.getExpireTime())) {
                throw new RuntimeException("卡密已过期");
            }
            
            boolean isTimeCard = (statusRecord.getTotalCount() == null || statusRecord.getTotalCount() <= 0);

            // 高级时间卡：不允许重复验证时，已激活则拒绝
            if (isTimeCard && cardMetadata != null
                    && cardMetadata.getAllowReverify() != null && cardMetadata.getAllowReverify() == 0
                    && statusRecord.getLastUseTime() != null) {
                throw new RuntimeException("该卡密不允许重复验证，验证次数已达上限(1次)");
            }

            if (statusRecord.getRemainCount() <= 0 && !isTimeCard) {
                throw new RuntimeException("卡密次数已用尽");
            }
            
            // Deduct with Distributed Lock
            String lockKey = "lock:card:" + cardHash;
            RLock lock = (redissonClient != null) ? redissonClient.getLock(lockKey) : null;
            
            try {
                if (lock != null) {
                    boolean locked = lock.tryLock(5, 10, TimeUnit.SECONDS);
                    if (!locked) {
                        throw new RuntimeException("系统繁忙，请重试");
                    }
                }
                
                // Double Check
                statusRecord = cardStatusMapper.findByCardHash(cardHash);
                
                if (statusRecord.getRemainCount() <= 0 && !isTimeCard) {
                    throw new RuntimeException("卡密次数已用尽");
                }
                
                int newCount = statusRecord.getRemainCount();
                LocalDateTime activatedExpire = statusRecord.getExpireTime();

                if (!isTimeCard) {
                    newCount = newCount - 1;
                    cardStatusMapper.updateUsage(cardHash, newCount, LocalDateTime.now());
                } else {
                    // 时间卡首次激活：此前 expire_time 为空，现在根据 duration 计算并写入
                    if (activatedExpire == null && cardMetadata != null && cardMetadata.getDuration() != null && cardMetadata.getDuration() > 0) {
                        activatedExpire = LocalDateTime.now().plusDays(cardMetadata.getDuration());
                        cardStatusMapper.activateExpireTime(cardHash, activatedExpire);
                    }
                    cardStatusMapper.updateUsage(cardHash, newCount, LocalDateTime.now());
                }

                // 首次使用时绑定机器码（高级卡密）
                String boundMachineCode = (cardMetadata != null) ? cardMetadata.getMachineCode() : null;
                if (boundMachineCode == null && machineCode != null && !machineCode.isEmpty()) {
                    boundMachineCode = machineCode;
                }

                Card card = new Card();
                card.setId(statusRecord.getId());
                card.setCardKey(fullKey);
                card.setRemainingCount(newCount);
                card.setTotalCount(statusRecord.getTotalCount());
                card.setMachineCode(boundMachineCode);

                if (isTimeCard) {
                    card.setStatus(1);
                    card.setExpireTime(activatedExpire);
                } else {
                    card.setStatus(newCount <= 0 ? 1 : (newCount < statusRecord.getTotalCount() ? 1 : 0));
                }

                card.setCardType(isTimeCard ? "time" : "count");
                card.setUseTime(LocalDateTime.now());

                // 同步主表（时间卡带 expire_time + 机器码）
                try {
                    LocalDateTime syncExpire = isTimeCard ? activatedExpire : null;
                    cardMapper.updateUsageByHash(cardHash, LocalDateTime.now(), card.getStatus(), newCount, syncExpire, boundMachineCode);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                
                // Log webhook if needed
                if (apiKeyId != null) {
                     org.xxg.backend.backend.entity.ApiKey apiKey = apiKeyMapper.findById(apiKeyId);
                     if (apiKey != null) {
                         webhookService.triggerWebhook(apiKey, card, ipAddress);
                     }
                }
                
                return card;
                
            } finally {
                if (lock != null && lock.isHeldByCurrentThread()) {
                    lock.unlock();
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("卡密验证失败: " + e.getMessage());
        }
    }

    /**
     * 获取卡密使用趋势
     * @param days 天数
     * @return 趋势数据
     */
    public Map<String, Object> getUsageTrend(int days) {
        List<Map<String, Object>> rawData = cardMapper.getUsageTrend(days);
        
        // 补全日期，确保每天都有数据，即使是0
        List<String> dates = new ArrayList<>();
        List<Integer> counts = new ArrayList<>();
        
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(days - 1);
        
        Map<String, Integer> dataMap = rawData.stream()
            .collect(Collectors.toMap(
                m -> (String) m.get("date"),
                m -> (Integer) m.get("count")
            ));
            
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        
        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            String dateStr = date.format(formatter);
            dates.add(dateStr);
            counts.add(dataMap.getOrDefault(dateStr, 0));
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("dates", dates);
        result.put("counts", counts);
        
        return result;
    }
}
