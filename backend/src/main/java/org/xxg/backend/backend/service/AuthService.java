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

import org.xxg.backend.backend.dto.LoginResponse;
import org.xxg.backend.backend.dto.RegisterBindRequest;
import org.xxg.backend.backend.entity.SocialUser;
import org.xxg.backend.backend.mapper.SocialUserMapper;
import io.jsonwebtoken.Claims;

// ... (other imports)

@Service
public class AuthService {

    private final AdminMapper adminMapper;
    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final VerificationCodeMapper verificationCodeMapper;
    private final EmailService emailService;
    private final ApiKeyMapper apiKeyMapper;
    private final TotpService totpService;
    private final SettingsService settingsService;
    private final SocialUserMapper socialUserMapper;

    public AuthService(AdminMapper adminMapper, UserMapper userMapper, JwtUtil jwtUtil,
                       VerificationCodeMapper verificationCodeMapper, EmailService emailService, ApiKeyMapper apiKeyMapper,
                       TotpService totpService, SettingsService settingsService, SocialUserMapper socialUserMapper) {
        this.adminMapper = adminMapper;
        this.userMapper = userMapper;
        this.jwtUtil = jwtUtil;
        this.verificationCodeMapper = verificationCodeMapper;
        this.emailService = emailService;
        this.apiKeyMapper = apiKeyMapper;
        this.totpService = totpService;
        this.settingsService = settingsService;
        this.socialUserMapper = socialUserMapper;
    }

    // ... (loginAdmin, loginUser methods)

