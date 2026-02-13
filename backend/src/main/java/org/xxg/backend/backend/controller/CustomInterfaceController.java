package org.xxg.backend.backend.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.entity.ApiKey;
import org.xxg.backend.backend.mapper.ApiKeyMapper;
import org.xxg.backend.backend.service.CardService;

import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.xxg.backend.backend.entity.Card;
import java.time.Duration;
import java.time.LocalDateTime;

@RestController
@RequestMapping("/custom")
public class CustomInterfaceController {

    @Autowired
    private ApiKeyMapper apiKeyMapper;

    @Autowired
    private CardService cardService;

    @Autowired
    private org.xxg.backend.backend.util.CustomCardObfuscator customCardObfuscator;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @RequestMapping(value = "/use", method = {RequestMethod.GET, RequestMethod.POST}, produces = "application/json")
    public ResponseEntity<Map<String, Object>> useCardWithoutPathKey(
            @RequestParam(required = false) Map<String, String> queryParams,
            @RequestBody(required = false) Map<String, Object> bodyParams,
            HttpServletRequest request) {
        
        // Merge params to find potential API key
        Map<String, String> incomingParams = new HashMap<>();
        if (queryParams != null) incomingParams.putAll(queryParams);
        if (bodyParams != null) {
            for (Map.Entry<String, Object> entry : bodyParams.entrySet()) {
                incomingParams.put(entry.getKey(), String.valueOf(entry.getValue()));
            }
        }

        ApiKey apiKey = null;
        // Iterate over all values to find a matching API Key
        for (String value : incomingParams.values()) {
            // Basic optimization: API keys are usually long (e.g. 32 chars), skip short values
            if (value == null || value.length() < 10) continue;
            
            ApiKey potentialKey = apiKeyMapper.findByApiKey(value);
            if (potentialKey != null) {
                apiKey = potentialKey;
                break;
            }
        }

        if (apiKey == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Could not identify API Key from parameters. Please ensure your API Key is passed in one of the parameters."));
        }

        return processCardUse(apiKey, incomingParams, request);
    }

