package org.xxg.backend.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.xxg.backend.backend.entity.ApiKey;
import org.xxg.backend.backend.entity.User;
import org.xxg.backend.backend.mapper.ApiKeyMapper;

import java.util.List;
import java.util.UUID;

@Service
public class ApiKeyService {

    private final ApiKeyMapper apiKeyMapper;

    public ApiKeyService(ApiKeyMapper apiKeyMapper) {
        this.apiKeyMapper = apiKeyMapper;
    }

    public List<ApiKey> getAllApiKeys() {
        List<ApiKey> keys = apiKeyMapper.findAll();
        for (ApiKey key : keys) {
            List<User> users = apiKeyMapper.getAssignedUsers(key.getId());
            key.setAssignedUsers(users);
            key.setUserCount(users.size());
            // TODO: Count cards if needed. For now 0.
            key.setCardCount(0); 
        }
        return keys;
    }

    public ApiKey getByApiKey(String apiKey) {
        return apiKeyMapper.findByApiKey(apiKey);
    }

    @Transactional
    public void updateUsage(Long id) {
        apiKeyMapper.updateUsage(id);
    }

    @Transactional
    public ApiKey createApiKey(String name, String description, Boolean enableCardEncryption) {
        ApiKey apiKey = new ApiKey();
        apiKey.setKeyName(name); // Map input name to keyName
        apiKey.setDescription(description);
        apiKey.setEnableCardEncryption(enableCardEncryption);
        
        // Generate api_key (32 chars)
        String secret = UUID.randomUUID().toString().replace("-", ""); // 32 chars
        apiKey.setApiKey(secret);
        
        // Generate key_value (UUID)
        apiKey.setKeyValue(UUID.randomUUID().toString());
        
        // Default name
        apiKey.setName("API Key");
        
        apiKey.setStatus(1);
        
        apiKeyMapper.insert(apiKey);
        return apiKey;
    }

    @Transactional
    public void updateApiKey(Long id, String name, String description, Integer status, String webhookConfig, Boolean enableCardEncryption) {
        ApiKey apiKey = apiKeyMapper.findById(id);
        if (apiKey != null) {
            apiKey.setKeyName(name);
            apiKey.setDescription(description);
            apiKey.setStatus(status);
            apiKey.setWebhookConfig(webhookConfig);
            apiKey.setEnableCardEncryption(enableCardEncryption);
            apiKeyMapper.update(apiKey);
        }
    }

    @Transactional
    public void deleteApiKey(Long id) {
        apiKeyMapper.delete(id);
    }

    @Transactional
    public void assignUser(Long apiKeyId, Long userId) {
        // Check if already assigned
        // For simplicity, catch duplicate key exception or check first.
        // We'll rely on DB constraints or check list.
        List<User> users = apiKeyMapper.getAssignedUsers(apiKeyId);
        boolean exists = users.stream().anyMatch(u -> u.getId().equals(userId));
        if (!exists) {
            apiKeyMapper.assignUser(apiKeyId, userId);
        }
    }

    @Transactional
    public void unassignUser(Long apiKeyId, Long userId) {
        apiKeyMapper.unassignUser(apiKeyId, userId);
    }
}
