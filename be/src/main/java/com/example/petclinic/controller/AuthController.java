package com.example.petclinic.controller;

import com.example.petclinic.dto.request.auth.LoginRequest;
import com.example.petclinic.dto.request.auth.LogoutRequest;
import com.example.petclinic.dto.request.auth.RefreshToken;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.auth.TokenResponse;
import com.example.petclinic.service.AuthService;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.nimbusds.jose.JOSEException;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.text.ParseException;

@RestController
@RequestMapping("/auth")
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AuthController {
    AuthService authService;
    @PostMapping("/login")
    public ApiResponse<TokenResponse> login(@RequestBody LoginRequest request) {
        return  authService.login(request);
    }

    @PostMapping("/logout")
    public void logout(@RequestBody LogoutRequest request) throws ParseException {
         authService.logout(request);
    }

//    @PostMapping("/refresh-token")
//    public ApiResponse<TokenResponse> refreshToken(@RequestBody RefreshToken refresh) throws ParseException, JOSEException {
//        return authService.refreshToken(refresh);
//    }
}