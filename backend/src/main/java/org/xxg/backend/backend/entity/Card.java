package org.xxg.backend.backend.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

/**
 * 卡密实体类
 */
public class Card {
    private Long id;
    
    @JsonProperty("card_key")
    private String cardKey;
    
    @JsonProperty("encrypted_key")
    private String encryptedKey;
    
    private Integer status; // 0:未使用 1:已使用 2:已停用
    
    @JsonProperty("create_time")
    private LocalDateTime createTime;
    
    @JsonProperty("use_time")
    private LocalDateTime useTime;
    
    @JsonProperty("expire_time")
    private LocalDateTime expireTime;
    
    private Integer duration;
    
    @JsonProperty("verify_method")
    private String verifyMethod;
    
    @JsonProperty("allow_reverify")
    private Integer allowReverify;
    
    @JsonProperty("device_id")
    private String deviceId;
    
    @JsonProperty("ip_address")
    private String ipAddress;
    
    @JsonProperty("encryption_type")
    private String encryptionType;
    
    @JsonProperty("card_type")
    private String cardType;
    
    @JsonProperty("total_count")
    private Integer totalCount;
    
    @JsonProperty("remaining_count")
    private Integer remainingCount;
    
    @JsonProperty("creator_type")
    private String creatorType;
    
    @JsonProperty("creator_id")
    private Long creatorId;
    
    @JsonProperty("creator_name")
    private String creatorName;

    @JsonProperty("api_key_id")
    private Long apiKeyId;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCardKey() { return cardKey; }
    public void setCardKey(String cardKey) { this.cardKey = cardKey; }

    public String getEncryptedKey() { return encryptedKey; }
    public void setEncryptedKey(String encryptedKey) { this.encryptedKey = encryptedKey; }

    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }

    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }

    public LocalDateTime getUseTime() { return useTime; }
    public void setUseTime(LocalDateTime useTime) { this.useTime = useTime; }

    public LocalDateTime getExpireTime() { return expireTime; }
    public void setExpireTime(LocalDateTime expireTime) { this.expireTime = expireTime; }

    public Integer getDuration() { return duration; }
    public void setDuration(Integer duration) { this.duration = duration; }

    public String getVerifyMethod() { return verifyMethod; }
    public void setVerifyMethod(String verifyMethod) { this.verifyMethod = verifyMethod; }

    public Integer getAllowReverify() { return allowReverify; }
    public void setAllowReverify(Integer allowReverify) { this.allowReverify = allowReverify; }

    public String getDeviceId() { return deviceId; }
    public void setDeviceId(String deviceId) { this.deviceId = deviceId; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public String getEncryptionType() { return encryptionType; }
    public void setEncryptionType(String encryptionType) { this.encryptionType = encryptionType; }

    public String getCardType() { return cardType; }
    public void setCardType(String cardType) { this.cardType = cardType; }

    public Integer getTotalCount() { return totalCount; }
    public void setTotalCount(Integer totalCount) { this.totalCount = totalCount; }

    public Integer getRemainingCount() { return remainingCount; }
    public void setRemainingCount(Integer remainingCount) { this.remainingCount = remainingCount; }

    public String getCreatorType() { return creatorType; }
    public void setCreatorType(String creatorType) { this.creatorType = creatorType; }

    public Long getCreatorId() { return creatorId; }
    public void setCreatorId(Long creatorId) { this.creatorId = creatorId; }

    public String getCreatorName() { return creatorName; }
    public void setCreatorName(String creatorName) { this.creatorName = creatorName; }

    public Long getApiKeyId() { return apiKeyId; }
    public void setApiKeyId(Long apiKeyId) { this.apiKeyId = apiKeyId; }
}
