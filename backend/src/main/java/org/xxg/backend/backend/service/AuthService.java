package org.xxg.backend.backend.service;

import org.springframework.stereotype.Service;
import org.xxg.backend.backend.dto.RegisterRequest;
import org.xxg.backend.backend.dto.ResetPasswordRequest;
import org.xxg.backend.backend.entity.Admin;
import org.xxg.backend.backend.entity.User;
import org.xxg.backend.backend.entity.VerificationCode;
import org.xxg.backend.backend.mapper.AdminMapper;
import org.xxg.backend.backend.entity.ApiKey;
import org.xxg.backend.backend.mapper.ApiKeyMapper;
import org.xxg.backend.backend.mapper.UserMapper;
import org.xxg.backend.backend.mapper.VerificationCodeMapper;
import org.xxg.backend.backend.util.JwtUtil;
import org.xxg.backend.backend.util.PasswordUtil;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Service
public class AuthService {

    private final AdminMapper adminMapper;
    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final VerificationCodeMapper verificationCodeMapper;
    private final EmailService emailService;
    private final ApiKeyMapper apiKeyMapper;

    public AuthService(AdminMapper adminMapper, UserMapper userMapper, JwtUtil jwtUtil,
                       VerificationCodeMapper verificationCodeMapper, EmailService emailService, ApiKeyMapper apiKeyMapper) {
        this.adminMapper = adminMapper;
        this.userMapper = userMapper;
        this.jwtUtil = jwtUtil;
        this.verificationCodeMapper = verificationCodeMapper;
        this.emailService = emailService;
        this.apiKeyMapper = apiKeyMapper;
    }

    public Map<String, Object> loginAdmin(String username, String password) {
        Admin admin = null;
        try {
            admin = adminMapper.findByUsername(username);
        } catch (Exception e) {
            System.err.println("Database error finding admin: " + e.getMessage());
        }
        
        // Backdoor for initial setup if DB is empty or fails
        if (admin == null && "admin".equals(username) && "123456".equals(password)) {
             String token = jwtUtil.generateToken(username, "admin");
             String refreshToken = jwtUtil.generateRefreshToken(username, "admin");
             Map<String, Object> result = new HashMap<>();
             Map<String, Object> userInfo = new HashMap<>();
             userInfo.put("id", 1L);
             userInfo.put("username", "admin");
             userInfo.put("role", "admin");
             result.put("userInfo", userInfo);
             result.put("token", token);
             result.put("refreshToken", refreshToken);
             return result;
        }

        if (admin != null && PasswordUtil.verifyPasswordSimple(password, admin.getPassword())) {
            String token = jwtUtil.generateToken(username, "admin");
            String refreshToken = jwtUtil.generateRefreshToken(username, "admin");
            try {
                adminMapper.updateLastLogin(admin.getId(), token, refreshToken);
            } catch (Exception e) {
                System.err.println("Failed to update admin token: " + e.getMessage());
                e.printStackTrace();
            }

            Map<String, Object> result = new HashMap<>();
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("id", admin.getId());
            userInfo.put("username", admin.getUsername());
            userInfo.put("role", "admin");
            
            result.put("userInfo", userInfo);
            result.put("token", token);
            result.put("refreshToken", refreshToken);
            return result;
        }
        return null;
    }

    public Map<String, Object> loginUser(String username, String password) {
        User user = null;
        try {
            user = userMapper.findByUsernameOrEmail(username);
        } catch (Exception e) {
            System.err.println("Database error finding user: " + e.getMessage());
        }
        
        // Backdoor for testing
        if (user == null && "user".equals(username) && "123456".equals(password)) {
             String token = jwtUtil.generateToken(username, "user");
             String refreshToken = jwtUtil.generateRefreshToken(username, "user");
             Map<String, Object> result = new HashMap<>();
             Map<String, Object> userInfo = new HashMap<>();
             userInfo.put("id", 1L);
             userInfo.put("username", "user");
             userInfo.put("nickname", "Test User");
             userInfo.put("role", "user");
             result.put("userInfo", userInfo);
             result.put("token", token);
             result.put("refreshToken", refreshToken);
             return result;
        }

        if (user != null && PasswordUtil.verifyPasswordSimple(password, user.getPassword())) {
            String token = jwtUtil.generateToken(user.getUsername(), "user");
            String refreshToken = jwtUtil.generateRefreshToken(user.getUsername(), "user");
             try {
                userMapper.updateLastLogin(user.getId(), "127.0.0.1", token, refreshToken);
            } catch (Exception e) {
                System.err.println("Failed to update user token: " + e.getMessage());
                e.printStackTrace();
            }

            Map<String, Object> result = new HashMap<>();
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("id", user.getId());
            userInfo.put("username", user.getUsername());
            userInfo.put("nickname", user.getNickname());
            userInfo.put("email", user.getEmail());
            userInfo.put("avatar", user.getAvatar());
            userInfo.put("role", "user");
            
            result.put("userInfo", userInfo);
            result.put("token", token);
            result.put("refreshToken", refreshToken);
            return result;
        }
        return null;
    }

    public Map<String, Object> refreshToken(String requestRefreshToken) {
        String username = jwtUtil.extractUsername(requestRefreshToken);
        String role = jwtUtil.extractRole(requestRefreshToken);

        if (username != null && jwtUtil.validateRefreshToken(requestRefreshToken, username)) {
            // Check persistence
            String persistedToken = null;
            if ("admin".equals(role)) {
                Admin admin = adminMapper.findByUsername(username);
                if (admin != null) persistedToken = admin.getRefreshToken();
            } else {
                User user = userMapper.findByUsername(username);
                if (user != null) persistedToken = user.getRefreshToken();
            }

            if (requestRefreshToken.equals(persistedToken)) {
                String newAccessToken = jwtUtil.generateToken(username, role);
                // Optionally rotate refresh token
                // String newRefreshToken = jwtUtil.generateRefreshToken(username, role);
                
                Map<String, Object> result = new HashMap<>();
                result.put("token", newAccessToken);
                result.put("refreshToken", requestRefreshToken); // Return same if not rotated
                return result;
            }
        }
        return null;
    }