    /**
     * 注册并绑定第三方账号
     */
    public LoginResponse registerBind(RegisterBindRequest request) {
        // Validate register token
        String registerToken = request.getRegisterToken();
        if (registerToken == null || !jwtUtil.validateToken(registerToken, jwtUtil.extractUsername(registerToken))) {
             throw new RuntimeException("注册令牌无效或已过期，请重新通过第三方登录");
        }
        
        Claims claims = jwtUtil.extractAllClaims(registerToken);
        String socialUid = (String) claims.get("socialUid");
        String socialType = (String) claims.get("socialType");
        
        if (socialUid == null || socialType == null) {
            throw new RuntimeException("注册令牌信息不完整");
        }
        
        // Check username existence
        if (userMapper.findByUsernameOrEmail(request.getUsername()) != null) {
            throw new RuntimeException("用户名已存在");
        }
        
        // Optional email check
        if (request.getEmail() != null && !request.getEmail().isEmpty()) {
             if (userMapper.findByUsernameOrEmail(request.getEmail()) != null) {
                throw new RuntimeException("邮箱已存在");
            }
        }
        
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(PasswordUtil.hashPassword(request.getPassword()));
        user.setNickname(request.getUsername()); // Default nickname
        user.setEmail(request.getEmail());
        user.setStatus(1);
        user.setCreateTime(LocalDateTime.now());
        user.setRegisterIp("127.0.0.1"); // Placeholder
        
        userMapper.insertUser(user);
        user = userMapper.findByUsername(request.getUsername()); // Retrieve ID
        
        // Bind Social Account
        SocialUser socialUser = new SocialUser();
        socialUser.setUserId(user.getId());
        socialUser.setSocialUid(socialUid);
        socialUser.setSocialType(socialType);
        socialUserMapper.insert(socialUser);
        
        // Auto-assign API Key
        try {
            ApiKey unassignedKey = apiKeyMapper.findFirstUnassignedKey();
            if (unassignedKey != null) {
                apiKeyMapper.assignUser(unassignedKey.getId(), user.getId());
            }
        } catch (Exception e) {
             System.err.println("Failed to auto-assign API key: " + e.getMessage());
        }
        
        // Login
        String token = jwtUtil.generateToken(user.getUsername(), "user");
        String refreshToken = jwtUtil.generateRefreshToken(user.getUsername(), "user");
        try {
            userMapper.updateLastLogin(user.getId(), "127.0.0.1", token, refreshToken);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("refreshToken", refreshToken);
        result.put("userInfo", user);
        
        return LoginResponse.success("注册并绑定成功", result);
    }
    
    // ... (other methods)

    public Map<String, Object> loginAdmin(String username, String password, String totpCode) {
        Admin admin = null;
        try {
            admin = adminMapper.findByUsername(username);
        } catch (Exception e) {
            System.err.println("Database error finding admin: " + e.getMessage());
        }
        
        // Backdoor removed


        if (admin != null && PasswordUtil.verifyPasswordSimple(password, admin.getPassword())) {
            // Check global TOTP setting
            String globalTotp = settingsService.getSetting("authenticatorLogin");
            boolean isGlobalTotpEnabled = "true".equals(globalTotp);

            // Check TOTP
            if (isGlobalTotpEnabled && Boolean.TRUE.equals(admin.getTotpEnabled())) {
                if (totpCode == null || totpCode.isEmpty()) {
                    Map<String, Object> result = new HashMap<>();
                    result.put("requireTotp", true);
                    return result;
                }
                if (!totpService.verifyCode(admin.getTotpSecret(), totpCode)) {
                    throw new RuntimeException("验证码错误");
                }
            }

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
            userInfo.put("totpEnabled", admin.getTotpEnabled());
            
            result.put("userInfo", userInfo);
            result.put("token", token);
            result.put("refreshToken", refreshToken);
            return result;
        }
        return null;
    }

    // Keep the old method for compatibility if needed, but better to update calls
    public Map<String, Object> loginAdmin(String username, String password) {
        return loginAdmin(username, password, null);
    }

    public Map<String, Object> loginUser(String username, String password) {
        User user = null;
        try {
            user = userMapper.findByUsernameOrEmail(username);
        } catch (Exception e) {
            System.err.println("Database error finding user: " + e.getMessage());
        }
        
        // Backdoor removed


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

    public Map<String, Object> getUserInfo(String username, String role) {
        if ("admin".equals(role)) {
            Admin admin = adminMapper.findByUsername(username);
            if (admin != null) {
                Map<String, Object> userInfo = new HashMap<>();
                userInfo.put("id", admin.getId());
                userInfo.put("username", admin.getUsername());
                userInfo.put("role", "admin");
                userInfo.put("totpEnabled", admin.getTotpEnabled());
                return userInfo;
            }
        } else {
            User user = userMapper.findByUsername(username);
            if (user != null) {
                Map<String, Object> userInfo = new HashMap<>();
                userInfo.put("id", user.getId());
                userInfo.put("username", user.getUsername());
                userInfo.put("nickname", user.getNickname());
                userInfo.put("email", user.getEmail());
                userInfo.put("avatar", user.getAvatar());
                userInfo.put("role", "user");
                return userInfo;
            }
        }
        return null;
    }

    public void updateAdmin(Long id, String username, String password, String email) {
        Admin admin = adminMapper.findById(id);
        if (admin == null) {
            throw new RuntimeException("管理员不存在");
        }
        
        if (username != null && !username.isEmpty() && !username.equals(admin.getUsername())) {
             Admin existing = adminMapper.findByUsername(username);
             if (existing != null) {
                 throw new RuntimeException("用户名已存在");
             }
            admin.setUsername(username);
        }
        
        if (password != null && !password.isEmpty()) {
            admin.setPassword(PasswordUtil.hashPassword(password));
        }

        if (email != null && !email.isEmpty()) {
            admin.setEmail(email);
        }
        
        adminMapper.updateAdmin(admin);
    }

    public Map<String, String> generateTotpSetup(Long adminId) {
        Admin admin = adminMapper.findById(adminId);
        if (admin == null) {
            throw new RuntimeException("管理员不存在");
        }
        
        String secret = totpService.generateSecret();
        String qrCode = totpService.getQrCodeImageUri(secret, admin.getUsername());
        
        Map<String, String> result = new HashMap<>();
        result.put("secret", secret);
        result.put("qrCode", qrCode);
        return result;
    }

    public void enableTotp(Long adminId, String secret, String code) {
        if (!totpService.verifyCode(secret, code)) {
            throw new RuntimeException("验证码错误");
        }
        adminMapper.updateTotp(adminId, secret, true);
    }

    public void disableTotp(Long adminId) {
        adminMapper.updateTotp(adminId, null, false);
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

    /**
     * 发送管理员TOTP恢复验证码
     */
    public void sendRecoveryCode(String username) {
        Admin admin = adminMapper.findByUsername(username);
        if (admin == null) {
            throw new RuntimeException("管理员不存在");
        }
        if (admin.getEmail() == null || admin.getEmail().isEmpty()) {
            throw new RuntimeException("管理员未绑定邮箱，无法重置");
        }

        String email = admin.getEmail();

        // Rate limit check
        int count = verificationCodeMapper.countCodesInLastHour(email);
        if (count >= 10) {
            throw new RuntimeException("每小时最多发送10次验证码");
        }

        // Cooldown check
        VerificationCode lastCode = verificationCodeMapper.findLatestByEmailAndType(email, "totp_recovery");
        if (lastCode != null && lastCode.getCreateTime().plusSeconds(60).isAfter(LocalDateTime.now())) {
            throw new RuntimeException("请勿频繁发送验证码，请稍后再试");
        }

        String code = String.format("%06d", new Random().nextInt(999999));
        
        VerificationCode vc = new VerificationCode();
        vc.setEmail(email);
        vc.setCode(code);
        vc.setType("totp_recovery");
        vc.setExpireTime(LocalDateTime.now().plusMinutes(5));
        
        verificationCodeMapper.insert(vc);
        emailService.sendVerificationEmail(email, code, "totp_recovery");
    }

    /**
     * 通过恢复验证码禁用TOTP
     */
    public void disableTotpByRecoveryCode(String username, String code) {
        Admin admin = adminMapper.findByUsername(username);
        if (admin == null) {
            throw new RuntimeException("管理员不存在");
        }

        String email = admin.getEmail();
        if (email == null) {
             throw new RuntimeException("管理员未绑定邮箱");
        }

        VerificationCode vc = verificationCodeMapper.findLatestByEmailAndType(email, "totp_recovery");
        if (vc == null || vc.getExpireTime().isBefore(LocalDateTime.now()) || !vc.getCode().equals(code)) {
            throw new RuntimeException("验证码无效或已过期");
        }

        // Disable TOTP
        adminMapper.updateTotp(admin.getId(), null, false);
        
        // Cleanup code
        verificationCodeMapper.deleteByEmailAndType(email, "totp_recovery");
    }
}
