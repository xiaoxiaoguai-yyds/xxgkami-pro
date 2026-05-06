package org.xxg.backend.backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.entity.ApiKey;
import org.xxg.backend.backend.entity.User;
import org.xxg.backend.backend.mapper.UserMapper;
import org.xxg.backend.backend.service.ApiKeyService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin")
@CrossOrigin
public class ApiKeyController {

    private final ApiKeyService apiKeyService;
    private final UserMapper userMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public ApiKeyController(ApiKeyService apiKeyService, UserMapper userMapper) {
        this.apiKeyService = apiKeyService;
        this.userMapper = userMapper;
    }

    @GetMapping("/apikeys")
    public ResponseEntity<?> getAllApiKeys() {
        try {
            return ResponseEntity.ok(apiKeyService.getAllApiKeys());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Map.of("error", e.getClass().getName(), "message", e.getMessage()));
        }
    }

    @PostMapping("/apikeys")
    public ResponseEntity<ApiKey> createApiKey(@RequestBody Map<String, Object> body) {
        String name = (String) body.get("name");
        String description = (String) body.get("description");
        Boolean enableCardEncryption = body.containsKey("enable_card_encryption") ? (Boolean) body.get("enable_card_encryption") : false;
        return ResponseEntity.ok(apiKeyService.createApiKey(name, description, enableCardEncryption));
    }

    @PutMapping("/apikeys/{id}")
    public ResponseEntity<Void> updateApiKey(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String name = (String) body.get("name");
        String description = (String) body.get("description");
        Integer status = body.containsKey("status") ? (Integer) body.get("status") : 1;
        Boolean enableCardEncryption = body.containsKey("enable_card_encryption") ? (Boolean) body.get("enable_card_encryption") : false;

        Boolean requireMachineCode = body.containsKey("require_machine_code")
                ? Boolean.TRUE.equals(body.get("require_machine_code")) : null;

        boolean updateSpecConfig = body.containsKey("machine_spec_once_config");
        String machineSpecOnceConfig = null;
        if (updateSpecConfig) {
            Object spec = body.get("machine_spec_once_config");
            if (spec == null) {
                machineSpecOnceConfig = null;
            } else if (spec instanceof String) {
                machineSpecOnceConfig = (String) spec;
            } else {
                try {
                    machineSpecOnceConfig = objectMapper.writeValueAsString(spec);
                } catch (Exception e) {
                    machineSpecOnceConfig = spec.toString();
                }
            }
        }

        boolean updateWebhook = body.containsKey("webhook_config");
        String webhookStr = updateWebhook ? (String) body.get("webhook_config") : null;

        apiKeyService.updateApiKey(id, name, description, status, webhookStr, enableCardEncryption,
                requireMachineCode, machineSpecOnceConfig, updateSpecConfig, updateWebhook);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/apikeys/{id}")
    public ResponseEntity<Void> deleteApiKey(@PathVariable Long id) {
        apiKeyService.deleteApiKey(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/apikeys/{id}/users")
    public ResponseEntity<Void> assignUser(@PathVariable Long id, @RequestBody Map<String, Long> body) {
        Long userId = body.get("userId");
        apiKeyService.assignUser(id, userId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/apikeys/{id}/users/{userId}")
    public ResponseEntity<Void> unassignUser(@PathVariable Long id, @PathVariable Long userId) {
        apiKeyService.unassignUser(id, userId);
        return ResponseEntity.ok().build();
    }
}
