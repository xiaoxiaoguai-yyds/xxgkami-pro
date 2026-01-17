package org.xxg.backend.backend.controller;

import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
public class WebhookTestController {

    @GetMapping("/callback")
    public String handleGetCallback(@RequestParam Map<String, String> params) {
        System.out.println("Received Webhook GET callback: " + params);
        return "Webhook GET callback received successfully. Params: " + params;
    }

    @PostMapping("/callback")
    public String handlePostCallback(@RequestBody(required = false) Map<String, Object> body, @RequestParam Map<String, String> params) {
        System.out.println("Received Webhook POST callback. Body: " + body + ", Params: " + params);
        return "Webhook POST callback received successfully.";
    }
}
