package com.example.petclinic.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "vnp")
public class VnpayConfig {
    private String TmnCode;
    private String HashSecret;
    private String Url;
    private String returnUrl;
}
