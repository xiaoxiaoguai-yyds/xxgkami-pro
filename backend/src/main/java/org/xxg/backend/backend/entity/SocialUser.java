package org.xxg.backend.backend.entity;

import java.time.LocalDateTime;

public class SocialUser {
    private Long id;
    private Long userId;
    private String socialUid;
    private String socialType;
    private LocalDateTime createTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getSocialUid() { return socialUid; }
    public void setSocialUid(String socialUid) { this.socialUid = socialUid; }

    public String getSocialType() { return socialType; }
    public void setSocialType(String socialType) { this.socialType = socialType; }

    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}
