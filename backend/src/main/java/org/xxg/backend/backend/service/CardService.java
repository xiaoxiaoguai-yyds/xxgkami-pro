package org.xxg.backend.backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.xxg.backend.backend.mapper.ApiKeyMapper;
import org.xxg.backend.backend.mapper.ApiKeyMachineSpecRedemptionMapper;
import org.xxg.backend.backend.mapper.CardMapper;
import org.xxg.backend.backend.mapper.OrderMapper;
import org.xxg.backend.backend.mapper.UserMapper;
import org.xxg.backend.backend.entity.ApiKey;
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
import com.fasterxml.jackson.databind.JsonNode;
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
    private ApiKeyMachineSpecRedemptionMapper apiKeyMachineSpecRedemptionMapper;
    
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

        ApiKey apiKeyEntity = loadApiKeyOrNull(apiKeyId);
        enforceRequireMachineCode(apiKeyEntity, machineCode);

        if (card.getStatus() != null && card.getStatus() == 2) {
            boolean wasActivated = card.getUseTime() != null;
            throw new RuntimeException(wasActivated ? "卡密被停止使用" : "卡密已停用");
        }

        if (Integer.valueOf(4).equals(card.getStatus())) {
            throw new RuntimeException("该卡密已用于续期合并，无法再次使用");
        }

        boolean needsMachinePersist = reconcileUsedCardMissingMachine(card, machineCode);
        verifyMachineCode(card, machineCode);

        assertMachineSpecAllowsRedemption(apiKeyEntity, machineCode, card);

        LocalDateTime now = LocalDateTime.now();
        boolean isUpdated = false;

        if ("time".equals(card.getCardType())) {
            if (card.getStatus() != null && card.getStatus() != 0) {
                if (card.getExpireTime() != null && card.getExpireTime().isBefore(now)) {
                    throw new RuntimeException("卡密已过期");
                }
                if (card.getAllowReverify() != null && card.getAllowReverify() == 0) {
                    throw new RuntimeException("该卡密不允许重复验证，验证次数已达上限(1次)");
                }
                if (needsMachinePersist) {
                    cardMapper.update(card);
                }
            } else {
                Card anchor = null;
                if (Boolean.TRUE.equals(card.getStackTimeIfSameMachine())
                        && machineCode != null && !machineCode.isEmpty()
                        && card.getDuration() != null && card.getDuration() > 0) {
                    anchor = pickBestStackAnchor(machineCode, card.getApiKeyId(), card.getId());
                }

                if (anchor != null) {
                    extendAnchorSubscription(anchor, card.getDuration());
                    cardMapper.markCardMergedInto(card.getId(), anchor.getId(), now, machineCode, deviceId, ipAddress);
                    recordMachineSpecRedemptionIfNeeded(apiKeyEntity, machineCode, card);
                    notifyCardConsumed(apiKeyEntity, anchor, ipAddress, cardKey, now);

                    Card reloaded = cardMapper.findById(anchor.getId());
                    enrichAdvancedTimeCardExpireFromStatus(Collections.singletonList(reloaded));
                    return reloaded;
                }

                card.setUseTime(now);
                card.setExpireTime(now.plusDays(card.getDuration()));
                card.setStatus(1);
                card.setDeviceId(deviceId);
                card.setIpAddress(ipAddress);
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
            recordMachineSpecRedemptionIfNeeded(apiKeyEntity, machineCode, card);
        }

        notifyCardConsumed(apiKeyEntity, card, ipAddress, cardKey, now);

        return card;
    }

    private void notifyCardConsumed(ApiKey apiKey, Card webhookCard, String ipAddress, String usedCardKey, LocalDateTime now) {
        if (apiKey != null) {
            webhookService.triggerWebhook(apiKey, webhookCard, ipAddress);
        }

        try {
            Order order = orderMapper.findByCardKey(usedCardKey);
            if (order != null && order.getUserId() != null) {
                User user = userMapper.findById(Long.valueOf(order.getUserId()));
                if (user != null && user.getEmail() != null) {
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                    emailService.sendCardUsedNotification(user.getEmail(), usedCardKey, now.format(formatter));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
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

    private ApiKey loadApiKeyOrNull(Long apiKeyId) {
        if (apiKeyId == null) {
            return null;
        }
        return apiKeyMapper.findById(apiKeyId);
    }

    private void enforceRequireMachineCode(ApiKey apiKey, String machineCode) {
        if (apiKey == null) {
            return;
        }
        if (Boolean.TRUE.equals(apiKey.getRequireMachineCode()) && (machineCode == null || machineCode.isBlank())) {
            throw new RuntimeException("当前 API 密钥要求核销时必须提供机器码");
        }
    }

    /** 已使用但历史未写入机器码的卡：用本次传入的机器码补齐绑定；若发生补绑返回 true 以便落库 */
    private boolean reconcileUsedCardMissingMachine(Card card, String machineCode) {
        if (machineCode == null || machineCode.isBlank()) {
            return false;
        }
        if (!Integer.valueOf(1).equals(card.getStatus())) {
            return false;
        }
        if (card.getMachineCode() != null && !card.getMachineCode().isBlank()) {
            return false;
        }
        card.setMachineCode(machineCode);
        return true;
    }

    private LocalDateTime getEffectiveTimeCardExpire(Card c) {
        if (c == null) {
            return null;
        }
        if (c.getExpireTime() != null) {
            return c.getExpireTime();
        }
        if (c.getEncryptionType() != null && "advanced".equalsIgnoreCase(c.getEncryptionType())
                && c.getEncryptedKey() != null && !c.getEncryptedKey().isEmpty()) {
            try {
                CardStatus st = cardStatusMapper.findByCardHash(c.getEncryptedKey());
                if (st != null) {
                    return st.getExpireTime();
                }
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    private Card pickBestStackAnchor(String machineCode, Long apiKeyId, Long excludeCardId) {
        Long exId = excludeCardId != null ? excludeCardId : -1L;
        List<Card> candidates = cardMapper.listStackAnchorCandidates(machineCode, exId);
        LocalDateTime now = LocalDateTime.now();
        Card best = null;
        LocalDateTime bestExp = null;
        for (Card c : candidates) {
            if (!Objects.equals(c.getApiKeyId(), apiKeyId)) {
                continue;
            }
            LocalDateTime exp = getEffectiveTimeCardExpire(c);
            if (exp == null || !exp.isAfter(now)) {
                continue;
            }
            if (best == null || bestExp == null || exp.isAfter(bestExp)) {
                best = c;
                bestExp = exp;
            }
        }
        return best;
    }

    private void extendAnchorSubscription(Card anchor, int addDays) {
        if (anchor == null || addDays <= 0) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime base = getEffectiveTimeCardExpire(anchor);
        if (base == null || !base.isAfter(now)) {
            base = now;
        }
        LocalDateTime newExp = base.plusDays(addDays);
        cardMapper.updateExpireTimeById(anchor.getId(), newExp);
        if (anchor.getEncryptedKey() != null && anchor.getEncryptionType() != null
                && "advanced".equalsIgnoreCase(anchor.getEncryptionType())) {
            cardStatusMapper.activateExpireTime(anchor.getEncryptedKey(), newExp);
        }
    }

    private Optional<String> resolveTrackedSpecKey(ApiKey apiKey, Card card) {
        if (apiKey == null || card == null) {
            return Optional.empty();
        }
        String json = apiKey.getMachineSpecOnceConfig();
        if (json == null || json.isBlank()) {
            return Optional.empty();
        }
        try {
            JsonNode root = objectMapper.readTree(json);
            if (!root.path("enabled").asBoolean(false)) {
                return Optional.empty();
            }
            JsonNode rules = root.get("rules");
            if (rules == null || !rules.isArray()) {
                return Optional.empty();
            }
            for (JsonNode rule : rules) {
                String custom = rule.hasNonNull("spec_key") ? rule.get("spec_key").asText() : null;
                if (custom != null && !custom.isBlank()) {
                    if (ruleMatchesSpecRule(rule, card)) {
                        return Optional.of(custom.trim());
                    }
                    continue;
                }
                String ctype = rule.hasNonNull("card_type") ? rule.get("card_type").asText() : "";
                String cardType = card.getCardType() != null ? card.getCardType() : "";
                if (!ctype.equalsIgnoreCase(cardType)) {
                    continue;
                }
                if ("time".equalsIgnoreCase(ctype) && rule.has("duration")) {
                    int rd = rule.get("duration").asInt(Integer.MIN_VALUE);
                    int cd = card.getDuration() != null ? card.getDuration() : 0;
                    if (rd != Integer.MIN_VALUE && rd == cd) {
                        return Optional.of("time:" + rd);
                    }
                }
                if ("count".equalsIgnoreCase(ctype) && rule.has("total_count")) {
                    int rt = rule.get("total_count").asInt(Integer.MIN_VALUE);
                    int ct = card.getTotalCount() != null ? card.getTotalCount() : 0;
                    if (rt != Integer.MIN_VALUE && rt == ct) {
                        return Optional.of("count:" + rt);
                    }
                }
            }
        } catch (Exception ignored) {
        }
        return Optional.empty();
    }

    /** 配置了自定义 spec_key 时仍可附加 card_type 等条件以提高可读性 */
    private boolean ruleMatchesSpecRule(JsonNode rule, Card card) {
        if (rule.hasNonNull("card_type")) {
            String want = rule.get("card_type").asText();
            String actual = card.getCardType() != null ? card.getCardType() : "";
            if (!want.equalsIgnoreCase(actual)) {
                return false;
            }
        }
        if (rule.has("duration")) {
            int rd = rule.get("duration").asInt(Integer.MIN_VALUE);
            int cd = card.getDuration() != null ? card.getDuration() : 0;
            if (rd != Integer.MIN_VALUE && rd != cd) {
                return false;
            }
        }
        if (rule.has("total_count")) {
            int rt = rule.get("total_count").asInt(Integer.MIN_VALUE);
            int ct = card.getTotalCount() != null ? card.getTotalCount() : 0;
            if (rt != Integer.MIN_VALUE && rt != ct) {
                return false;
            }
        }
        return true;
    }

    private void assertMachineSpecAllowsRedemption(ApiKey apiKey, String machineCode, Card card) {
        Optional<String> sk = resolveTrackedSpecKey(apiKey, card);
        if (sk.isEmpty()) {
            return;
        }
        if (machineCode == null || machineCode.isBlank()) {
            throw new RuntimeException("已为该 API 密钥配置「同机同规格仅一次」限制，核销时必须提供机器码");
        }
        if (apiKeyMachineSpecRedemptionMapper.exists(apiKey.getId(), machineCode, sk.get())) {
            throw new RuntimeException("在当前 API 密钥下，该机器码已使用过此规格卡密，无法重复核销");
        }
    }

    private void recordMachineSpecRedemptionIfNeeded(ApiKey apiKey, String machineCode, Card card) {
        Optional<String> sk = resolveTrackedSpecKey(apiKey, card);
        if (sk.isEmpty()) {
            return;
        }
        if (machineCode == null || machineCode.isBlank()) {
            return;
        }
        if (!apiKeyMachineSpecRedemptionMapper.tryInsert(apiKey.getId(), machineCode, sk.get())) {
            throw new RuntimeException("规格核销记录冲突，请重试");
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
        return createCards(count, cardType, duration, totalCount, verifyMethod, encryptionType,
                allowReverify, creatorType, creatorId, creatorName, apiKeyId, false, false);
    }

    public List<Card> createCards(int count, String cardType, int duration, int totalCount,
                                 String verifyMethod, String encryptionType, int allowReverify,
                                 String creatorType, Long creatorId, String creatorName, Long apiKeyId,
                                 boolean stackTimeIfSameMachine) {
        return createCards(count, cardType, duration, totalCount, verifyMethod, encryptionType,
                allowReverify, creatorType, creatorId, creatorName, apiKeyId, stackTimeIfSameMachine, false);
    }

    public List<Card> createCards(int count, String cardType, int duration, int totalCount,
                                 String verifyMethod, String encryptionType, int allowReverify,
                                 String creatorType, Long creatorId, String creatorName, Long apiKeyId,
                                 boolean stackTimeIfSameMachine, boolean allowSelfUnbind) {

        if ("advanced".equalsIgnoreCase(encryptionType)) {
            return createAdvancedCards(count, totalCount, duration, allowReverify, creatorId, creatorType, creatorName, apiKeyId, stackTimeIfSameMachine, allowSelfUnbind);
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
            card.setStackTimeIfSameMachine(stackTimeIfSameMachine && "time".equals(cardType));
            card.setAllowSelfUnbind(allowSelfUnbind);

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
     * 已激活时间卡：修改 duration 会同步重算 expire_time；高级卡密额外写回 card_status。
     * 已使用次数卡（高级）：修改总次数/剩余次数会同步 card_status，否则核销仍读旧值。
     */
    @Transactional
    public void adminUpdateCard(Long id, Map<String, Object> body) {
        Card card = cardMapper.findById(id);
        if (card == null) {
            throw new RuntimeException("卡密不存在");
        }

        boolean advanced = card.getEncryptionType() != null && "advanced".equalsIgnoreCase(card.getEncryptionType());
        String cardHash = card.getEncryptedKey();

        Integer prevDuration = card.getDuration();
        LocalDateTime prevExpire = card.getExpireTime();
        LocalDateTime prevUseTime = card.getUseTime();

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
        if (body.containsKey("stack_time_if_same_machine")) {
            card.setStackTimeIfSameMachine(Boolean.TRUE.equals(body.get("stack_time_if_same_machine")));
        }
        if (body.containsKey("allow_self_unbind")) {
            card.setAllowSelfUnbind(Boolean.TRUE.equals(body.get("allow_self_unbind")));
        }

        // 已激活（或已有到期时间）的时间卡：仅改 duration 时须重算到期时间，否则核销仍按旧 expire_time
        if (body.containsKey("duration") && "time".equals(card.getCardType())) {
            int newDur = card.getDuration() != null ? card.getDuration() : 0;
            if (newDur > 0 && (prevExpire != null || prevUseTime != null)) {
                if (advanced) {
                    if (prevExpire != null) {
                        int baseDur = prevDuration != null ? prevDuration : 0;
                        card.setExpireTime(prevExpire.plusDays((long) newDur - baseDur));
                    }
                } else {
                    if (prevUseTime != null) {
                        card.setExpireTime(prevUseTime.plusDays(newDur));
                    } else if (prevExpire != null) {
                        int baseDur = prevDuration != null ? prevDuration : 0;
                        card.setExpireTime(prevExpire.plusDays((long) newDur - baseDur));
                    }
                }
                if (advanced && cardHash != null && !cardHash.isEmpty() && card.getExpireTime() != null) {
                    cardStatusMapper.activateExpireTime(cardHash, card.getExpireTime());
                }
            }
        }

        if (advanced && cardHash != null && !cardHash.isEmpty() && "count".equals(card.getCardType())) {
            if (body.containsKey("total_count") || body.containsKey("remaining_count")) {
                int remain = card.getRemainingCount() != null ? card.getRemainingCount() : 0;
                int total = card.getTotalCount() != null ? card.getTotalCount() : 0;
                cardStatusMapper.updateQuota(cardHash, remain, total);
            }
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

    private List<Card> createAdvancedCards(int count, int totalCount, int duration, int allowReverify, Long creatorId, String creatorType, String creatorName, Long apiKeyId, boolean stackTimeIfSameMachine, boolean allowSelfUnbind) {
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
                card.setStackTimeIfSameMachine(stackTimeIfSameMachine && card.getCardType() != null && "time".equals(card.getCardType()));
                card.setAllowSelfUnbind(allowSelfUnbind);
                
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
            ApiKey apiKeyEntity = loadApiKeyOrNull(apiKeyId);

            enforceRequireMachineCode(apiKeyEntity, machineCode);

            // Verify API Key binding for Advanced Card
            Card cardMetadata = cardMapper.findByCardKey(fullKey);
            if (cardMetadata != null && cardMetadata.getApiKeyId() != null) {
                 if (apiKeyId == null || !cardMetadata.getApiKeyId().equals(apiKeyId)) {
                     throw new RuntimeException("该卡密为专属卡密，当前API密钥无法使用");
                 }
            }

            if (cardMetadata != null && Integer.valueOf(4).equals(cardMetadata.getStatus())) {
                throw new RuntimeException("该卡密已用于续期合并，无法再次使用");
            }

            if (cardMetadata != null) {
                boolean persistMc = reconcileUsedCardMissingMachine(cardMetadata, machineCode);
                verifyMachineCode(cardMetadata, machineCode);
                assertMachineSpecAllowsRedemption(apiKeyEntity, machineCode, cardMetadata);
                if (persistMc) {
                    try {
                        cardMapper.update(cardMetadata);
                    } catch (Exception ignored) {
                    }
                }
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
            
            // 未写入 card_status 过期时间前，仍以密文载荷中的上限兜底；激活后以库为准，便于管理端延长时长
            if (statusRecord.getExpireTime() == null && payload.expireTime != null
                    && System.currentTimeMillis() / 1000 > payload.expireTime) {
                throw new RuntimeException("卡密已过期");
            }
            
            if (statusRecord.getExpireTime() != null && LocalDateTime.now().isAfter(statusRecord.getExpireTime())) {
                throw new RuntimeException("卡密已过期");
            }

            /*
             * 卡类型判断：必须与主表 cards.card_type（及载荷）一致，不能仅用 card_status.total_count。
             * 否则 total_count 为 0 / NULL（被 JDBC 映射成 0）时会把「次数卡」误判为「时间卡」，
             * 从而跳过 remain_count 扣减 —— 剩 1 次时会永远显示 1 次且可重复核销。
             */
            boolean isTimeCard;
            if (cardMetadata != null && cardMetadata.getCardType() != null && !cardMetadata.getCardType().isBlank()) {
                isTimeCard = "time".equalsIgnoreCase(cardMetadata.getCardType());
            } else if (payload.totalCount != null && payload.totalCount > 0) {
                isTimeCard = false;
            } else {
                boolean heuristicTime =
                        statusRecord.getTotalCount() == null || statusRecord.getTotalCount() <= 0;
                /*
                 * 若主表已声明为次数卡（历史脏数据仅有 card_metadata），仍按次数扣减，避免误判为时间卡。
                 */
                heuristicTime &= cardMetadata == null || cardMetadata.getCardType() == null
                        || !"count".equalsIgnoreCase(cardMetadata.getCardType());
                isTimeCard = heuristicTime;
            }

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
                cardMetadata = cardMapper.findByCardKey(fullKey);
                if (cardMetadata != null && Integer.valueOf(4).equals(cardMetadata.getStatus())) {
                    throw new RuntimeException("该卡密已用于续期合并，无法再次使用");
                }

                if (statusRecord.getRemainCount() <= 0 && !isTimeCard) {
                    throw new RuntimeException("卡密次数已用尽");
                }

                if (cardMetadata != null) {
                    assertMachineSpecAllowsRedemption(apiKeyEntity, machineCode, cardMetadata);
                }

                int newCount = statusRecord.getRemainCount();
                LocalDateTime activatedExpire = statusRecord.getExpireTime();

                int quotaTotal = 0;
                if (cardMetadata != null && cardMetadata.getTotalCount() != null && cardMetadata.getTotalCount() > 0) {
                    quotaTotal = cardMetadata.getTotalCount();
                } else if (statusRecord.getTotalCount() != null && statusRecord.getTotalCount() > 0) {
                    quotaTotal = statusRecord.getTotalCount();
                }

                LocalDateTime nowInner = LocalDateTime.now();

                if (isTimeCard && activatedExpire == null && cardMetadata != null
                        && Boolean.TRUE.equals(cardMetadata.getStackTimeIfSameMachine())
                        && machineCode != null && !machineCode.isEmpty()
                        && cardMetadata.getDuration() != null && cardMetadata.getDuration() > 0) {
                    Card anchor = pickBestStackAnchor(machineCode, cardMetadata.getApiKeyId(), cardMetadata.getId());
                    if (anchor != null) {
                        extendAnchorSubscription(anchor, cardMetadata.getDuration());
                        cardMapper.markCardMergedInto(cardMetadata.getId(), anchor.getId(), nowInner, machineCode,
                                deviceId, ipAddress);
                        recordMachineSpecRedemptionIfNeeded(apiKeyEntity, machineCode, cardMetadata);

                        Card anchorRow = cardMapper.findById(anchor.getId());
                        enrichAdvancedTimeCardExpireFromStatus(Collections.singletonList(anchorRow));
                        CardStatus ast = anchorRow != null && anchorRow.getEncryptedKey() != null
                                ? cardStatusMapper.findByCardHash(anchorRow.getEncryptedKey())
                                : null;

                        Card synth = new Card();
                        synth.setId(ast != null ? ast.getId() : (anchorRow != null ? anchorRow.getId() : null));
                        synth.setCardKey(anchorRow != null ? anchorRow.getCardKey() : fullKey);
                        synth.setRemainingCount(ast != null ? ast.getRemainCount() : newCount);
                        synth.setTotalCount(quotaTotal);
                        synth.setMachineCode(anchorRow != null ? anchorRow.getMachineCode() : machineCode);
                        synth.setExpireTime(anchorRow != null ? getEffectiveTimeCardExpire(anchorRow) : null);
                        synth.setStatus(1);
                        synth.setCardType("time");
                        synth.setUseTime(nowInner);

                        notifyCardConsumed(apiKeyEntity, synth, ipAddress, fullKey, nowInner);
                        return synth;
                    }
                }

                if (!isTimeCard) {
                    newCount = newCount - 1;
                    cardStatusMapper.updateUsage(cardHash, newCount, nowInner);
                    if (quotaTotal > 0
                            && (statusRecord.getTotalCount() == null || statusRecord.getTotalCount() <= 0)) {
                        cardStatusMapper.updateQuota(cardHash, newCount, quotaTotal);
                    }
                    recordMachineSpecRedemptionIfNeeded(apiKeyEntity, machineCode, cardMetadata);
                } else {
                    if (activatedExpire == null && cardMetadata != null && cardMetadata.getDuration() != null && cardMetadata.getDuration() > 0) {
                        activatedExpire = nowInner.plusDays(cardMetadata.getDuration());
                        cardStatusMapper.activateExpireTime(cardHash, activatedExpire);
                    }
                    cardStatusMapper.updateUsage(cardHash, newCount, nowInner);
                    recordMachineSpecRedemptionIfNeeded(apiKeyEntity, machineCode, cardMetadata);
                }

                String boundMachineCode = (cardMetadata != null) ? cardMetadata.getMachineCode() : null;
                if (boundMachineCode == null && machineCode != null && !machineCode.isEmpty()) {
                    boundMachineCode = machineCode;
                }

                Card card = new Card();
                card.setId(statusRecord.getId());
                card.setCardKey(fullKey);
                card.setRemainingCount(newCount);
                int totalForCard = quotaTotal;
                if (totalForCard <= 0 && statusRecord.getTotalCount() != null) {
                    totalForCard = statusRecord.getTotalCount();
                }
                card.setTotalCount(totalForCard);
                card.setMachineCode(boundMachineCode);

                if (isTimeCard) {
                    card.setStatus(1);
                    card.setExpireTime(activatedExpire);
                } else {
                    card.setStatus(newCount <= 0 ? 1 : (quotaTotal > 0 && newCount < quotaTotal ? 1 : 0));
                }

                card.setCardType(isTimeCard ? "time" : "count");
                card.setUseTime(nowInner);

                try {
                    LocalDateTime syncExpire = isTimeCard ? activatedExpire : null;
                    cardMapper.updateUsageByHash(cardHash, nowInner, card.getStatus(), newCount, syncExpire, boundMachineCode);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                notifyCardConsumed(apiKeyEntity, card, ipAddress, fullKey, nowInner);

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

    /**
     * 公开页：解析普通卡密或高级卡密（整段含 $），高级卡密会校验签名与载荷，防止恶意探测。
     */
    public Card resolveCardForPublicMachineOps(String rawInput) {
        if (rawInput == null || rawInput.isBlank()) {
            throw new RuntimeException("请输入卡密");
        }
        String trimmed = rawInput.trim();
        if (trimmed.contains("$")) {
            return resolveAdvancedCardRowForPublic(trimmed);
        }
        return cardMapper.findByCardKey(trimmed);
    }

    private Card resolveAdvancedCardRowForPublic(String fullKey) {
        try {
            if (fullKey.contains(" ")) {
                fullKey = fullKey.replace(" ", "+");
            }
            String[] parts = fullKey.split("\\$");
            if (parts.length != 3) {
                throw new RuntimeException("卡密格式无效");
            }
            String ivB64 = parts[0];
            String cipherB64 = parts[1];
            String sigB64 = parts[2];
            String dataToVerify = ivB64 + "." + cipherB64;
            if (!advancedCryptoUtil.verify(dataToVerify, sigB64, keyManagerService.getEccKeyPair().getPublic())) {
                throw new RuntimeException("卡密签名无效");
            }
            String json = advancedCryptoUtil.decrypt(cipherB64, ivB64, keyManagerService.getAesKey());
            CardPayload payload = objectMapper.readValue(json, CardPayload.class);
            String cardHash = advancedCryptoUtil.hashArgon2id(payload.cardId, keyManagerService.getPepper());
            CardStatus statusRecord = cardStatusMapper.findByCardHash(cardHash);
            if (statusRecord == null) {
                throw new RuntimeException("卡密不存在");
            }
            Card cardMetadata = cardMapper.findByCardKey(fullKey);
            if (cardMetadata == null) {
                throw new RuntimeException("卡密不存在");
            }
            return cardMetadata;
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("卡密解析失败: " + e.getMessage());
        }
    }

    /**
     * 公开页：查询是否已绑定机器码（不修改数据）
     */
    public Map<String, Object> getPublicMachineBindStatus(String rawInput) {
        Card card = resolveCardForPublicMachineOps(rawInput);
        if (card == null) {
            return Map.of("success", false, "message", "未找到该卡密");
        }
        String mc = card.getMachineCode();
        boolean bound = mc != null && !mc.isBlank();
        boolean allowSelf = Boolean.TRUE.equals(card.getAllowSelfUnbind());
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("bound", bound);
        data.put("allowSelfUnbind", allowSelf);
        if (bound) {
            data.put("machineCode", mc);
            if (card.getDeviceId() != null && !card.getDeviceId().isBlank()) {
                data.put("deviceId", card.getDeviceId());
            }
        }
        data.put("cardType", card.getCardType());
        return Map.of("success", true, "data", data);
    }

    /**
     * 公开页：解绑当前卡密上的设备码与设备 ID（须已绑定机器码）。同步清理 api_key_machine_spec_redemption。
     */
    @Transactional
    public void publicUnbindMachine(String rawInput) {
        Card card = resolveCardForPublicMachineOps(rawInput);
        if (card == null) {
            throw new RuntimeException("未找到该卡密");
        }
        if (Integer.valueOf(4).equals(card.getStatus())) {
            throw new RuntimeException("该卡密已用于续期合并，无法在此解绑，请联系管理员");
        }
        if (!Boolean.TRUE.equals(card.getAllowSelfUnbind())) {
            throw new RuntimeException("该卡密不支持自主解绑");
        }
        String mc = card.getMachineCode();
        if (mc == null || mc.isBlank()) {
            throw new RuntimeException("该卡密未绑定设备，无法解绑");
        }
        Long apiKeyId = card.getApiKeyId();
        card.setMachineCode(null);
        card.setDeviceId(null);
        cardMapper.update(card);
        if (apiKeyId != null) {
            apiKeyMachineSpecRedemptionMapper.deleteByApiKeyAndMachine(apiKeyId, mc);
        }
    }
}