    @RequestMapping(value = "/{apiKeyStr}/use", method = {RequestMethod.GET, RequestMethod.POST}, produces = "application/json")
    public ResponseEntity<Map<String, Object>> useCard(
            @PathVariable String apiKeyStr,
            @RequestParam(required = false) Map<String, String> queryParams,
            @RequestBody(required = false) Map<String, Object> bodyParams,
            HttpServletRequest request) {

        // 1. Find ApiKey
        ApiKey apiKey = apiKeyMapper.findByApiKey(apiKeyStr);
        if (apiKey == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "Invalid API Key"));
        }

        // Merge params
        Map<String, String> incomingParams = new HashMap<>();
        if (queryParams != null) incomingParams.putAll(queryParams);
        if (bodyParams != null) {
            for (Map.Entry<String, Object> entry : bodyParams.entrySet()) {
                incomingParams.put(entry.getKey(), String.valueOf(entry.getValue()));
            }
        }

        return processCardUse(apiKey, incomingParams, request);
    }

    private ResponseEntity<Map<String, Object>> processCardUse(ApiKey apiKey, Map<String, String> incomingParams, HttpServletRequest request) {
        // Parse config first to get status codes for error handling
        Map<String, Object> config = null;
        List<Map<String, String>> statusCodesConfig = null;
        try {
            if (apiKey.getWebhookConfig() != null) {
                config = objectMapper.readValue(apiKey.getWebhookConfig(), new TypeReference<>() {});
                statusCodesConfig = (List<Map<String, String>>) config.get("statusCodes");
            }
        } catch (Exception e) {
            // Ignore config parse errors here, will fail later
        }

        try {
            if (apiKey.getStatus() == 0) {
                throw new RuntimeException("API Key is disabled");
            }

            if (config == null) {
                throw new RuntimeException("No interface configuration found");
            }

            List<Map<String, String>> paramConfig = (List<Map<String, String>>) config.get("params");

            if (paramConfig == null || paramConfig.isEmpty()) {
                throw new RuntimeException("No parameter mapping configured");
            }

            // 4. Resolve Target Parameters (card_key)
            String cardKey = null;
            
            for (Map<String, String> param : paramConfig) {
                String incomingParamName = param.get("key");
                String targetValueType = param.get("value"); 
                String type = param.get("type"); 

                if ("variable".equals(type) && "card_key".equals(targetValueType)) {
                    if (incomingParams.containsKey(incomingParamName)) {
                        cardKey = incomingParams.get(incomingParamName);
                    }
                }
            }

            if (cardKey == null) {
                throw new RuntimeException("Could not resolve 'card_key' from request parameters");
            }

            // Check encryption
            if (Boolean.TRUE.equals(apiKey.getEnableCardEncryption())) {
                 try {
                     String decryptedKey = customCardObfuscator.deobfuscate(cardKey);
                     if (decryptedKey == null) {
                         throw new RuntimeException("Decryption failed");
                     }
                     cardKey = decryptedKey;
                 } catch (Exception e) {
                     throw new RuntimeException("卡密格式错误或解密失败(Encrypted Card Key Required)");
                 }
            }

            // 5. Use Card
            String ipAddress = request.getRemoteAddr();
            String deviceId = "custom_api"; 

            Card card = cardService.useCard(cardKey, deviceId, ipAddress, apiKey.getId());
            
            // 6. Construct Custom Response (Success)
            return buildCustomResponse(config, card, "success", "验证成功");

        } catch (Exception e) {
            // Handle exceptions using custom response format if possible
            if (config != null) {
                String statusKey = mapExceptionToStatusKey(e.getMessage());
                String message = e.getMessage();
                // For "Card not found", message might be "卡密不存在"
                // Try to build response with null card
                return buildCustomResponse(config, null, statusKey, message);
            }
            
            // Fallback for critical errors (no config)
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
    
    private String mapExceptionToStatusKey(String message) {
        if (message == null) return "error";
        if (message.contains("卡密不存在")) return "not_found";
        if (message.contains("卡密已过期")) return "expired";
        if (message.contains("卡密已停用") || message.contains("已使用") || message.contains("无法使用")) return "used";
        if (message.contains("次数已用尽")) return "no_count";
        return "error";
    }

    private ResponseEntity<Map<String, Object>> buildCustomResponse(Map<String, Object> config, Card card, String statusKey, String message) {
        List<Map<String, String>> responseConfig = (List<Map<String, String>>) config.get("response");
        List<Map<String, String>> statusCodes = (List<Map<String, String>>) config.get("statusCodes");
        
        // Find status code value
        String statusCodeValue = "200"; // Default success
        if ("success".equals(statusKey)) {
             statusCodeValue = "200"; 
        } else {
             statusCodeValue = "400"; // Default error
        }
        
        if (statusCodes != null) {
            for (Map<String, String> sc : statusCodes) {
                if (statusKey.equals(sc.get("key"))) {
                    statusCodeValue = sc.get("value");
                    break;
                }
            }
        }

        if (responseConfig == null || responseConfig.isEmpty()) {
             // Default fallback if no custom response configured but we are in this method
             boolean isSuccess = "success".equals(statusKey);
             return ResponseEntity.status(isSuccess ? 200 : 400)
                     .body(Map.of("success", isSuccess, "message", message));
        }
        
        Map<String, Object> responseMap = new LinkedHashMap<>();
        for (Map<String, String> respItem : responseConfig) {
            String key = respItem.get("key");
            String type = respItem.get("type"); // "fixed" or "variable"
            String value = respItem.get("value");
            
            if (key == null || key.isEmpty()) continue;
            
            if ("fixed".equals(type)) {
                responseMap.put(key, value);
            } else if ("variable".equals(type)) {
                Object varValue = resolveVariable(value, card, statusCodeValue, message, "success".equals(statusKey));
                responseMap.put(key, varValue);
            }
        }

        // Always return 200 OK HTTP status, but with custom body codes?
        // Or should we map HTTP status too? Usually custom JSON APIs return 200 with internal error codes.
        return ResponseEntity.ok(responseMap);
    }
    
    private Object resolveVariable(String varName, Card card, String statusCode, String message, boolean isSuccess) {
        switch (varName) {
            case "status_code":
                return statusCode;
            case "message":
                return message;
            case "success":
                return isSuccess;
            // Card related fields (only valid if card exists)
            case "remaining_time":
                if (card == null) return "0秒";
                if ("time".equals(card.getCardType()) && card.getExpireTime() != null) {
                    long seconds = Duration.between(LocalDateTime.now(), card.getExpireTime()).getSeconds();
                    if (seconds <= 0) return "0秒";
                    
                    long days = seconds / (24 * 3600);
                    long hours = (seconds % (24 * 3600)) / 3600;
                    long minutes = (seconds % 3600) / 60;
                    
                    StringBuilder sb = new StringBuilder();
                    if (days > 0) sb.append(days).append("天");
                    if (hours > 0) sb.append(hours).append("小时");
                    if (minutes > 0) sb.append(minutes).append("分钟");
                    if (sb.length() == 0) sb.append("少于1分钟");
                    
                    return sb.toString();
                }
                return "0秒";
            case "remaining_count":
                if (card == null) return "0次";
                if ("count".equals(card.getCardType())) {
                     return (card.getRemainingCount() != null ? card.getRemainingCount() : 0) + "次";
                }
                return "不限次数";
            case "card_key":
                return card != null ? card.getCardKey() : "";
            case "expire_time":
                if (card != null && card.getExpireTime() != null) {
                    return card.getExpireTime().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                }
                return "永久有效";
            case "card_type":
                if (card == null) return "";
                return "time".equals(card.getCardType()) ? "时间卡" : "次数卡";
            case "card_status":
                if (card == null) return "no";
                return card.getStatus() == 1 ? "yes" : "no";
            default:
                return null;
        }
    }
}
