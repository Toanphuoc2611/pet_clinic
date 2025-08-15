package com.example.petclinic.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "onesignal")
public class OneSignalConfig {
    private String restAPIKey;
    private String APIUrl;
    private String AppId;
}
