package org.xxg.backend.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.dto.LoginRequest;
import org.xxg.backend.backend.dto.LoginResponse;
import org.xxg.backend.backend.dto.RegisterRequest;
import org.xxg.backend.backend.dto.ResetPasswordRequest;
import org.xxg.backend.backend.dto.TokenRefreshRequest;
import org.xxg.backend.backend.service.AuthService;

import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/refresh")
    public LoginResponse refresh(@RequestBody TokenRefreshRequest request) {
        Map<String, Object> data = authService.refreshToken(request.getRefreshToken());
        if (data != null) {
            return LoginResponse.success("刷新成功", data);
        }
        return LoginResponse.error("Refresh Token无效或已过期");
    }

    @PostMapping("/logout")
    public LoginResponse logout(@RequestBody Map<String, Object> request) {
        if (request.get("id") != null && request.get("role") != null) {
            Long userId = Long.valueOf(request.get("id").toString());
            String role = (String) request.get("role");
            authService.logout(userId, role);
            return LoginResponse.success("登出成功", null);
        }
        return LoginResponse.error("参数错误");
    }

    @PostMapping("/admin/login")
    public LoginResponse loginAdmin(@RequestBody LoginRequest request) {
        System.out.println("Login attempt for admin: " + request.getUsername() + ", password: " + request.getPassword());
        try {
            Map<String, Object> data = authService.loginAdmin(request.getUsername(), request.getPassword());
            if (data != null) {
                return LoginResponse.success("登录成功", data);
            }
            System.out.println("Login failed for admin: " + request.getUsername());
            return LoginResponse.error("用户名或密码错误");
        } catch (Exception e) {
            e.printStackTrace();
            return LoginResponse.error("系统错误: " + e.getMessage());
        }
    }

    @PostMapping("/user/login")
    public LoginResponse loginUser(@RequestBody LoginRequest request) {
        System.out.println("Login attempt for user: " + request.getUsername() + ", password: " + request.getPassword());
        try {
            Map<String, Object> data = authService.loginUser(request.getUsername(), request.getPassword());
            if (data != null) {
                return LoginResponse.success("登录成功", data);
            }
            System.out.println("Login failed for user: " + request.getUsername());
            return LoginResponse.error("用户名或密码错误");
        } catch (Exception e) {
            e.printStackTrace();
            return LoginResponse.error("系统错误: " + e.getMessage());
        }
    }

    @PostMapping("/email-code")
    public LoginResponse sendEmailCode(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String type = request.get("type");
        if (email == null || type == null) {
            return LoginResponse.error("参数错误");
        }
        try {
            authService.sendEmailCode(email, type);
            return LoginResponse.success("验证码已发送", null);
        } catch (Exception e) {
            return LoginResponse.error(e.getMessage());
        }
    }

    @PostMapping("/register")
    public LoginResponse register(@RequestBody RegisterRequest request) {
        try {
            authService.register(request);
            return LoginResponse.success("注册成功", null);
        } catch (Exception e) {
            return LoginResponse.error("注册失败: " + e.getMessage());
        }
    }

    @PostMapping("/reset-code")
    public LoginResponse sendResetCode(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String email = request.get("email");
        if (username == null || email == null) {
            return LoginResponse.error("参数错误");
        }
        try {
            authService.sendResetPasswordCode(username, email);
            return LoginResponse.success("验证码已发送", null);
        } catch (Exception e) {
            return LoginResponse.error(e.getMessage());
        }
    }

    @PostMapping("/reset-password")
    public LoginResponse resetPassword(@RequestBody ResetPasswordRequest request) {
        try {
            authService.resetPassword(request);
            return LoginResponse.success("密码重置成功", null);
        } catch (Exception e) {
            return LoginResponse.error("重置失败: " + e.getMessage());
        }
    }
}
