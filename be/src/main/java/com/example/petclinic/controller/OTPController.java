package com.example.petclinic.controller;

import com.example.petclinic.dto.request.account.PhoneRequest;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.service.OTPService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/send-otp")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class OTPController {
    OTPService otpService;
    @PostMapping
    public ApiResponse<Boolean> sendOtp(@RequestBody PhoneRequest request) {
        boolean otp = otpService.sendOtp(request.getEmail());
        return ApiResponse.<Boolean>builder().code(200).message("Send Otp").data(otp).build();
    }
}
