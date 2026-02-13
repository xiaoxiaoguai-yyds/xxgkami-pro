package org.xxg.backend.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.xxg.backend.backend.entity.SocialUser;
import org.xxg.backend.backend.entity.User;
import org.xxg.backend.backend.mapper.SocialUserMapper;
import org.xxg.backend.backend.mapper.UserMapper;
import org.xxg.backend.backend.util.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;

@Service
public class OAuthService {

    private final SettingsService settingsService;
    private final SocialUserMapper socialUserMapper;
    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public OAuthService(SettingsService settingsService, SocialUserMapper socialUserMapper, UserMapper userMapper, JwtUtil jwtUtil) {
        this.settingsService = settingsService;
        this.socialUserMapper = socialUserMapper;
        this.userMapper = userMapper;
        this.jwtUtil = jwtUtil;
    }

    public String getLoginUrl(String type) {
        String oauthUrl = settingsService.getSetting("oauth_url");
        String appid = settingsService.getSetting("oauth_appid");
        String appkey = settingsService.getSetting("oauth_appkey");
        String callbackDomain = settingsService.getSetting("oauth_callback_domain");

        if (oauthUrl != null) oauthUrl = oauthUrl.trim();
        if (appid != null) appid = appid.trim();
        if (appkey != null) appkey = appkey.trim();
        if (callbackDomain != null) callbackDomain = callbackDomain.trim();
        
        System.out.println("DEBUG: Settings - oauth_url: " + oauthUrl);
        System.out.println("DEBUG: Settings - oauth_appid: " + appid);
        System.out.println("DEBUG: Settings - oauth_callback_domain (DB): " + callbackDomain);
        
        if (oauthUrl == null || oauthUrl.isEmpty()) oauthUrl = "https://baoxian18.com";
        // Remove trailing slash from oauthUrl to avoid double slashes
        if (oauthUrl.endsWith("/")) oauthUrl = oauthUrl.substring(0, oauthUrl.length() - 1);

        if (callbackDomain == null || callbackDomain.isEmpty()) {
             callbackDomain = settingsService.getSetting("site_url");
             if (callbackDomain != null) callbackDomain = callbackDomain.trim();
             System.out.println("DEBUG: Settings - site_url (Fallback): " + callbackDomain);
             if (callbackDomain == null || callbackDomain.isEmpty()) callbackDomain = "http://localhost:5173";
        }
        if (callbackDomain.endsWith("/")) callbackDomain = callbackDomain.substring(0, callbackDomain.length() - 1);
        
        // Ensure callbackDomain has protocol
        if (!callbackDomain.startsWith("http://") && !callbackDomain.startsWith("https://")) {
            // Default to http if no protocol is specified, but allow https if already present
            // In a real scenario, we might want to detect or configure this better.
            // For now, if the user input "example.com", we prepend "http://".
            // If they want https, they should input "https://example.com" or we can default to https if preferred.
            // Given the user request "support http and https", it implies we should not force http if not needed,
            // or perhaps dynamically detect? But we are generating a URL for an external service to call back.
            // The safest bet for modern web is usually https, but local dev is http.
            // Let's assume if no protocol, we prepend http:// as a safe default for IP/localhost,
            // BUT if it looks like a domain, maybe https?
            // Actually, the previous fix forced "http://".
            // If the user wants https, they should enter it in the settings.
            // But if they just entered "baoxian18.com", we forced "http://".
            // The user says "support http and https".
            // This likely means: Don't just blindly add "http://".
            // If the string starts with nothing, we still need a protocol for a valid URL.
            // Let's check if it looks like a domain that typically uses https?
            // Or better, just default to http:// if missing, as users who need https usually type it.
            // Wait, the issue might be that I hardcoded "http://" in the previous step.
            // The code `if (!callbackDomain.startsWith("http://") && !callbackDomain.startsWith("https://"))`
            // correctly checks BOTH.
            // So if the user enters "https://...", it skips the block.
            // If they enter "example.com", it enters the block and adds "http://".
            // This logic seems sound for "supporting both" by respecting user input, but providing a default.
            // UNLESS the user implies we should auto-detect or allow relative protocol `//`?
            // `//` is not valid for backend redirect construction usually.
            
            // Let's assume the user means "don't break if I entered https".
            // My previous code:
            // if (!startsWith("http://") && !startsWith("https://")) { callbackDomain = "http://" + ... }
            // This ALREADY supports https if the user typed it.
            
            // Maybe the user wants us to *prefer* https or handle cases where `http` was hardcoded elsewhere?
            // Let's look at `OAuthController.java` as well.
            
            callbackDomain = "http://" + callbackDomain;
        }
        
        System.out.println("DEBUG: Final Callback Domain: " + callbackDomain);

        String callbackUrl = callbackDomain + "/api/oauth/callback";
        System.out.println("DEBUG: Generated Callback URL: " + callbackUrl);

        // Generate state to match PHP SDK behavior
        String state = UUID.randomUUID().toString().replace("-", "");

        try {
            // Build parameters map exactly like PHP SDK
            Map<String, String> params = new HashMap<>();
            params.put("act", "login");
            params.put("appid", appid);
            params.put("appkey", appkey);
            params.put("type", type);
            params.put("redirect_uri", callbackUrl);
            params.put("state", state);

            // Construct query string manually to ensure correct encoding
            StringBuilder queryString = new StringBuilder();
            for (Map.Entry<String, String> entry : params.entrySet()) {
                if (queryString.length() > 0) queryString.append("&");
                queryString.append(java.net.URLEncoder.encode(entry.getKey(), "UTF-8"))
                           .append("=")
                           .append(java.net.URLEncoder.encode(entry.getValue(), "UTF-8"));
            }

            String requestUrlStr = oauthUrl + "/connect.php?" + queryString.toString();
            System.out.println("DEBUG: Full OAuth Request URL: " + requestUrlStr);

            HttpHeaders headers = new HttpHeaders();
            headers.set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
            HttpEntity<String> entity = new HttpEntity<>("parameters", headers);

            // IMPORTANT: Use URI object to prevent RestTemplate from double-encoding the URL parameters
            // RestTemplate(String url) automatically encodes the URL, but we already manually encoded params above.
            java.net.URI uri = new java.net.URI(requestUrlStr);

            ResponseEntity<String> responseEntity = restTemplate.exchange(uri, HttpMethod.GET, entity, String.class);
            String response = responseEntity.getBody();
            
            System.out.println("OAuth Request URL: " + requestUrlStr);
            System.out.println("OAuth Response: " + response);

            if (response == null || response.isEmpty()) {
                throw new RuntimeException("Empty response from OAuth provider");
            }

            Map<String, Object> data = objectMapper.readValue(response, Map.class);
            
            if (data.containsKey("code") && (Integer)data.get("code") == 0) {
                return (String) data.get("url");
            } else {
                throw new RuntimeException("Failed to get login URL: " + data.get("msg") + 
                    " [DEBUG: callbackUrl=" + callbackUrl + ", requestUrl=" + requestUrlStr + "]");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("OAuth Error: " + e.getMessage());
        }
    }

    public Map<String, Object> handleCallback(String type, String code) {
        String oauthUrl = settingsService.getSetting("oauth_url");
        String appid = settingsService.getSetting("oauth_appid");
        String appkey = settingsService.getSetting("oauth_appkey");
        
        if (oauthUrl == null || oauthUrl.isEmpty()) oauthUrl = "https://baoxian18.com";
        // Remove trailing slash from oauthUrl
        if (oauthUrl.endsWith("/")) oauthUrl = oauthUrl.substring(0, oauthUrl.length() - 1);

        try {
            // Build parameters map exactly like PHP SDK's callback() method
            Map<String, String> params = new HashMap<>();
            params.put("act", "callback");
            params.put("appid", appid);
            params.put("appkey", appkey);
            params.put("code", code);

            StringBuilder queryString = new StringBuilder();
            for (Map.Entry<String, String> entry : params.entrySet()) {
                if (queryString.length() > 0) queryString.append("&");
                queryString.append(java.net.URLEncoder.encode(entry.getKey(), "UTF-8"))
                           .append("=")
                           .append(java.net.URLEncoder.encode(entry.getValue(), "UTF-8"));
            }

            String url = oauthUrl + "/connect.php?" + queryString.toString();
            
            String response = restTemplate.getForObject(url, String.class);
            Map<String, Object> data = objectMapper.readValue(response, Map.class);
            
            if ((Integer)data.get("code") != 0) {
                throw new RuntimeException("OAuth login failed: " + data.get("msg"));
            }

            String socialUid = (String) data.get("social_uid");
            String nickname = (String) data.get("nickname");
            // String faceimg = (String) data.get("faceimg");

            // Check if bound
            SocialUser socialUser = socialUserMapper.findBySocialUidAndType(socialUid, type);
            User user = null;

            if (socialUser != null) {
                user = userMapper.findById(socialUser.getUserId());
                if (user == null) {
                    socialUserMapper.deleteById(socialUser.getId());
                    socialUser = null;
                }
            }

            if (socialUser == null) {
                // Not bound, check if we need to register
                // Instead of auto-registering, we should return a special "unbound" status 
                // BUT user requested: "如果没有则跳转到注册页面进行注册... 注册成功后加上登录返回的数据一起写入数据库"
                
                // This means the OAuth flow should NOT finish with a login token yet if the user is not found.
                // It should return the OAuth data to the frontend so the frontend can show the register form.
                
                // However, security-wise, we shouldn't pass raw socialUid to frontend.
                // We should probably create a temporary "Bind Token" or just register a temporary user?
                
                // Let's re-read the requirement: "如果没有则跳转到注册页面进行注册，注册成功后加上登录返回的数据一起写入数据库"
                
                // This implies a flow:
                // 1. OAuth Callback -> Backend
                // 2. Backend sees no user -> Returns { needRegister: true, socialData: encrypted_or_session_key }
                // 3. Frontend sees needRegister -> Shows Register Form
                // 4. User fills form -> Frontend calls /api/auth/register-bind with form data + socialData
                
                // Implementation:
                // We can cache the social info in a temporary token (JWT) with a short expiration and scope "register".
                
                String registerToken = jwtUtil.generateToken(socialUid, "register"); // Use socialUid as subject
                // We might need to store type/nickname/faceimg too.
                // JWT claims are good for this.
                
                Map<String, Object> claims = new HashMap<>();
                claims.put("socialUid", socialUid);
                claims.put("socialType", type);
                claims.put("nickname", nickname);
                // claims.put("faceimg", faceimg);
                
                String tempToken = jwtUtil.generateCustomToken(claims, "register", 600); // 10 mins
                
                Map<String, Object> result = new HashMap<>();
                result.put("needRegister", true);
                result.put("registerToken", tempToken);
                result.put("nickname", nickname);
                // result.put("faceimg", faceimg);
                
                return result;

            }

            // Login (Existing user)
            String token = jwtUtil.generateToken(user.getUsername(), "user");
            String refreshToken = jwtUtil.generateRefreshToken(user.getUsername(), "user");
            userMapper.updateLastLogin(user.getId(), "127.0.0.1", token, refreshToken);

            Map<String, Object> result = new HashMap<>();
            result.put("token", token);
            result.put("refreshToken", refreshToken);
            result.put("userInfo", user);
            
            return result;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("OAuth Error: " + e.getMessage());
        }
    }
}
