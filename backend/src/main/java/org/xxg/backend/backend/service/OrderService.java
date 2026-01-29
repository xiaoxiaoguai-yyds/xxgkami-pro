package org.xxg.backend.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.xxg.backend.backend.dto.CreateOrderRequest;
import org.xxg.backend.backend.entity.Card;
import org.xxg.backend.backend.entity.Order;
import org.xxg.backend.backend.entity.User;
import org.xxg.backend.backend.entity.CardPricing;
import org.xxg.backend.backend.mapper.CardMapper;
import org.xxg.backend.backend.mapper.OrderMapper;
import org.xxg.backend.backend.mapper.UserMapper;
import org.xxg.backend.backend.mapper.CardPricingMapper;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class OrderService {

    private final OrderMapper orderMapper;
    private final CardMapper cardMapper;
    private final EmailService emailService;
    private final UserMapper userMapper;
    private final CardService cardService;
    private final CardPricingMapper cardPricingMapper;

    private final SettingsService settingsService;

    public OrderService(OrderMapper orderMapper, CardMapper cardMapper, EmailService emailService, UserMapper userMapper, CardService cardService, CardPricingMapper cardPricingMapper, SettingsService settingsService) {
        this.orderMapper = orderMapper;
        this.cardMapper = cardMapper;
        this.emailService = emailService;
        this.userMapper = userMapper;
        this.cardService = cardService;
        this.cardPricingMapper = cardPricingMapper;
        this.settingsService = settingsService;
    }

    @Transactional
    public Order createOrder(CreateOrderRequest request) {
        BigDecimal unitPrice = BigDecimal.ZERO;
        int duration = 0;
        int totalCount = 0;
        
        if (request.getPricingId() != null) {
            CardPricing pricing = cardPricingMapper.findById(request.getPricingId());
            if (pricing != null) {
                unitPrice = pricing.getPrice();
                if ("time".equals(request.getCardType())) {
                    duration = pricing.getValue();
                } else {
                    totalCount = pricing.getValue();
                }
            } else {
                 unitPrice = calculateUnitPrice(request.getCardType(), request.getCardSpec());
                 int specValue = parseSpecValue(request.getCardSpec());
                 if ("time".equals(request.getCardType())) duration = specValue;
                 else totalCount = specValue;
            }
        } else {
             unitPrice = calculateUnitPrice(request.getCardType(), request.getCardSpec());
             int specValue = parseSpecValue(request.getCardSpec());
             if ("time".equals(request.getCardType())) duration = specValue;
             else totalCount = specValue;
        }

        BigDecimal totalPrice = unitPrice.multiply(BigDecimal.valueOf(request.getQuantity()));

        // Initialize order
        Order order = new Order();
        order.setOrderNo(generateOrderNo());
        order.setUserId(request.getUserId());
        order.setUsername(request.getUsername());
        order.setCardType(request.getCardType());
        order.setCardSpec(request.getCardSpec());
        order.setQuantity(request.getQuantity());
        order.setUnitPrice(unitPrice);
        order.setTotalPrice(totalPrice);
        order.setPaymentMethod(request.getPaymentMethod());
        order.setCreateTime(LocalDateTime.now());
        
        // Check if payment is enabled
        String paymentEnabled = settingsService.getSetting("payment_enabled"); 
        
        // If payment is enabled, do NOT generate cards yet.
        // Cards should only be generated upon successful payment callback.
        // Status should be "pending".
        
        String cardKeys = "";
        
        if ("true".equalsIgnoreCase(paymentEnabled)) {
            order.setStatus("pending");
            // Do NOT generate cards here
        } else {
            // Payment disabled or free/admin mode, generate immediately
            order.setStatus("completed"); // Or "pending" if manual approval? Assuming completed for now.
            
            // Create cards directly
            // Use "advanced" encryption for user purchases by default
            String creatorType = "user";
            Long creatorId = request.getUserId() != null ? Long.valueOf(request.getUserId()) : 1L;
            String creatorName = request.getUsername();
            
            List<Card> cards = cardService.createCards(request.getQuantity(), request.getCardType(), duration, totalCount, 
                                                     "web", "advanced", 1,
                                                     creatorType, creatorId, creatorName, null);
    
            // Collect card keys
            cardKeys = cards.stream().map(Card::getCardKey).collect(Collectors.joining(","));
        }

        order.setCardKeys(cardKeys); 
        
        orderMapper.insert(order);

        return order;
    }
    
    /**
     * Process successful payment and generate cards
     */
    @Transactional
    public void completeOrder(Order order) {
        if (!"pending".equals(order.getStatus())) {
            return; // Already processed
        }
        
        // Calculate duration/count again or store in order?
        // We have cardType and cardSpec in order.
        // We need to parse them again or store parameters.
        // To be safe, let's re-parse.
        int duration = 0;
        int totalCount = 0;
        int specValue = parseSpecValue(order.getCardSpec());
        if ("time".equals(order.getCardType())) duration = specValue;
        else totalCount = specValue;
        
        String creatorType = "user";
        Long creatorId = order.getUserId() != null ? Long.valueOf(order.getUserId()) : 1L;
        String creatorName = order.getUsername();
        
        List<Card> cards = cardService.createCards(order.getQuantity(), order.getCardType(), duration, totalCount, 
                                                 "web", "advanced", 1,
                                                 creatorType, creatorId, creatorName, null);

        // Collect card keys
        String cardKeys = cards.stream().map(Card::getCardKey).collect(Collectors.joining(","));
        
        // Update order
        order.setCardKeys(cardKeys);
        order.setStatus("completed");
        orderMapper.update(order); // Assuming update method exists
        
        // Send notification
        // ...
    }
    
    @Transactional
    public void completeOrder(String orderNo) {
        Order order = orderMapper.findByOrderNo(orderNo);
        if (order != null) {
            completeOrder(order);
        }
    }
    
    public List<Order> getUserOrders(Integer userId) {
        return orderMapper.findByUserId(userId);
    }

    public List<Order> getAllOrders() {
        return orderMapper.findAll();
    }

    public List<Order> searchOrders(String orderNo, String username, String status, String cardType, String startTime, String endTime) {
        return orderMapper.search(orderNo, username, status, cardType, startTime, endTime);
    }

    public boolean updateOrderStatus(String orderNo, String status) {
        return orderMapper.updateStatus(orderNo, status) > 0;
    }

    public Order getOrderByNo(String orderNo) {
        return orderMapper.findByOrderNo(orderNo);
    }

    private int parseSpecValue(String spec) {
        Pattern p = Pattern.compile("\\d+");
        Matcher m = p.matcher(spec);
        if (m.find()) {
            return Integer.parseInt(m.group());
        }
        return 0;
    }

    private String generateOrderNo() {
        return "ORD" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) + 
               (int)(Math.random() * 1000);
    }

    private BigDecimal calculateUnitPrice(String type, String spec) {
        if ("time".equals(type)) {
            if (spec.contains("7")) return new BigDecimal("9.9");
            if (spec.contains("15")) return new BigDecimal("18.8");
            if (spec.contains("30")) return new BigDecimal("35.0");
            if (spec.contains("60")) return new BigDecimal("65.0");
            if (spec.contains("90")) return new BigDecimal("90.0");
            if (spec.contains("180")) return new BigDecimal("168.0");
        } else if ("count".equals(type)) {
            if (spec.contains("50")) return new BigDecimal("12.0");
            if (spec.contains("100")) return new BigDecimal("22.0");
            if (spec.contains("200")) return new BigDecimal("40.0");
            if (spec.contains("500")) return new BigDecimal("95.0");
            if (spec.contains("1000")) return new BigDecimal("180.0");
        }
        return BigDecimal.ZERO;
    }
}
