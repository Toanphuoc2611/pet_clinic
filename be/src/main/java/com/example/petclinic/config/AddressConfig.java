package com.example.petclinic.config;

import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "address")
public class AddressConfig {
    @Value("address.apiKey")
    private String apiKey;
}
