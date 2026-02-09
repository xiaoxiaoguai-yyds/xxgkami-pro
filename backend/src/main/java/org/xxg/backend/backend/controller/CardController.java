package org.xxg.backend.backend.controller;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.entity.ApiKey;
import org.xxg.backend.backend.entity.Card;
import org.xxg.backend.backend.service.ApiKeyService;
import org.xxg.backend.backend.service.CardService;

import java.util.List;
import java.util.Map;

import org.xxg.backend.backend.util.CustomCardObfuscator;

/**
 * 卡密控制器
 */
@RestController
@RequestMapping("/cards")
public class CardController {

    @Autowired
    private CardService cardService;

    @Autowired
    private ApiKeyService apiKeyService;
    
    @Autowired
    private CustomCardObfuscator customCardObfuscator;

    /**
     * 获取用户的卡密
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getUserCards(@PathVariable Long userId) {
        try {
            List<Card> cards = cardService.getUserCards(userId);
            return ResponseEntity.ok(Map.of("success", true, "data", cards));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    /**
     * 管理员批量创建卡密
     */
    @PostMapping("/admin/create")
    public ResponseEntity<Map<String, Object>> createCards(@RequestBody CreateCardRequest request) {
        try {
            // Default admin user for now (ID: 2, Username: admin)
            // In a real app, retrieve from SecurityContext
            Long adminId = 2L;
            String adminName = "admin";
            String creatorType = "admin";

            List<Card> cards = cardService.createCards(
                request.getCount(),
                request.getCardType(),
                request.getDuration(),
                request.getTotalCount(),
                request.getVerifyMethod(),
                request.getEncryptionType(),
                request.getAllowReverify(),
                creatorType,
                adminId,
                adminName,
                request.getApiKeyId()
            );
            return ResponseEntity.ok(Map.of("success", true, "data", cards));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    /**
     * 管理员获取所有卡密
     */
    @GetMapping("/admin/all")
    public ResponseEntity<Map<String, Object>> getAllCards() {
        try {
            List<Card> cards = cardService.getAllCards();
            return ResponseEntity.ok(Map.of("success", true, "data", cards));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @GetMapping("/apikey/{apiKeyId}")
    public ResponseEntity<Map<String, Object>> getApiKeyCards(@PathVariable Long apiKeyId) {
        try {
            List<Card> cards = cardService.getCardsByApiKey(apiKeyId);
            return ResponseEntity.ok(Map.of("success", true, "data", cards));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    /**
     * 使用卡密
     */
    @RequestMapping(value = "/use", method = {RequestMethod.POST, RequestMethod.GET})
    public ResponseEntity<Map<String, Object>> useCard(
            @RequestParam(required = false) Map<String, String> requestParams,
            @RequestBody(required = false) Map<String, String> requestBody,
            jakarta.servlet.http.HttpServletRequest httpRequest) {
        
        Map<String, String> params = requestParams != null ? requestParams : new java.util.HashMap<>();
        if (requestBody != null) {
            params.putAll(requestBody);
        }

        String cardKey = params.get("card_key");
        String deviceId = params.get("device_id");
        String apiKeyStr = params.get("api_key"); // If passed as parameter
        
        // Try to get IP from request if not provided
        String ipAddress = params.get("ip_address");
        if (ipAddress == null || ipAddress.isEmpty()) {
            ipAddress = httpRequest.getRemoteAddr();
        }

        if (cardKey == null || cardKey.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Card key is required"));
        }
        
        try {
            // Resolve API Key ID if provided
            Long apiKeyId = null;
            if (apiKeyStr != null && !apiKeyStr.isEmpty()) {
                ApiKey apiKey = apiKeyService.getByApiKey(apiKeyStr);
                if (apiKey == null) {
                    return ResponseEntity.status(403).body(Map.of("success", false, "message", "Invalid API Key"));
                }
                if (apiKey.getStatus() != 1) {
                    return ResponseEntity.status(403).body(Map.of("success", false, "message", "API Key is disabled"));
                }
                apiKeyId = apiKey.getId();
                
                // 检查是否开启了卡密加密验证
                if (Boolean.TRUE.equals(apiKey.getEnableCardEncryption())) {
                    // 如果开启了加密验证，必须对传入的 cardKey 进行解密
                    // 尝试解密
                    try {
                        String decryptedKey = customCardObfuscator.deobfuscate(cardKey);
                        System.out.println("DEBUG: Encrypted Key: " + cardKey);
                        System.out.println("DEBUG: Decrypted Key: " + decryptedKey);
                        System.out.println("DEBUG: Contains $ ? " + (decryptedKey != null && decryptedKey.contains("$")));
                        
                        if (decryptedKey == null) {
                            throw new RuntimeException("Decryption failed");
                        }
                        // 使用解密后的卡密进行后续验证
                        cardKey = decryptedKey;
                    } catch (Exception e) {
                        return ResponseEntity.badRequest().body(Map.of("success", false, "message", "卡密格式错误或解密失败(Encrypted Card Key Required)"));
                    }
                }
                
                // Update usage stats
                apiKeyService.updateUsage(apiKeyId);
            }
            
            cardService.useCard(cardKey, deviceId, ipAddress, apiKeyId);
            return ResponseEntity.ok(Map.of("success", true, "message", "Card used successfully"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    /**
     * 获取卡密使用趋势
     */
    @GetMapping("/trend")
    public ResponseEntity<Map<String, Object>> getUsageTrend(@RequestParam(defaultValue = "7") int days) {
        try {
            Map<String, Object> trend = cardService.getUsageTrend(days);
            return ResponseEntity.ok(trend);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 创建卡密请求对象
     */
    public static class CreateCardRequest {
        private int count;
        
        @JsonProperty("card_type")
        private String cardType;
        
        private int duration;
        
        @JsonProperty("total_count")
        private int totalCount;
        
        @JsonProperty("verify_method")
        private String verifyMethod;
        
        @JsonProperty("encryption_type")
        private String encryptionType;
        
        @JsonProperty("allow_reverify")
        private int allowReverify;

        @JsonProperty("api_key_id")
        private Long apiKeyId;

        // Getters and Setters
        public int getCount() { return count; }
        public void setCount(int count) { this.count = count; }

        public String getCardType() { return cardType; }
        public void setCardType(String cardType) { this.cardType = cardType; }

        public int getDuration() { return duration; }
        public void setDuration(int duration) { this.duration = duration; }

        public int getTotalCount() { return totalCount; }
        public void setTotalCount(int totalCount) { this.totalCount = totalCount; }

        public String getVerifyMethod() { return verifyMethod; }
        public void setVerifyMethod(String verifyMethod) { this.verifyMethod = verifyMethod; }

        public String getEncryptionType() { return encryptionType; }
        public void setEncryptionType(String encryptionType) { this.encryptionType = encryptionType; }

        public int getAllowReverify() { return allowReverify; }
        public void setAllowReverify(int allowReverify) { this.allowReverify = allowReverify; }

        public Long getApiKeyId() { return apiKeyId; }
        public void setApiKeyId(Long apiKeyId) { this.apiKeyId = apiKeyId; }
    }
}
