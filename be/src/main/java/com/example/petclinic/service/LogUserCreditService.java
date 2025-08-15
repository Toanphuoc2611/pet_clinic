package com.example.petclinic.service;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.LogUserCredit;
import com.example.petclinic.entity.User;
import com.example.petclinic.repository.LogUserCreditRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import java.util.List;
@Data
@RequiredArgsConstructor
@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)

public class LogUserCreditService {
    LogUserCreditRepository repository;


    public void createLogUserCredit(String content, String action, int balanceCurr, int balanceAfter, User user) {
        LogUserCredit logUserCredit = new LogUserCredit();
        logUserCredit.setUser(user);
        logUserCredit.setContent(content);
        logUserCredit.setAction(action);
        logUserCredit.setBalance_after(balanceAfter);
        logUserCredit.setBalance_curr(balanceCurr);
        repository.save(logUserCredit);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<LogUserCredit>> getLogByUserId(String userId) {
        List<LogUserCredit> list = repository.getLogByUserId(userId);
        return ApiResponse.<List<LogUserCredit>>builder().code(200).message("Log user credit").data(list).build();
    }

}
