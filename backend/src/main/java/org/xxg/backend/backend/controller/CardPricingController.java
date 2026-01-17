package org.xxg.backend.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.entity.CardPricing;
import org.xxg.backend.backend.service.CardPricingService;

import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/pricing")
public class CardPricingController {

    private final CardPricingService cardPricingService;

    public CardPricingController(CardPricingService cardPricingService) {
        this.cardPricingService = cardPricingService;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllPricing() {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", cardPricingService.getAllPricing());
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> addPricing(@RequestBody CardPricing pricing) {
        cardPricingService.addPricing(pricing);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "添加成功");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updatePricing(@PathVariable Integer id, @RequestBody CardPricing pricing) {
        pricing.setId(id);
        cardPricingService.updatePricing(pricing);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "更新成功");
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deletePricing(@PathVariable Integer id) {
        cardPricingService.deletePricing(id);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "删除成功");
        return ResponseEntity.ok(response);
    }
}
