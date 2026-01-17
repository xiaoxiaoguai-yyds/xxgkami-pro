package org.xxg.backend.backend.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.xxg.backend.backend.entity.ApiKey;
import org.xxg.backend.backend.entity.Card;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Service
public class WebhookService {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final RestTemplate restTemplate = new RestTemplate();

    public void triggerWebhook(ApiKey apiKey, Card card, String clientIp) {
        if (apiKey == null || apiKey.getWebhookConfig() == null || apiKey.getWebhookConfig().isEmpty()) {
            return;
        }

        try {
            Map<String, Object> config = objectMapper.readValue(apiKey.getWebhookConfig(), new TypeReference<>() {});
            String url = (String) config.get("url");
            
            // If the URL is self-referencing (points to our own /api/custom endpoint), DO NOT trigger webhook
            // to avoid infinite loops (User calls /use -> Service calls Webhook -> /use -> Service calls Webhook...)
            // Simple check: if url contains "/api/custom/" and "/use"
            if (url != null && url.contains("/api/custom/") && url.contains("/use")) {
                System.out.println("Skipping webhook trigger: Self-referencing URL detected (" + url + ")");
                return;
            }

            String method = (String) config.get("method");
            List<Map<String, String>> params = (List<Map<String, String>>) config.get("params");

            if (url == null || url.isEmpty()) {
                return;
            }

            // Prepare variables
            Map<String, String> variables = new HashMap<>();
            variables.put("time", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            variables.put("client_ip", clientIp);
            variables.put("card_key", card.getCardKey());
            variables.put("api_key", apiKey.getApiKey());
            variables.put("remaining_time", card.getDuration() + " days"); // Or calculate exact remaining if used
            variables.put("remaining_count", String.valueOf(card.getRemainingCount()));

            // Replace variables in URL
            for (Map.Entry<String, String> entry : variables.entrySet()) {
                url = url.replace("{" + entry.getKey() + "}", entry.getValue());
            }

            // Build request data
            Map<String, String> requestData = new HashMap<>();
            if (params != null) {
                for (Map<String, String> param : params) {
                    String key = param.get("key");
                    String value = param.get("value");
                    String type = param.get("type");

                    if ("variable".equals(type)) {
                        requestData.put(key, variables.getOrDefault(value, ""));
                    } else {
                        requestData.put(key, value);
                    }
                }
            }

            // Async execution
            String targetUrl = url;
            CompletableFuture.runAsync(() -> {
                try {
                    if ("GET".equalsIgnoreCase(method)) {
                        StringBuilder query = new StringBuilder();
                        for (Map.Entry<String, String> entry : requestData.entrySet()) {
                            if (query.length() > 0) query.append("&");
                            query.append(entry.getKey()).append("=").append(entry.getValue());
                        }
                        String finalUrl = targetUrl.contains("?") ? targetUrl + "&" + query : targetUrl + "?" + query;
                        restTemplate.getForObject(finalUrl, String.class);
                    } else {
                        restTemplate.postForObject(targetUrl, requestData, String.class);
                    }
                } catch (Exception e) {
                    System.err.println("Webhook failed: " + e.getMessage());
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
