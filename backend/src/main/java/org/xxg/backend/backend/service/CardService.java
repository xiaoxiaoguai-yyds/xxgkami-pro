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

    /**
     * 使用卡密
     * @param cardKey 卡密
     * @param deviceId 设备ID
     * @param ipAddress IP地址
     * @return 更新后的Card对象
     */
    @Transactional
    public Card useCard(String cardKey, String deviceId, String ipAddress, Long apiKeyId) {
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
