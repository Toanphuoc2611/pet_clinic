package com.example.petclinic.service;

import com.example.petclinic.config.OneSignalConfig;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
public class PushNotificationService {
    OneSignalConfig oneSignalConfig;

    public static boolean sendPushNotification(String title, String message, String[] userId) {
        RestTemplate restTemplate = new RestTemplate();

        HttpHeaders headers = new HttpHeaders();
//        headers.set("Authorization", "Basic " + oneSignalConfig.getRestAPIKey());
        headers.set("Authorization", "Basic " + "os_v2_app_5ddulhmgmravfczz7bwjb3i2vqjva2cgg2jethe4fyyhy5j6z4kxvkzdqxv6tir3q67elvnhybrooxuusoig6vf2kl7v4sn34c5zpwq");
        headers.set("Content-Type", "application/json");

        Map<String, Object> payload = new HashMap<>();
//        payload.put("app_id", oneSignalConfig.getAppId());
        payload.put("contents", Map.of("en", message));
        payload.put("app_id", "e8c7459d-8664-4152-8b39-f86c90ed1aac");
        payload.put("headings", Map.of("en", title));
        payload.put("include_external_user_ids", userId);

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(payload, headers);

        ResponseEntity<String> response = restTemplate.exchange(
//                oneSignalConfig.getAPIUrl(),
                "https://onesignal.com/api/v1/notifications",
                HttpMethod.POST,
                request,
                String.class);

        return response.getStatusCode().is2xxSuccessful();
    }

    public static boolean createUser(String userId) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
//        headers.set("Authorization", "Basic " + oneSignalConfig.getRestAPIKey());
        headers.set("Authorization", "Basic " + "os_v2_app_5ddulhmgmravfczz7bwjb3i2vqjva2cgg2jethe4fyyhy5j6z4kxvkzdqxv6tir3q67elvnhybrooxuusoig6vf2kl7v4sn34c5zpwq");
        Map<String, Object> payload = new HashMap<>();
        Map<String, String> identity = new HashMap<>();
        identity.put("external_id", userId);
        payload.put("identity", identity);
        HttpEntity<Map<String, Object>> request = new HttpEntity<>(payload, headers);
//        String API_CREATE_USER = "https://api.onesignal.com/apps/" + oneSignalConfig.getAppId() + "/users";
        String API_CREATE_USER = "https://api.onesignal.com/apps/" + "e8c7459d-8664-4152-8b39-f86c90ed1aac" + "/users";
        ResponseEntity<String> response = restTemplate.exchange(
                API_CREATE_USER,
                HttpMethod.POST,
                request,
                String.class
        );
        return response.getStatusCode().is2xxSuccessful();
    }

    public static void main(String[] args) {
//        PushNotificationService.createUser("35209116-a2fa-48e5-b160-73f79c12f69a");
        PushNotificationService.sendPushNotification("Hello", "this is test", new String[] {"35209116-a2fa-48e5-b160-73f79c12f69a"});
    }
}