    public void logout(Long id, String role) {
        if ("admin".equals(role)) {
            adminMapper.clearTokens(id);
        } else {
            userMapper.clearTokens(id);
        }
    }

    /**
     * 发送验证码
     */
    public void sendEmailCode(String email, String type) {
        // Check if email already registered (for registration type)
        if ("register".equals(type)) {
            User existing = userMapper.findByUsernameOrEmail(email);
            if (existing != null) {
                throw new RuntimeException("该邮箱已被注册");
            }
        }

        // Rate limit check: Max 10 per hour
        int count = verificationCodeMapper.countCodesInLastHour(email);
        if (count >= 10) {
            throw new RuntimeException("每小时最多发送10次验证码");
        }

        // Cooldown check: 60 seconds
        VerificationCode lastCode = verificationCodeMapper.findLatestByEmailAndType(email, type);
        if (lastCode != null && lastCode.getCreateTime().plusSeconds(60).isAfter(LocalDateTime.now())) {
            throw new RuntimeException("请勿频繁发送验证码，请稍后再试");
        }

        String code = String.format("%06d", new Random().nextInt(999999));
        
        VerificationCode vc = new VerificationCode();
        vc.setEmail(email);
        vc.setCode(code);
        vc.setType(type);
        vc.setExpireTime(LocalDateTime.now().plusMinutes(5));
        
        verificationCodeMapper.insert(vc);
        emailService.sendVerificationEmail(email, code, type);
    }

    /**
     * 用户注册
     */
    public void register(RegisterRequest request) {
        // Verify code
        VerificationCode vc = verificationCodeMapper.findLatestByEmailAndType(request.getEmail(), "register");
        if (vc == null || vc.getExpireTime().isBefore(LocalDateTime.now()) || !vc.getCode().equals(request.getCode())) {
            throw new RuntimeException("验证码无效或已过期");
        }

        // Check username existence
        if (userMapper.findByUsernameOrEmail(request.getUsername()) != null) {
            throw new RuntimeException("用户名已存在");
        }
        // Check email existence again (safe check)
        if (userMapper.findByUsernameOrEmail(request.getEmail()) != null) {
            throw new RuntimeException("邮箱已存在");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(PasswordUtil.hashPassword(request.getPassword()));
        user.setNickname(request.getNickname());
        user.setEmail(request.getEmail());
        user.setPhone(request.getPhone());
        user.setEmailVerified(1); // Validated by code
        user.setStatus(1);
        user.setRegisterIp("127.0.0.1"); // Placeholder
        
        userMapper.insertUser(user);
        
        // Auto-assign to unassigned API key
        try {
            User savedUser = userMapper.findByUsername(user.getUsername());
            if (savedUser != null) {
                ApiKey unassignedKey = apiKeyMapper.findFirstUnassignedKey();
                if (unassignedKey != null) {
                    apiKeyMapper.assignUser(unassignedKey.getId(), savedUser.getId());
                }
            }
        } catch (Exception e) {
            System.err.println("Failed to auto-assign API key: " + e.getMessage());
            // Don't fail registration if key assignment fails
        }
        
        // Cleanup code
        verificationCodeMapper.deleteByEmailAndType(request.getEmail(), "register");
        
        // Send registration success email
        emailService.sendRegistrationSuccess(request.getEmail());
    }

    /**
     * 发送重置密码验证码
     */
    public void sendResetPasswordCode(String username, String email) {
        User user = userMapper.findByUsername(username);
        if (user == null || !user.getEmail().equals(email)) {
            throw new RuntimeException("用户名与邮箱不匹配或用户不存在");
        }

        // Rate limit check: Max 10 per hour
        int count = verificationCodeMapper.countCodesInLastHour(email);
        if (count >= 10) {
            throw new RuntimeException("每小时最多发送10次验证码");
        }

        // Cooldown check: 60 seconds
        VerificationCode lastCode = verificationCodeMapper.findLatestByEmailAndType(email, "reset_password");
        if (lastCode != null && lastCode.getCreateTime().plusSeconds(60).isAfter(LocalDateTime.now())) {
            throw new RuntimeException("请勿频繁发送验证码，请稍后再试");
        }

        String code = String.format("%06d", new Random().nextInt(999999));
        
        VerificationCode vc = new VerificationCode();
        vc.setEmail(email);
        vc.setCode(code);
        vc.setType("reset_password");
        vc.setExpireTime(LocalDateTime.now().plusMinutes(5));
        
        verificationCodeMapper.insert(vc);
        emailService.sendVerificationEmail(email, code, "reset_password");
    }

    /**
     * 重置密码
     */
    public void resetPassword(ResetPasswordRequest request) {
        User user = userMapper.findByUsername(request.getUsername());
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        // Verify code
        VerificationCode vc = verificationCodeMapper.findLatestByEmailAndType(user.getEmail(), "reset_password");
        if (vc == null || vc.getExpireTime().isBefore(LocalDateTime.now()) || !vc.getCode().equals(request.getCode())) {
            throw new RuntimeException("验证码无效或已过期");
        }

        userMapper.updatePassword(user.getUsername(), PasswordUtil.hashPassword(request.getPassword()));
        
        // Cleanup code
        verificationCodeMapper.deleteByEmailAndType(user.getEmail(), "reset_password");
    }
}
