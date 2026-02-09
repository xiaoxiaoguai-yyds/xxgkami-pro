package org.xxg.backend.backend.util;

import org.springframework.stereotype.Component;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.net.URLDecoder;
import java.net.URLEncoder;

@Component
public class CustomCardObfuscator {

    /**
     * 混淆（加密）卡密
     * 算法：
     * 1. URL 编码
     * 2. 字符串反转
     * 3. Base64 编码
     * 4. 替换字符: 'e' -> '*', 'U' -> '-'
     */
    public String obfuscate(String rawKey) {
        if (rawKey == null || rawKey.isEmpty()) {
            return rawKey;
        }
        try {
            String encoded = URLEncoder.encode(rawKey, StandardCharsets.UTF_8.toString());
            String reversed = new StringBuilder(encoded).reverse().toString();
            String base64 = Base64.getEncoder().encodeToString(reversed.getBytes(StandardCharsets.UTF_8));
            return base64.replace('e', '*').replace('U', '-');
        } catch (Exception e) {
            throw new RuntimeException("Card obfuscation failed", e);
        }
    }

    /**
     * 还原（解密）卡密
     */
    public String deobfuscate(String encryptedKey) {
        if (encryptedKey == null || encryptedKey.isEmpty()) {
            return encryptedKey;
        }
        try {
            String restoredChars = encryptedKey.replace('*', 'e').replace('-', 'U');
            byte[] decodedBytes = Base64.getDecoder().decode(restoredChars);
            String reversed = new String(decodedBytes, StandardCharsets.UTF_8);
            String encoded = new StringBuilder(reversed).reverse().toString();
            return URLDecoder.decode(encoded, StandardCharsets.UTF_8.toString());
        } catch (Exception e) {
            // 解密失败通常意味着格式不匹配，返回 null 或抛出异常供上层处理
            throw new RuntimeException("无效的加密卡密格式");
        }
    }
}
