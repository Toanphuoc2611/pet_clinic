package com.example.petclinic.controller;

import com.example.petclinic.dto.request.vnpay.VnPayRequest;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.service.VnpayService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.io.UnsupportedEncodingException;
import java.util.Map;

@RestController
@RequestMapping("/vnpay")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class VnpayController {
    VnpayService vnpayService;
    @GetMapping("/callback")
    public String hello() {
        return "Hello from petclinic";
    }

    @PostMapping("/payment")
    public ApiResponse<Map<String, String>> getUrlPaymentVnpay(@RequestBody VnPayRequest request) throws UnsupportedEncodingException {
        return vnpayService.paymentVnp(request);
    }
}
