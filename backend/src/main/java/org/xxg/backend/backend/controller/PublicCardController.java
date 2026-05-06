package org.xxg.backend.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.xxg.backend.backend.service.CardService;

import java.util.Map;

/**
 * 无需登录的公开卡密能力（如首页在线解绑）
 */
@RestController
@RequestMapping("/public/cards")
public class PublicCardController {

    @Autowired
    private CardService cardService;

    private String extractCardKey(Map<String, String> body) {
        if (body == null) {
            return null;
        }
        String k = body.get("card_key");
        if (k == null) {
            k = body.get("cardKey");
        }
        return k;
    }

    /**
     * 查询卡密是否已绑定机器码
     */
    @PostMapping("/machine-bind/query")
    public ResponseEntity<Map<String, Object>> queryMachineBind(@RequestBody(required = false) Map<String, String> body) {
        try {
            String cardKey = extractCardKey(body);
            Map<String, Object> result = cardService.getPublicMachineBindStatus(cardKey);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    /**
     * 解绑：清空 machine_code、device_id，并清理「同机同规格」核销记录
     */
    @PostMapping("/machine-bind/unbind")
    public ResponseEntity<Map<String, Object>> unbindMachine(@RequestBody(required = false) Map<String, String> body) {
        try {
            String cardKey = extractCardKey(body);
            cardService.publicUnbindMachine(cardKey);
            return ResponseEntity.ok(Map.of("success", true, "message", "解绑成功"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }
}
