package org.xxg.backend.backend.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * 密码加密工具类
 */
public class PasswordUtil {

    private static final PasswordEncoder encoder = new BCryptPasswordEncoder();

    /**
     * 使用BCrypt加密密码
     */
    public static String hashPassword(String password) {
        return encoder.encode(password);
    }

    /**
     * 验证密码
     */
    public static boolean verifyPasswordSimple(String rawPassword, String encodedPassword) {
        if (encodedPassword == null || encodedPassword.isEmpty()) return false;
        
        // 尝试BCrypt验证
        try {
            if (encoder.matches(rawPassword, encodedPassword)) {
                return true;
            }
        } catch (Exception e) {
            // 忽略格式错误
        }
        
        // 兼容明文密码（仅用于旧数据或测试）
        return rawPassword.equals(encodedPassword);
    }
}
