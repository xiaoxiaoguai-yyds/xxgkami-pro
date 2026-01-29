package org.xxg.backend.backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import org.xxg.backend.backend.entity.User;
import org.xxg.backend.backend.mapper.UserMapper;

import org.xxg.backend.backend.util.PasswordUtil;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.xxg.backend.backend.entity.SocialUser;
import org.xxg.backend.backend.mapper.SocialUserMapper;
import org.xxg.backend.backend.util.JwtUtil;
import io.jsonwebtoken.Claims;

// ... (existing imports)

@Service
public class UserService {

    private final UserMapper userMapper;
    private final SocialUserMapper socialUserMapper;
    private final JwtUtil jwtUtil;

    @Value("${server.port:8080}")
    private String serverPort;

    public UserService(UserMapper userMapper, SocialUserMapper socialUserMapper, JwtUtil jwtUtil) {
        this.userMapper = userMapper;
        this.socialUserMapper = socialUserMapper;
        this.jwtUtil = jwtUtil;
    }

    // ... (existing methods)

    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        
        // If user has a password, verify old password
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
             if (oldPassword == null || !PasswordUtil.verifyPasswordSimple(oldPassword, user.getPassword())) {
                throw new RuntimeException("旧密码错误");
            }
        }
        
        userMapper.updatePassword(user.getUsername(), PasswordUtil.hashPassword(newPassword));
    }

    public List<SocialUser> getSocialBindings(Long userId) {
        return socialUserMapper.findByUserId(userId);
    }

    public void unbindSocial(Long userId, String socialType) {
        socialUserMapper.deleteByUserIdAndType(userId, socialType);
    }

    public void bindSocial(Long userId, String registerToken) {
        // Validate token
        if (registerToken == null || !jwtUtil.validateToken(registerToken, jwtUtil.extractUsername(registerToken))) {
             throw new RuntimeException("绑定令牌无效或已过期");
        }
        
        Claims claims = jwtUtil.extractAllClaims(registerToken);
        String socialUid = (String) claims.get("socialUid");
        String socialType = (String) claims.get("socialType");
        
        if (socialUid == null || socialType == null) {
            throw new RuntimeException("绑定令牌信息不完整");
        }
        
        // Check if already bound
        SocialUser existing = socialUserMapper.findBySocialUidAndType(socialUid, socialType);
        if (existing != null) {
            if (existing.getUserId().equals(userId)) {
                return; // Already bound to this user
            } else {
                throw new RuntimeException("该账号已被其他用户绑定");
            }
        }
        
        // Remove any existing binding for this user and type (Overwrite/Change Binding)
        socialUserMapper.deleteByUserIdAndType(userId, socialType);
        
        // Bind
        SocialUser socialUser = new SocialUser();
        socialUser.setUserId(userId);
        socialUser.setSocialUid(socialUid);
        socialUser.setSocialType(socialType);
        socialUserMapper.insert(socialUser);
    }

    public User getUserById(Long userId) {
        return userMapper.findById(userId);
    }

    public User getUserByUsername(String username) {
        return userMapper.findByUsername(username);
    }

    // Admin methods
    public Map<String, Object> getUserList(int page, int size, String keyword) {
        int offset = (page - 1) * size;
        List<User> users;
        int total;

        if (keyword != null && !keyword.trim().isEmpty()) {
            users = userMapper.searchUsers(keyword, size, offset);
            total = userMapper.countSearchUsers(keyword);
        } else {
            users = userMapper.findAll(size, offset);
            total = userMapper.countTotalUsers();
        }

        // Mask passwords
        users.forEach(u -> u.setPassword(null));

        Map<String, Object> result = new HashMap<>();
        result.put("users", users);
        result.put("total", total);
        result.put("page", page);
        result.put("size", size);
        return result;
    }

    public void createUser(User user) {
        if (userMapper.findByUsername(user.getUsername()) != null) {
            throw new RuntimeException("用户名已存在");
        }
        if (userMapper.findByEmail(user.getEmail()) != null) {
            throw new RuntimeException("邮箱已存在");
        }
        
        user.setPassword(PasswordUtil.hashPassword(user.getPassword()));
        user.setStatus(1);
        user.setEmailVerified(1); // Admin created users are verified by default
        user.setRegisterIp("admin");
        userMapper.insertUser(user);
    }

    public void updateUser(Long id, User userRequest) {
        User user = userMapper.findById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        // Check conflicts if changed
        if (userRequest.getEmail() != null && !userRequest.getEmail().equals(user.getEmail())) {
            User existing = userMapper.findByEmail(userRequest.getEmail());
            if (existing != null) throw new RuntimeException("邮箱已存在");
            user.setEmail(userRequest.getEmail());
        }
        
        if (userRequest.getNickname() != null) user.setNickname(userRequest.getNickname());
        if (userRequest.getPhone() != null) user.setPhone(userRequest.getPhone());
        if (userRequest.getStatus() != null) user.setStatus(userRequest.getStatus());
        
        // Password update via separate method usually, but allow here if provided
        if (userRequest.getPassword() != null && !userRequest.getPassword().isEmpty()) {
            userMapper.updatePasswordById(id, PasswordUtil.hashPassword(userRequest.getPassword()));
        }

        userMapper.updateUser(user);
    }

    public void deleteUser(Long id) {
        userMapper.deleteUser(id);
    }

    public void updateUserStatus(Long id, Integer status) {
        userMapper.updateStatus(id, status);
    }

    public void updateUserProfile(Long userId, String nickname, String email, String phone) {
        User user = userMapper.findById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        
        // Check if email is taken by another user
        if (email != null && !email.equals(user.getEmail())) {
            User existing = userMapper.findByEmail(email);
            if (existing != null) {
                throw new RuntimeException("邮箱已被使用");
            }
        }

        user.setNickname(nickname);
        user.setEmail(email);
        user.setPhone(phone);
        userMapper.updateUser(user);
    }

    public String uploadAvatar(Long userId, MultipartFile file) {
        try {
            // Ensure uploads directory exists
            String uploadsDir = System.getProperty("user.dir") + "/uploads/avatars/";
            File directory = new File(uploadsDir);
            if (!directory.exists()) {
                directory.mkdirs();
            }

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String filename = UUID.randomUUID().toString() + extension;
            
            // Save file
            Path filePath = Paths.get(uploadsDir + filename);
            Files.write(filePath, file.getBytes());

            // Construct full URL
            String fileUrl = ServletUriComponentsBuilder.fromCurrentContextPath()
                    .path("/uploads/avatars/")
                    .path(filename)
                    .toUriString();

            // Update user avatar in DB
            User user = userMapper.findById(userId);
            if (user != null) {
                user.setAvatar(fileUrl);
                userMapper.updateUser(user);
            }

            return fileUrl;
        } catch (IOException e) {
            throw new RuntimeException("文件上传失败: " + e.getMessage());
        }
    }
}
