package org.xxg.backend.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.entity.ApiKey;
import org.xxg.backend.backend.service.ApiKeyService;
import org.xxg.backend.backend.service.CardService;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/v1")
@CrossOrigin
public class OpenApiController {

    private final ApiKeyService apiKeyService;
    private final CardService cardService;

    public OpenApiController(ApiKeyService apiKeyService, CardService cardService) {
        this.apiKeyService = apiKeyService;
        this.cardService = cardService;
    }

    /**
     * 处理卡密使用逻辑
     */
    private ResponseEntity<Map<String, Object>> executeUseCard(
            String apiKey, String cardKey, String deviceId, String ipAddress, HttpServletRequest request
    ) {
        // Default IP if not provided
        if (ipAddress == null || ipAddress.isEmpty()) {
            ipAddress = request.getRemoteAddr();
        }

        Map<String, Object> response = new HashMap<>();

        // 1. Validate Parameters
        if (apiKey == null || apiKey.isEmpty()) {
            response.put("code", 401);
            response.put("message", "API Key is required");
            response.put("success", false);
            return ResponseEntity.status(401).body(response);
        }

        if (cardKey == null || cardKey.isEmpty()) {
            response.put("code", 400);
            response.put("message", "Card Key is required");
            response.put("success", false);
            return ResponseEntity.badRequest().body(response);
        }

        // 2. Validate API Key
        ApiKey keyEntity = apiKeyService.getByApiKey(apiKey);
        if (keyEntity == null) {
            response.put("code", 403);
            response.put("message", "Invalid API Key");
            response.put("success", false);
            return ResponseEntity.status(403).body(response);
        }

        if (keyEntity.getStatus() != 1) {
            response.put("code", 403);
            response.put("message", "API Key is disabled");
            response.put("success", false);
            return ResponseEntity.status(403).body(response);
        }

        // 3. Use Card
        try {
            cardService.useCard(cardKey, deviceId, ipAddress, keyEntity.getId());
            
            // 4. Update API Key Usage
            apiKeyService.updateUsage(keyEntity.getId());

            response.put("code", 200);
            response.put("message", "Card used successfully");
            response.put("success", true);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("code", 400);
            response.put("message", e.getMessage());
            response.put("success", false);
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * JSON POST Request
     */
    @PostMapping(value = "/use_card", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, Object>> useCardJson(
            HttpServletRequest request,
            @RequestBody Map<String, String> jsonBody
    ) {
        return executeUseCard(
            jsonBody.get("api_key"),
            jsonBody.get("card_key"),
            jsonBody.get("device_id"),
            jsonBody.get("ip_address"),
            request
        );
    }

    /**
     * GET Request or Form POST Request
     */
    @RequestMapping(value = "/use_card")
    public ResponseEntity<Map<String, Object>> useCard(
            HttpServletRequest request,
            @RequestParam(value = "api_key", required = false) String apiKey,
            @RequestParam(value = "card_key", required = false) String cardKey,
            @RequestParam(value = "device_id", required = false) String deviceId,
            @RequestParam(value = "ip_address", required = false) String ipAddress
    ) {
        return executeUseCard(apiKey, cardKey, deviceId, ipAddress, request);
    }
}
