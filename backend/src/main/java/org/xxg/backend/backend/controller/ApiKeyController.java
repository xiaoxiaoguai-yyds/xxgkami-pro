package org.xxg.backend.backend.controller;

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
    public ResponseEntity<ApiKey> createApiKey(@RequestBody Map<String, String> body) {
        String name = body.get("name");
        String description = body.get("description");
        return ResponseEntity.ok(apiKeyService.createApiKey(name, description));
    }

    @PutMapping("/apikeys/{id}")
    public ResponseEntity<Void> updateApiKey(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        String name = (String) body.get("name");
        String description = (String) body.get("description");
        Integer status = body.containsKey("status") ? (Integer) body.get("status") : 1;
        String webhookConfig = (String) body.get("webhook_config");
        apiKeyService.updateApiKey(id, name, description, status, webhookConfig);
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
