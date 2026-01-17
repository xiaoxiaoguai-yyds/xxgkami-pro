package org.xxg.backend.backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import org.xxg.backend.backend.entity.User;
import org.xxg.backend.backend.mapper.UserMapper;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
public class UserService {

    private final UserMapper userMapper;

    @Value("${server.port:8080}")
    private String serverPort;

    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public User getUserById(Long userId) {
        return userMapper.findById(userId);
    }

    public User getUserByUsername(String username) {
        return userMapper.findByUsername(username);
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
