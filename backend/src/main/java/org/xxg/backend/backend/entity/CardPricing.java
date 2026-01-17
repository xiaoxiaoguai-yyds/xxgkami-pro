package org.xxg.backend.backend.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class CardPricing {
    private Integer id;
    
    // 'time' or 'count'
    private String type;
    
    // duration (days) or count
    private Integer value;
    
    private BigDecimal price;
    
    // e.g., "7天时间卡"
    private String description;
    
    @JsonProperty("create_time")
    private LocalDateTime createTime;
    
    @JsonProperty("update_time")
    private LocalDateTime updateTime;

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Integer getValue() { return value; }
    public void setValue(Integer value) { this.value = value; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }

    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }
}
