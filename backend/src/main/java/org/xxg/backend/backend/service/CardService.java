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
    public Card useCard(String cardKey, String deviceId, String ipAddress, Long apiKeyId) {
        // Advanced Card Check
        if (cardKey != null && cardKey.contains("$")) {
             return useAdvancedCard(cardKey, deviceId, ipAddress, apiKeyId);
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
        
        if (card.getStatus() == 2) { // 2 is typically "disabled"
            throw new RuntimeException("卡密已停用");
        }

        LocalDateTime now = LocalDateTime.now();
        boolean isUpdated = false;

        if ("time".equals(card.getCardType())) {
            if (card.getStatus() != 0) {
                // Already activated
                if (card.getExpireTime() != null && card.getExpireTime().isBefore(now)) {
                    throw new RuntimeException("卡密已过期");
                }
                // If we want to prevent re-use on different device, check here.
                // For now, allow valid time cards to pass "use" check.
            } else {
                // First use, activate
                card.setUseTime(now);
                card.setExpireTime(now.plusDays(card.getDuration()));
                card.setStatus(1); // Activated
                card.setDeviceId(deviceId);
                card.setIpAddress(ipAddress);
                isUpdated = true;
            }
        } else {
            // Count card
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
            
            if (card.getRemainingCount() <= 0) {
                card.setStatus(1); // Exhausted
            }
            isUpdated = true;
        }

        if (isUpdated) {
            cardMapper.update(card);
        }
        
        // Trigger Webhook if apiKeyId is present
        if (apiKeyId != null) {
            org.xxg.backend.backend.entity.ApiKey apiKey = apiKeyMapper.findById(apiKeyId);
            if (apiKey != null) {
                webhookService.triggerWebhook(apiKey, card, ipAddress);
            }
        }

        // Send notification (only on first activation or specific logic? keeping original logic)
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
    public Card useCard(String cardKey, String deviceId, String ipAddress) {
        return useCard(cardKey, deviceId, ipAddress, null);
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
        
        return cardMapper.findByCardKeys(cardKeys);
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
            return createAdvancedCards(count, totalCount, duration, creatorId, creatorType, creatorName, apiKeyId);
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
     * 获取所有卡密
     * @return 卡密列表
     */
    public List<Card> getCardsByApiKey(Long apiKeyId) {
        return cardMapper.findByApiKeyId(apiKeyId);
    }

    public List<Card> getAllCards() {
        return cardMapper.findAll();
    }

    private List<Card> createAdvancedCards(int count, int totalCount, int duration, Long creatorId, String creatorType, String creatorName, Long apiKeyId) {
        List<Card> result = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();
        
        try {
            for (int i = 0; i < count; i++) {
                // 1. Prepare Payload
                CardPayload payload = new CardPayload();
                payload.cardId = UUID.randomUUID().toString().replace("-", "") + UUID.randomUUID().toString().replace("-", ""); // 64 chars
                if (duration > 0) {
                     payload.expireTime = now.plusDays(duration).atZone(java.time.ZoneId.systemDefault()).toEpochSecond();
                } else {
                     payload.expireTime = now.plusYears(100).atZone(java.time.ZoneId.systemDefault()).toEpochSecond(); // No expiry effectively
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
                if (duration > 0) {
                    status.setExpireTime(now.plusDays(duration));
                }
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
                card.setVerifyMethod("web"); // Default
                card.setAllowReverify(1);
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

    private Card useAdvancedCard(String fullKey, String deviceId, String ipAddress, Long apiKeyId) {
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
            
            CardStatus statusRecord = cardStatusMapper.findByCardHash(cardHash);
            
            if (statusRecord == null) {
                throw new RuntimeException("卡密不存在或伪造");
            }
            
            if (statusRecord.getIsValid() == 0) {
                throw new RuntimeException("卡密已停用");
            }
            
            if (payload.expireTime != null && System.currentTimeMillis() / 1000 > payload.expireTime) {
                throw new RuntimeException("卡密已过期");
            }
            
            if (statusRecord.getExpireTime() != null && LocalDateTime.now().isAfter(statusRecord.getExpireTime())) {
                throw new RuntimeException("卡密已过期");
            }
            
            // Check if it is a time card BEFORE first count check
            boolean isTimeCardPreCheck = false;
            if (statusRecord.getExpireTime() != null && statusRecord.getExpireTime().getYear() < 2090) {
                isTimeCardPreCheck = true;
            }
            
            if (statusRecord.getRemainCount() <= 0 && !isTimeCardPreCheck) {
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
                
                // For Advanced Cards, we need to distinguish between Time and Count logic
                // The current schema stores both duration/expireTime and totalCount/remainCount
                
                // If duration > 0, it's a Time card.
                // Time cards logic:
                // 1. If never used (remainCount == totalCount?), activate it (set expire time).
                // 2. If already activated, check expiry.
                // 3. BUT advanced card schema uses `card_status` table differently.
                //    It has `remain_count`, `total_count`, `expire_time`
                
                // Let's refine the logic based on payload or DB state.
                // Since we don't have explicit "cardType" in card_status, we infer from totalCount/duration passed during creation.
                // During creation:
                //   Time Card: totalCount = whatever (UI sends 0 or 1?), duration > 0. expireTime in payload set to now+duration? NO.
                //   If Time Card, payload.expireTime is usually set to now+duration at creation time? 
                //   Wait, if it's a duration card, it should start counting from FIRST USE, not creation.
                //   Current creation logic:
                //     if (duration > 0) payload.expireTime = now.plusDays(duration)... -> This sets expiry from CREATION time.
                //     This effectively makes it a "subscription valid until X" card, not "X days from first use".
                
                // If user wants "X days from first use", we need to store duration and activate on first use.
                // However, current advanced creation logic sets hard expiry in payload.
                //   if (duration > 0) payload.expireTime = now.plusDays(duration)...
                
                // And verification logic checks:
                //   if (payload.expireTime != null && now > payload.expireTime) -> Expired.
                
                // Issue: User says "Time Card" but error is "Count exhausted".
                // Error "卡密次数已用尽" comes from:
                //   if (statusRecord.getRemainCount() <= 0)
                
                // So for Time Cards, we must ensure RemainCount is not 0, or we ignore RemainCount if it's purely time-based.
                // But `useAdvancedCard` decrements count:
                //   int newCount = statusRecord.getRemainCount() - 1;
                //   cardStatusMapper.updateUsage(..., newCount, ...);
                
                // FIX:
                // If it is a time card (implied by duration/expireTime logic?), we shouldn't decrement count OR count should be large/irrelevant.
                // But wait, "Time Card" usually implies "Unlimited uses within duration" OR "One-time activation for duration".
                // In this system's main logic (useCard), Time Card = "Activate on first use, then valid until expiry".
                // And `useCard` updates `card.status=1` (activated).
                
                // For Advanced Card:
                // We rely on `card_status` table.
                // If we want "Unlimited uses within validity", we should NOT decrement count to 0.
                // OR we check if it's a time card.
                
                // How to know if it's a time card in `useAdvancedCard`?
                // 1. Check if payload has specific flag? No.
                // 2. Check DB status?
                //    We have `statusRecord.getTotalCount()`.
                //    If created as Time Card, totalCount might be 0? 
                //    Let's check `createAdvancedCards`:
                //      card.setCardType(totalCount > 0 ? "count" : "time");
                //      So if totalCount > 0, it's Count card. If 0, Time card.
                //      BUT `createAdvancedCards` sets `payload.totalCount = totalCount`.
                
                // User input: "Total Count" field in UI is likely 1 or 0 for Time Card?
                // If UI sends total_count=100 (default in KeysManagePage), then it's a count card?
                // Wait, `KeysManagePage` logic:
                //   newKey.card_type = 'time'
                //   newKey.duration = 30
                //   newKey.total_count = 100 (Default!)
                
                // So frontend sends both duration=30 AND total_count=100.
                // Backend `createAdvancedCards` uses both.
                // It sets expiry to now+30 days.
                // It sets count to 100.
                
                // So it acts as: "Valid for 30 days from CREATION, AND limited to 100 uses".
                
                // User says: "Error: Count exhausted".
                // This means `remainCount` hit 0.
                // If it's a new card, remainCount should be 100.
                // Why is it 0?
                // Maybe user set "Gen Quantity" to 1, "Total Count" to 1?
                // If user uses it once, count becomes 0.
                // Then second use -> "Count exhausted".
                
                // If it's a TIME card (Duration > 0), we usually expect unlimited uses (or verify-only) within that time.
                // Logic change:
                // If statusRecord.getExpireTime() is set (implies Time limit), we should ALLOW use even if count is 0?
                // OR we should not decrement count?
                
                // Let's look at `useCard` (legacy) logic for Time cards:
                //   if ("time".equals(cardType)) {
                //      ... check expiry ...
                //      (Does NOT decrement count)
                //   }
                
                // So `useAdvancedCard` needs similar branching.
                // But `card_status` doesn't explicitly store "type".
                // We can infer: if `expireTime` is "reasonable" (not 100 years), treat as Time Card?
                // `createAdvancedCards`:
                //    if (duration > 0) expire = now + duration
                //    else expire = now + 100 years.
                
                // So if expireTime < now + 50 years, it's likely a Time Card.
                // Let's use a safe threshold, e.g., year 2100.
                
                boolean isTimeCard = false;
                if (statusRecord.getExpireTime() != null && statusRecord.getExpireTime().getYear() < 2090) {
                    isTimeCard = true;
                }
                
                if (statusRecord.getRemainCount() <= 0 && !isTimeCard) {
                    throw new RuntimeException("卡密次数已用尽");
                }
                
                int newCount = statusRecord.getRemainCount();
                if (!isTimeCard) {
                    newCount = newCount - 1;
                    cardStatusMapper.updateUsage(cardHash, newCount, LocalDateTime.now());
                } else {
                    // For time cards, just update use time, don't decrement count
                    // But wait, if we don't decrement, `updateUsage` might not be called?
                    // We should still update use_time.
                     cardStatusMapper.updateUsage(cardHash, newCount, LocalDateTime.now());
                }
                
                // Return result
                Card card = new Card();
                card.setId(statusRecord.getId());
                card.setCardKey(fullKey);
                card.setRemainingCount(newCount);
                card.setTotalCount(statusRecord.getTotalCount());
                card.setStatus(newCount > 0 ? 0 : 1);
                // Fix Status for Time Card: always 0 (valid) if not expired
                // BUT wait, if it's a time card and ACTIVATED, we usually want to show it as "Active/Used" in UI?
                // Standard logic: 0=Unused, 1=Active/Used, 2=Disabled.
                // If we return 0, UI shows "Unused".
                // If we return 1, UI shows "Used".
                // User complaint: "Displayed as Unused after use".
                // So we MUST return 1 if it has been used/activated.
                
                // Logic update:
                // If it is a time card:
                //   If use_time is set (which we just set), it implies it's activated.
                //   So status should be 1.
                //   BUT verify logic might block status=1?
                //   Legacy verify: if ("time".equals(type) && status != 0) -> check expiry. -> OK.
                //   So setting status=1 is safe and correct for "Used/Active" state.
                
                if (isTimeCard) {
                    card.setStatus(1); // Mark as Used/Active
                } else {
                    // Count Card: if used at least once (remain < total), mark as Used (1)
                    // even if not exhausted.
                    if (newCount < statusRecord.getTotalCount()) {
                         card.setStatus(1);
                    }
                }
                
                card.setCardType(isTimeCard ? "time" : "count");
                card.setUseTime(LocalDateTime.now());
                
                // Also update main cards table status for visibility
                try {
                     cardMapper.updateUsageByHash(cardHash, LocalDateTime.now(), card.getStatus(), newCount);
                } catch (Exception ex) {
                    // Ignore sync error, core logic is safe
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
