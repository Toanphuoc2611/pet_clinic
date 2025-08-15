package com.example.petclinic.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "esms")
public class ESMSConfig {
    private String apiKey;
    private String secretKey;
    private String SMS_URL = "https://api.esms.vn/MainService.svc/json/SendMultipleMessage_V2_post_json/";
}
