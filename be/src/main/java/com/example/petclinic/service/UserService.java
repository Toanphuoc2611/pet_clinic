package com.example.petclinic.service;

import com.example.petclinic.dto.request.user.UserCreationRequest;
import com.example.petclinic.dto.request.user.UserUpdatedRequest;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.admin.user.UserResponse;
import com.example.petclinic.entity.User;
import com.example.petclinic.entity.UserCredit;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.mapper.UserMapper;
import com.example.petclinic.repository.AccountRepository;
import com.example.petclinic.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PostAuthorize;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
public class UserService {
    UserRepository userRepository;
    UserMapper userMapper;
    AccountRepository accountRepository;
    UserCreditService userCreditService;
    public ApiResponse<User> createUser(UserCreationRequest request) {
        User user = userRepository.findByPhoneNumber(request.getPhoneNumber()).orElse(null);
        if (user != null) {
            return ApiResponse.<User>builder().code(200).message("User existed").build();
        } else {
            user = userMapper.toUser(request);
            userRepository.save(user);

            return ApiResponse.<User>builder().code(200).message("User is created").data(user).build();
        }
    }

    public ApiResponse<User> getUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        User user = userRepository.findById(userId).orElseThrow(() -> new  AppException(ErrorCode.USER_NOT_EXISTED));
        return ApiResponse.<User>builder().code(200).message("success").data(user).build();
    }

    public ApiResponse<User> updateUser(UserUpdatedRequest request) {
        User user = userRepository.findById(request.getId()).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        user.setFullname(request.getFullname());
        user.setAddress(request.getAddress());
        user.setBirthday(LocalDate.parse(request.getBirthday()));
        user.setGender(request.getGender());
        userRepository.save(user);
        return ApiResponse.<User>builder().code(200).message("Update success").data(user).build();
    }


    public ApiResponse<List<User>> getListDoctor() {
        List<User> listDoctor = userRepository.findUsersByRole();
        return ApiResponse.<List<User>>builder().code(200).message("get list doctor success").data(listDoctor).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<UserResponse>> getListUsers() {
        List<User> listUsers = accountRepository.findAllUsersWithRole1OrNoAccount();
        List<UserResponse> userResponses = new ArrayList<>();
        for (User user : listUsers) {
            UserCredit userCredit = userCreditService.getUserCreditById(user.getId());
            if (userCredit != null) {
                UserResponse userResponse = new UserResponse(user, userCredit.getBalance());
                userResponses.add(userResponse);
            } else {
                UserResponse userResponse = new UserResponse(user, 0);
                userResponses.add(userResponse);
            }
        }
        return ApiResponse.<List<UserResponse>>builder().code(200).message("get list user").data(userResponses).build();
    }


    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Integer> totalUsers() {
        int totalUser = userRepository.totalUser();
        return ApiResponse.<Integer>builder().code(200).message("total users").data(totalUser).build();
    }

    @PreAuthorize("hasRole('DOCTOR')")
    public ApiResponse<List<User>> searchUser(String search) {
        List<User> listUser = userRepository.searchUsersByFullname(search);
        return ApiResponse.<List<User>>builder().code(200).message("User search").data(listUser).build();
    }
}
