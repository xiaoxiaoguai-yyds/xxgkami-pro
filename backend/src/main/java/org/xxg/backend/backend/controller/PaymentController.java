package org.xxg.backend.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.entity.Order;
import org.xxg.backend.backend.service.OrderService;
import org.xxg.backend.backend.service.PaymentService;

import org.xxg.backend.backend.service.SettingsService;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/payment")
public class PaymentController {

    private final PaymentService paymentService;
    private final OrderService orderService;
    private final SettingsService settingsService;

    public PaymentController(PaymentService paymentService, OrderService orderService, SettingsService settingsService) {
        this.paymentService = paymentService;
        this.orderService = orderService;
        this.settingsService = settingsService;
    }

    @PostMapping("/pay")
    public ResponseEntity<Map<String, Object>> pay(@RequestBody Map<String, String> payload) {
        String orderNo = payload.get("orderNo");
        String paymentType = payload.get("paymentMethod"); // alipay, wxpay, etc.
        
        if (orderNo == null || paymentType == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "缺少参数"));
        }
        
        // Find order by orderNo
        // OrderService doesn't have findByOrderNo exposed publicly, let's assume we can get it or add it.
        // For now, let's iterate or add method. Adding method is better.
        Order order = orderService.getOrderByNo(orderNo);
        
        if (order == null) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", "订单不存在"));
        }
        
        try {
            String payUrl = paymentService.createPaymentUrl(order, paymentType);
            return ResponseEntity.ok(Map.of("success", true, "payUrl", payUrl));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @GetMapping("/notify")
    public String notify(HttpServletRequest request) {
        Map<String, String> params = new HashMap<>();
        request.getParameterMap().forEach((k, v) -> params.put(k, v[0]));
        
        try {
            return paymentService.handleNotify(params);
        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }
    
    @GetMapping("/return")
    public void returnUrl(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Map<String, String> params = new HashMap<>();
        request.getParameterMap().forEach((k, v) -> params.put(k, v[0]));
        
        try {
            // Try to process payment synchronously as a fallback for notify failure (especially in dev)
            paymentService.handleNotify(params);
        } catch (Exception e) {
            // Ignore errors in return url processing, just redirect
            System.err.println("Return URL processing error: " + e.getMessage());
        }
        
        // Redirect to user page
        String siteUrl = settingsService.getSetting("site_url");
        String redirectUrl;
        
        if (siteUrl != null && !siteUrl.trim().isEmpty()) {
             if (siteUrl.endsWith("/")) siteUrl = siteUrl.substring(0, siteUrl.length() - 1);
             
             // 如果配置了 site_url，优先使用不带端口的地址跳转回前端
             // 因为后端在 8080，前端在 80，直接跳转 site_url 即可回到前端
             // 但需要确保 site_url 填的是不带 8080 的域名
             // 如果用户误填了 8080，我们尝试智能修复一下
             if (siteUrl.contains(":8080")) {
                 redirectUrl = siteUrl.replace(":8080", "") + "/#/user?payment=success";
             } else {
                 redirectUrl = siteUrl + "/#/user?payment=success";
             }
        } else {
            // Fallback for local dev
            redirectUrl = "http://localhost:5173/#/user?payment=success";
        }
        
        response.sendRedirect(redirectUrl);
    }
}
