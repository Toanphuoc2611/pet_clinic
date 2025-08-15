package com.example.petclinic.service;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.User;
import com.example.petclinic.entity.UserCredit;
import com.example.petclinic.repository.UserCreditRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
public class UserCreditService {
    UserCreditRepository repository;
    LogUserCreditService logUserCreditService;

    public ApiResponse<UserCredit> getUserCredit() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        UserCredit userCredit = repository.findByUserId(userId);
        return ApiResponse.<UserCredit>builder().code(200).message("Get user credit").data(userCredit).build();
    }

    public UserCredit getUserCreditById(String userId) {
        UserCredit userCredit = repository.findByUserId(userId);
        return userCredit;
    }

    public void createUserCredit(User user) {
        UserCredit userCredit = new UserCredit();
        userCredit.setUser(user);
        userCredit.setBalance(0);
        repository.save(userCredit);
    }

    public void refundBalanceKennel(String userId, int balance, int idKennel) {
        UserCredit userCredit = repository.findByUserId(userId);
        logUserCreditService.createLogUserCredit(
                "Hoàn tiền đăt lịch lưu chuồng id" + idKennel, "Hoàn tiền",
                userCredit.getBalance(),userCredit.getBalance() + balance, userCredit.getUser());
        userCredit.setBalance(userCredit.getBalance() + balance);
        repository.save(userCredit);
    }

    public void refundBalanceAppo(String userId, int balance, int idAppo) {
        UserCredit userCredit = repository.findByUserId(userId);

        logUserCreditService.createLogUserCredit(
                "Hoàn tiền đăt lịch khám bệnh id" + idAppo, "Hoàn tiền",
                userCredit.getBalance(),userCredit.getBalance() + balance, userCredit.getUser());
        userCredit.setBalance(userCredit.getBalance() + balance);
        repository.save(userCredit);
    }

    public void paymentCreditAppo(String userId, int price, int idAppo) {
        UserCredit userCredit = repository.findByUserId(userId);
        if (userCredit.getBalance() < price) {
            if(userCredit.getBalance() > 0) {
                logUserCreditService.createLogUserCredit(
                        "Thanh toán đăt lịch khám bệnh id" + idAppo, "Thanh toán",
                        userCredit.getBalance(),0, userCredit.getUser());
            }
            userCredit.setBalance(0);
        } else {
            logUserCreditService.createLogUserCredit(
                    "Thanh toán đăt lịch khám bệnh id" + idAppo, "Thanh toán",
                    userCredit.getBalance(),userCredit.getBalance() - price, userCredit.getUser());
            userCredit.setBalance(userCredit.getBalance() - price);
        }
        repository.save(userCredit);
    }

    public void paymentCreditKennel(String userId, int price, int idKennel) {
        UserCredit userCredit = repository.findByUserId(userId);
        if (userCredit.getBalance() < price) {
            if(userCredit.getBalance() > 0) {
                logUserCreditService.createLogUserCredit(
                        "Thanh toán đăt lịch lưu chuồng id" + idKennel, "Thanh toán",
                        userCredit.getBalance(),0, userCredit.getUser());
            userCredit.setBalance(0);
            }
        }else {
            logUserCreditService.createLogUserCredit(
                    "Thanh toán đăt lịch lưu chuồng id" + idKennel, "Thanh toán",
                    userCredit.getBalance(),userCredit.getBalance() - price, userCredit.getUser());
            userCredit.setBalance(userCredit.getBalance() - price);
        }
        repository.save(userCredit);
    }
}
