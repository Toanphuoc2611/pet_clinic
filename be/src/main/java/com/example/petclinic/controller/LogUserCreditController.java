package com.example.petclinic.controller;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.LogUserCredit;
import com.example.petclinic.service.LogUserCreditService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/log_user_credits")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class LogUserCreditController {
    LogUserCreditService logUserCreditService;
    @GetMapping("/{id}")
    public ApiResponse<List<LogUserCredit>> getLogByUserId(@PathVariable String id) {
        return logUserCreditService.getLogByUserId(id);
    }
}
