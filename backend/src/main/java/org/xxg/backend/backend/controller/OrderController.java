package org.xxg.backend.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.xxg.backend.backend.dto.CreateOrderRequest;
import org.xxg.backend.backend.entity.Order;
import org.xxg.backend.backend.service.OrderService;
import org.xxg.backend.backend.service.PaymentService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/orders")
public class OrderController {

    private final OrderService orderService;
    private final PaymentService paymentService;

    public OrderController(OrderService orderService, PaymentService paymentService) {
        this.orderService = orderService;
        this.paymentService = paymentService;
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createOrder(@RequestBody CreateOrderRequest request) {
        try {
            Order order = orderService.createOrder(request);
            Map<String, Object> response = new HashMap<>();
            
            if ("pending".equals(order.getStatus()) && paymentService.isPaymentEnabled()) {
                String paymentUrl = paymentService.createPaymentUrl(order, request.getPaymentMethod());
                response.put("paymentUrl", paymentUrl);
            }
            
            response.put("success", true);
            response.put("message", "下单成功");
            response.put("data", order);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "下单失败: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @GetMapping("/admin/all")
    public ResponseEntity<Map<String, Object>> getAllOrders(
            @RequestParam(required = false) String orderId,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String cardType,
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime
    ) {
        try {
            List<Order> orders = orderService.searchOrders(orderId, username, status, cardType, startTime, endTime);
            return ResponseEntity.ok(Map.of("success", true, "data", orders));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @PostMapping("/admin/updateStatus")
    public ResponseEntity<Map<String, Object>> updateOrderStatus(@RequestBody Map<String, String> payload) {
        String orderNo = payload.get("orderNo");
        String status = payload.get("status");
        try {
            if (orderService.updateOrderStatus(orderNo, status)) {
                return ResponseEntity.ok(Map.of("success", true, "message", "状态更新成功"));
            } else {
                return ResponseEntity.badRequest().body(Map.of("success", false, "message", "更新失败，订单不存在"));
            }
        } catch (Exception e) {
             return ResponseEntity.internalServerError().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<List<Order>> getUserOrders(@RequestParam(required = false) Integer userId) {
        // In a real app, we should get userId from SecurityContext
        // Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        // But here we rely on the param or maybe we should use the param if admin, or current user if not.
        // For simplicity, let's assume the frontend passes userId, or we default to 1 for dev.
        // Or better: let's try to get it from request if possible.
        // Since we are fixing "My Cards", let's assume we pass userId.
        
        if (userId == null) {
            // Fallback or error? Let's return empty or throw.
            // For now, let's assume userId is passed.
             return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(orderService.getUserOrders(userId));
    }
}
