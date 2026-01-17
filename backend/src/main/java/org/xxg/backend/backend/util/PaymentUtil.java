package org.xxg.backend.backend.util;

import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class PaymentUtil {

    public static String generateSignature(Map<String, String> params, String key) {
        List<String> keys = new ArrayList<>(params.keySet());
        Collections.sort(keys);

        StringBuilder sb = new StringBuilder();
        for (String k : keys) {
            String v = params.get(k);
            if (v != null && !v.isEmpty() && !"sign".equals(k) && !"sign_type".equals(k)) {
                sb.append(k).append("=").append(v).append("&");
            }
        }
        // Remove last &
        if (sb.length() > 0) {
            sb.setLength(sb.length() - 1);
        }
        
        // Append key
        sb.append(key);

        return md5(sb.toString());
    }

    private static String md5(String text) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(text.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("MD5 encryption failed", e);
        }
    }
}
