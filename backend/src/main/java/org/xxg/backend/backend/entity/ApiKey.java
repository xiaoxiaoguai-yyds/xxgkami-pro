package org.xxg.backend.backend.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;
import java.util.List;

public class ApiKey {
    private Long id;
    private String keyName; // Maps to key_name (The user defined name)
    private String apiKey;  // Maps to api_key (The 32-char secret)
    private String keyValue; // Maps to key_value (The UUID)
    private String name;     // Maps to name (Default 'API Key')
    private String description;
    private Integer status; // 1: Active, 0: Inactive
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private LocalDateTime lastUseTime;
    private Integer useCount;
    
    // Transient fields for display
    private List<User> assignedUsers;
    private Integer userCount;
    private Integer cardCount;

    @JsonProperty("webhook_config")
    private String webhookConfig;

    @JsonProperty("enable_card_encryption")
    private Boolean enableCardEncryption;

    public ApiKey() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getKeyName() { return keyName; }
    public void setKeyName(String keyName) { this.keyName = keyName; }

    public String getApiKey() { return apiKey; }
    public void setApiKey(String apiKey) { this.apiKey = apiKey; }

    public String getKeyValue() { return keyValue; }
    public void setKeyValue(String keyValue) { this.keyValue = keyValue; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }

    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }

    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }

    public LocalDateTime getLastUseTime() { return lastUseTime; }
    public void setLastUseTime(LocalDateTime lastUseTime) { this.lastUseTime = lastUseTime; }

    public Integer getUseCount() { return useCount; }
    public void setUseCount(Integer useCount) { this.useCount = useCount; }

    public List<User> getAssignedUsers() { return assignedUsers; }
    public void setAssignedUsers(List<User> assignedUsers) { this.assignedUsers = assignedUsers; }
    
    public Integer getUserCount() { return userCount; }
    public void setUserCount(Integer userCount) { this.userCount = userCount; }

    public Integer getCardCount() { return cardCount; }
    public void setCardCount(Integer cardCount) { this.cardCount = cardCount; }

    public String getWebhookConfig() { return webhookConfig; }
    public void setWebhookConfig(String webhookConfig) { this.webhookConfig = webhookConfig; }

    public Boolean getEnableCardEncryption() { return enableCardEncryption; }
    public void setEnableCardEncryption(Boolean enableCardEncryption) { this.enableCardEncryption = enableCardEncryption; }
}
