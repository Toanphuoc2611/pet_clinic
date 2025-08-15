package com.example.petclinic.controller;

import com.example.petclinic.dto.request.account.CreationDoctorRequest;
import com.example.petclinic.dto.request.account.PhoneRequest;
import com.example.petclinic.dto.request.account.RegisterRequest;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Account;
import com.example.petclinic.entity.User;
import com.example.petclinic.service.AccountService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/account")
@RequiredArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AccountController {
    AccountService accountService;

    @GetMapping
    public ApiResponse<User> findAccountByPhone(@RequestBody PhoneRequest request) {
        return accountService.findAccountByPhone(request);
    }

    @PostMapping("/register")
    public ApiResponse<Account> register(@RequestBody RegisterRequest request) {
        return accountService.register(request);
    }

    @GetMapping("/admin")
    public ApiResponse<List<Account>> getAllAccount() {
        return accountService.getAllAccount();
    }

    @PutMapping("/admin/{id}")
    public ApiResponse<Boolean> updateStatusAccount(@PathVariable String id, @RequestParam String status) {
        return accountService.updateStatusAccount(Integer.parseInt(id), Integer.parseInt(status));
    }

    @PostMapping("/admin/doctor")
    public ApiResponse<Boolean> createDoctor(@RequestBody CreationDoctorRequest request) {
        return accountService.createDoctor(request);
    }
}
