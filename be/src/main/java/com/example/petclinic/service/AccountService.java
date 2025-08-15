package com.example.petclinic.service;

import com.example.petclinic.config.JwtConfig;
import com.example.petclinic.dto.request.account.CreationDoctorRequest;
import com.example.petclinic.dto.request.account.PhoneRequest;
import com.example.petclinic.dto.request.account.RegisterRequest;
import com.example.petclinic.dto.request.user.UserCreationRequest;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Account;
import com.example.petclinic.entity.Role;
import com.example.petclinic.entity.User;
import com.example.petclinic.entity.UserCredit;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.mapper.UserMapper;
import com.example.petclinic.repository.AccountRepository;
import com.example.petclinic.repository.RoleRepository;
import com.example.petclinic.repository.UserRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.List;


@Data
@RequiredArgsConstructor
@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AccountService {
    AccountRepository accountRepository;
    RoleRepository roleRepository;
    UserRepository userRepository;
    UserCreditService userCreditService;
    UserMapper userMapper;
    OTPService otpService;
    JwtConfig jwtConfig;
    PushNotificationService pushNotificationService;
    public ApiResponse<User> findAccountByPhone(PhoneRequest request) {
        Account account = accountRepository
                .findByEmail(request.getEmail())
                .orElse(null);
        if (account == null) {
            return ApiResponse.<User>builder().code(200).message("User not existed").build();
        }
        return ApiResponse.<User>builder().code(200).message("User existed").data(account.getUser()).build();
    }

    private String bcryptPassword(String password) {
        PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(10);
        return passwordEncoder.encode(password);
    }

    public ApiResponse<Boolean> checkAccountExisted(String phoneNumber) {
        Account account = accountRepository.findByEmail(phoneNumber).orElse(null);
        boolean isExisted = account != null;
        return ApiResponse.<Boolean>builder().code(200).message("Success").data(isExisted).build();
    }

    public ApiResponse<Account> register(RegisterRequest request) {
        if (otpService.verifyOtp(request.getOtp(), request.getEmail()) == 0) {
            return ApiResponse.<Account>builder().code(205).message("OTP incorrect").build();
        }
        if(!isValidPassword(request.getPassword())) {
            return ApiResponse.<Account>builder().code(205).message("PASSWORD INVALID").build();
        }
        Account account = accountRepository.findByEmail(request.getEmail()).orElse(null);
        if (account != null) {
            return ApiResponse.<Account>builder().code(1002).message("Phone number is existed").build();
        }

        String password = bcryptPassword(request.getPassword());
        account = new Account();
        User user = userRepository.findByPhoneNumber(request.getPhoneNumber()).orElse(null);
        if (user == null) {
            UserCreationRequest creationRequest = new UserCreationRequest(
                    request.getFullname(), request.getBirthday(), request.getPhoneNumber(),
                    request.getEmail(),
                    request.getGender(), request.getAddress()
            );
            user = userMapper.toUser(creationRequest);
            userRepository.save(user);
        }
        userRepository.save(user);

        account.setEmail(request.getEmail());
        account.setPassword(password);
        int role_id = request.getRoleId() == 0 ? 1 : request.getRoleId();
        Role role = roleRepository.findById(role_id).orElseThrow(() -> new AppException(ErrorCode.ROLE_NOT_EXISTED));
        account.setRole(role);
        account.setUser(user);
        account.setStatus(1);
        userCreditService.createUserCredit(user);
        accountRepository.save(account);
        pushNotificationService.createUser(user.getId());
        return ApiResponse.<Account>builder().code(200).message("Created account success").data(account)
                .build();
    }

    public boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) return false;
        if (!password.matches(".*[A-Z].*")) return false;
        if (!password.matches(".*[!@#$%^&*(),.?\":{}|<>].*")) return false;

        return true;
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<Account>> getAllAccount() {
        return ApiResponse.<List<Account>>builder().message("List account").code(200).data(accountRepository.findAllByRoleIdNot(2)).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Boolean> updateStatusAccount(int id, int status) {
        Account account = accountRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        account.setStatus(status);
        accountRepository.save(account);
        return ApiResponse.<Boolean>builder().message("Account update status").code(200).data(true).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Boolean> createDoctor(CreationDoctorRequest request) {
        Account account = accountRepository.findByEmail(request.getEmail()).orElse(null);
        if (account != null) {
            return ApiResponse.<Boolean>builder().code(1002).message("email is existed").build();
        }
        account = new Account();
        UserCreationRequest creationRequest = new UserCreationRequest(
                request.getFullname(), request.getBirthday(), request.getPhoneNumber(),
                request.getEmail(),
                request.getGender(), request.getAddress()
        );
        User user = userMapper.toUser(creationRequest);
        userRepository.save(user);
        account.setStatus(1);
        Role role = roleRepository.findById(3).orElseThrow(() -> new AppException(ErrorCode.ROLE_NOT_EXISTED));
        account.setRole(role);
        account.setEmail(request.getEmail());
        account.setUser(user);
        String password = bcryptPassword("123456789");
        account.setPassword(password);
        accountRepository.save(account);
        return ApiResponse.<Boolean>builder().message("Create doctor success").code(200).data(true).build();
    }
}
