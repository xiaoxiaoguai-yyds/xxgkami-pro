package org.xxg.backend.backend.entity;

public class MaintenanceSettings {
    private Integer id;
    private Boolean enabled;
    private String content;
    private String maintenanceTime;
    private String startTime;
    private String emailSubject;
    private String emailTemplate;

    public MaintenanceSettings() {}

    public MaintenanceSettings(Integer id, Boolean enabled, String content, String maintenanceTime, String startTime, String emailSubject, String emailTemplate) {
        this.id = id;
        this.enabled = enabled;
        this.content = content;
        this.maintenanceTime = maintenanceTime;
        this.startTime = startTime;
        this.emailSubject = emailSubject;
        this.emailTemplate = emailTemplate;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Boolean getEnabled() {
        return enabled;
    }

    public void setEnabled(Boolean enabled) {
        this.enabled = enabled;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getMaintenanceTime() {
        return maintenanceTime;
    }

    public void setMaintenanceTime(String maintenanceTime) {
        this.maintenanceTime = maintenanceTime;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEmailSubject() {
        return emailSubject;
    }

    public void setEmailSubject(String emailSubject) {
        this.emailSubject = emailSubject;
    }

    public String getEmailTemplate() {
        return emailTemplate;
    }

    public void setEmailTemplate(String emailTemplate) {
        this.emailTemplate = emailTemplate;
    }
}
