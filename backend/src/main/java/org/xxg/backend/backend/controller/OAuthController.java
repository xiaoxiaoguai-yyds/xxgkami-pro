package org.xxg.backend.backend.controller;

import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.service.OAuthService;
import org.xxg.backend.backend.service.SettingsService;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("/oauth")
public class OAuthController {

    private final OAuthService oAuthService;
    private final SettingsService settingsService;

    public OAuthController(OAuthService oAuthService, SettingsService settingsService) {
        this.oAuthService = oAuthService;
        this.settingsService = settingsService;
    }

    @GetMapping("/login/{type}")
    public void login(@PathVariable String type, HttpServletResponse response) throws IOException {
        try {
            // Set cookie to remember type, robust against provider stripping query params
            Cookie cookie = new Cookie("oauth_type", type);
            cookie.setPath("/");
            cookie.setMaxAge(300); // 5 minutes
            response.addCookie(cookie);

            String url = oAuthService.getLoginUrl(type);
            System.out.println("Redirecting to OAuth URL: " + url); // Debug log
            response.sendRedirect(url);
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.setContentType("text/plain;charset=UTF-8");
            response.getWriter().write("OAuth Login Error: " + e.getMessage());
        }
    }

    @GetMapping("/callback")
    public void callback(@RequestParam(required = false) String type, @RequestParam(required = false) String code, 
                         HttpServletRequest request, HttpServletResponse response) throws IOException {
        
        // Try to recover type from cookie if missing
        if (type == null) {
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("oauth_type".equals(cookie.getName())) {
                        type = cookie.getValue();
                        break;
                    }
                }
            }
        }

        if (type == null || code == null) {
            response.getWriter().write("Error: Missing required parameters (type or code). Type=" + type + ", Code=" + (code != null ? "received" : "missing"));
            return;
        }
        
        String callbackDomain = settingsService.getSetting("oauth_callback_domain");
        if (callbackDomain == null || callbackDomain.isEmpty()) {
            callbackDomain = "http://localhost:5173"; // Default dev
        }
        if (callbackDomain.endsWith("/")) callbackDomain = callbackDomain.substring(0, callbackDomain.length() - 1);

        try {
            Map<String, Object> result = oAuthService.handleCallback(type, code);
            
            if (result.containsKey("needRegister") && (Boolean)result.get("needRegister")) {
                 // Redirect to frontend register page with temp token
                 String registerToken = (String) result.get("registerToken");
                 String nickname = (String) result.get("nickname");
                 // Encode nickname
                 if (nickname != null) nickname = java.net.URLEncoder.encode(nickname, "UTF-8");
                 
                 String redirect = String.format("%s/oauth/callback?needRegister=true&registerToken=%s&nickname=%s", 
                     callbackDomain, registerToken, nickname != null ? nickname : "");
                 
                 response.sendRedirect(redirect);
                 return;
            }

            String token = (String) result.get("token");
            String refreshToken = (String) result.get("refreshToken");
            
            String redirect = String.format("%s/oauth/callback?token=%s&refreshToken=%s", callbackDomain, token, refreshToken);
            
            response.sendRedirect(redirect);
        } catch (Exception e) {
            response.getWriter().write("Login failed: " + e.getMessage());
        }
    }
}
