package org.xxg.backend.backend.dto;

public class LoginResponse {
    private boolean success;
    private String message;
    private Object data;

    public LoginResponse(boolean success, String message, Object data) {
        this.success = success;
        this.message = message;
        this.data = data;
    }

    public static LoginResponse success(String message, Object data) {
        return new LoginResponse(true, message, data);
    }

    public static LoginResponse error(String message) {
        return new LoginResponse(false, message, null);
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }
}
