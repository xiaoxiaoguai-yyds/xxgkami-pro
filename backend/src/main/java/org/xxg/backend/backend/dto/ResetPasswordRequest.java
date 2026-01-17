package org.xxg.backend.backend.dto;

public class ResetPasswordRequest {
    private String username;
    private String email; // Optional for reset step if we trust username, but verification code is tied to email.
    // Actually, verification code is tied to email.
    // So if we find user by username, we get email, then check code for that email.
    
    private String code;
    private String password;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
