package com.example.petclinic.controller;

import com.example.petclinic.dto.request.user.UserCreationRequest;
import com.example.petclinic.dto.request.user.UserUpdatedRequest;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.admin.user.UserResponse;
import com.example.petclinic.entity.User;
import com.example.petclinic.service.UserService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.text.ParseException;
import java.util.List;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@CrossOrigin("*")
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class UserController {
    UserService userService;
    @PostMapping
    public ApiResponse<User> createUser(@RequestBody UserCreationRequest request) {
        return userService.createUser(request);
    }

    @GetMapping("/user")
    public ApiResponse<User> getUser() throws ParseException {
        return userService.getUser();
    }

    @PutMapping("/user")
    public ApiResponse<User> updateUser(@RequestBody UserUpdatedRequest request) {
        return userService.updateUser(request);
    }

    @GetMapping("/doctors")
    public ApiResponse<List<User>> getListDoctor() {
        return userService.getListDoctor();
    }

    @GetMapping("/admin/user")
    public ApiResponse<List<UserResponse>> getListUser() {
        return userService.getListUsers();
    }

    @GetMapping("/admin/user/count")
    public ApiResponse<Integer> totalUsers() {
        return userService.totalUsers();
    }

    @GetMapping("search")
    public ApiResponse<List<User>> searchUser(@RequestParam String query) {
        return userService.searchUser(query);
    }
}
