package org.xxg.backend.backend.entity;

/**
 * 系统设置实体类
 */
public class Setting {
    private Integer id;
    private String name;
    private String value;

    public Setting() {}

    public Setting(String name, String value) {
        this.name = name;
        this.value = value;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
