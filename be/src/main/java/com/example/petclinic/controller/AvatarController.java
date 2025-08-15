package com.example.petclinic.controller;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.service.AvatarService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/upload")
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@RequiredArgsConstructor
public class AvatarController {
    AvatarService avatarService;

    @PutMapping("/avatar/user")
    public ApiResponse<Map<String, String>> uploadAvatarUser(@RequestParam("file") MultipartFile file) {
        return avatarService.uploadAvatarUser(file);
    }

    @PutMapping("/avatar/pet")
    public ApiResponse<Map<String, String>> uploadAvatarPet(@RequestParam("file") MultipartFile file, @RequestParam String id) {
        return avatarService.uploadAvatarPet(file, id);
    }

}
