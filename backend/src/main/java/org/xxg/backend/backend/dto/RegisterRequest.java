package org.xxg.backend.backend.dto;

public class RegisterRequest {
    private String username;
    private String nickname;
    private String password;
    private String email;
    private String code;
    private String phone;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}
