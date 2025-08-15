package com.example.petclinic.service;

import com.example.petclinic.config.AddressConfig;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.address.District;
import com.example.petclinic.dto.response.address.Province;
import com.example.petclinic.dto.response.address.Ward;
import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nimbusds.jose.shaded.gson.JsonArray;
import com.nimbusds.jose.shaded.gson.JsonObject;
import com.nimbusds.jose.shaded.gson.JsonParser;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.HttpEntity;
import org.apache.hc.core5.http.ParseException;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.io.IOException;

@Data
@RequiredArgsConstructor
@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AddressService {
    String API_URL = "https://online-gateway.ghn.vn/shiip/public-api";
    final AddressConfig apiKey;
    String api_key = "bbce1485-31c7-11ef-8ba9-b6fbcb92e37e";

    public ApiResponse<List<Province>> getProvince() throws IOException {
        String url = API_URL + "/master-data/province";
        HttpGet request = new HttpGet(url);
        request.addHeader("Accept", "application/json");
        request.addHeader("Token", apiKey.getApiKey());
        try (CloseableHttpClient httpClient = HttpClients.createDefault();
             CloseableHttpResponse response = httpClient.execute(request)) {
            HttpEntity entity = response.getEntity();
            if (entity != null) {
                String json = EntityUtils.toString(entity);
                ObjectMapper mapper = new ObjectMapper();
                JsonNode root = mapper.readTree(json);
                JsonNode dataNode = root.get("data");
                List<Province> provinces = new ArrayList<>();
                for (JsonNode node : dataNode) {
                    int id = node.get("ProvinceID").asInt();
                    String name = node.get("ProvinceName").asText();
                    provinces.add(new Province(id, name));
                }

                return ApiResponse.<List<Province>>builder().code(200)
                        .message("Get Province success")
                        .data(provinces)
                        .build();
            }
            return ApiResponse.<List<Province>>builder().code(400).message("Get Province failure")
                    .build();

        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
    }

    public ApiResponse<List<District>> getDistrict(int provinceId) throws IOException {
        String url = API_URL + "/master-data/district?province_id=" + provinceId;
        HttpGet request = new HttpGet(url);
        request.addHeader("Content-Type", "application/json");
        request.addHeader("Token", apiKey.getApiKey());

        try (CloseableHttpClient httpClient = HttpClients.createDefault();
             CloseableHttpResponse response = httpClient.execute(request)) {
            HttpEntity entity = response.getEntity();
            if (entity != null) {
                String json = EntityUtils.toString(entity);
                ObjectMapper mapper = new ObjectMapper();
                JsonNode root = mapper.readTree(json);
                JsonNode dataNode = root.get("data");
                List<District> districts = new ArrayList<>();
                for (JsonNode node : dataNode) {
                    int id = node.get("DistrictID").asInt();
                    int idProvince = node.get("ProvinceID").asInt();
                    String name = node.get("DistrictName").asText();
                    districts.add(new District(id,idProvince ,name));
                }

                return ApiResponse.<List<District>>builder().code(200)
                        .message("Get Province success")
                        .data(districts)
                        .build();
            }
            return ApiResponse.<List<District>>builder().code(400).message("Address district failure").build();
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
    }

    public ApiResponse<List<Ward>> getWard(int districtId) throws IOException {
        String url = API_URL + "/master-data/ward?district_id=" + districtId;
        HttpGet request = new HttpGet(url);
        request.addHeader("Content-Type", "application/json");
        request.addHeader("Token", apiKey.getApiKey());

        try (CloseableHttpClient httpClient = HttpClients.createDefault();
             CloseableHttpResponse response = httpClient.execute(request)) {
            HttpEntity entity = response.getEntity();
            if (entity != null) {
                String json = EntityUtils.toString(entity);
                ObjectMapper mapper = new ObjectMapper();
                JsonNode root = mapper.readTree(json);
                JsonNode dataNode = root.get("data");
                List<Ward> wards = new ArrayList<>();
                for (JsonNode node : dataNode) {
                    String id = node.get("WardCode").asText();
                    int districtID = node.get("DistrictID").asInt();
                    String WardName = node.get("WardName").asText();
                    wards.add(new Ward(id, districtID, WardName));
                }

                return ApiResponse.<List<Ward>>builder().code(200)
                        .message("Get Ward success")
                        .data(wards)
                        .build();
            }
            return ApiResponse.<List<Ward>>builder().code(400)
                    .message("Get Ward failure")
                    .build();
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
    }

}
