package org.xxg.backend.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.xxg.backend.backend.entity.User;
import org.xxg.backend.backend.service.UserService;
import org.xxg.backend.backend.entity.SocialUser; // Import SocialUser

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof String) {
            String username = (String) authentication.getPrincipal();
            return userService.getUserByUsername(username);
        }
        return null;
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile() {
        User user = getCurrentUser();
        if (user == null) {
            return ResponseEntity.status(401).body("未登录");
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", user.getId());
        response.put("username", user.getUsername());
        response.put("nickname", user.getNickname());
        response.put("email", user.getEmail());
        response.put("phone", user.getPhone());
        response.put("avatar", user.getAvatar());
        response.put("createTime", user.getCreateTime());
        response.put("hasPassword", user.getPassword() != null && !user.getPassword().isEmpty());
        
        return ResponseEntity.ok(response);
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(@RequestBody Map<String, String> request) {
        User user = getCurrentUser();
        if (user == null) {
            return ResponseEntity.status(401).body("未登录");
        }

        try {
            userService.updateUserProfile(
                user.getId(),
                request.get("nickname"),
                request.get("email"),
                request.get("phone")
            );
            return ResponseEntity.ok(Map.of("success", true, "message", "个人信息更新成功"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @PostMapping("/password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> request) {
        User user = getCurrentUser();
        if (user == null) {
            return ResponseEntity.status(401).body("未登录");
        }
        
        try {
            userService.changePassword(user.getId(), request.get("oldPassword"), request.get("newPassword"));
            return ResponseEntity.ok(Map.of("success", true, "message", "密码修改成功"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @GetMapping("/social")
    public ResponseEntity<?> getSocialBindings() {
        User user = getCurrentUser();
        if (user == null) {
            return ResponseEntity.status(401).body("未登录");
        }
        
        try {
            return ResponseEntity.ok(Map.of("success", true, "data", userService.getSocialBindings(user.getId())));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @PostMapping("/social/bind")
    public ResponseEntity<?> bindSocial(@RequestBody Map<String, String> request) {
        User user = getCurrentUser();
        if (user == null) {
            return ResponseEntity.status(401).body("未登录");
        }
        
        try {
            userService.bindSocial(user.getId(), request.get("token"));
            return ResponseEntity.ok(Map.of("success", true, "message", "绑定成功"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @PostMapping("/social/unbind")
    public ResponseEntity<?> unbindSocial(@RequestBody Map<String, String> request) {
        User user = getCurrentUser();
        if (user == null) {
            return ResponseEntity.status(401).body("未登录");
        }
        
        try {
            userService.unbindSocial(user.getId(), request.get("type"));
            return ResponseEntity.ok(Map.of("success", true, "message", "解绑成功"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @PostMapping("/avatar")
    public ResponseEntity<?> uploadAvatar(@RequestParam("file") MultipartFile file) {
        User user = getCurrentUser();
        if (user == null) {
            return ResponseEntity.status(401).body("未登录");
        }

        try {
            String avatarUrl = userService.uploadAvatar(user.getId(), file);
            return ResponseEntity.ok(Map.of("success", true, "url", avatarUrl));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
