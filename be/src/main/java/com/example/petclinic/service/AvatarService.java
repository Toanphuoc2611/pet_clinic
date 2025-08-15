package com.example.petclinic.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Pet;
import com.example.petclinic.entity.User;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.PetRepository;
import com.example.petclinic.repository.UserRepository;
import io.github.cdimascio.dotenv.Dotenv;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AvatarService {
    UserRepository userRepository;
    PetRepository petRepository;

    public ApiResponse<Map<String, String>> uploadAvatarUser(MultipartFile file) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        User user = userRepository.findById(userId).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        String url = uploadImage(file, "clinic_avatar_user");
        Map<String, String> data = new HashMap<>();
        data.put("url", url);
        user.setAvatar(url);
        userRepository.save(user);
        return ApiResponse.<Map<String, String>>builder().code(200).message("upload avatar success").data(data).build();
    }

    public ApiResponse<Map<String, String>> uploadAvatarPet(MultipartFile file, String petId) {
        Pet pet = petRepository.findById(petId).orElseThrow(() -> new AppException(ErrorCode.PET_NOT_EXISTED));
        String url = uploadImage(file, "clinic_avatar_pets");
        Map<String, String> data = new HashMap<>();
        data.put("url", url);
        pet.setAvatar(url);
        petRepository.save(pet);
        return ApiResponse.<Map<String, String>>builder().code(200).message("upload avatar success").data(data).build();
    }

    public String uploadImage(MultipartFile file, String perset) {
        try {
            Dotenv dotenv = Dotenv.load();
            Cloudinary cloudinary = new Cloudinary(dotenv.get("CLOUDINARY_URL"));
            Map<String, Object> options = ObjectUtils.asMap(
                    "upload_preset", perset
            );
            Map uploadResult = cloudinary.uploader().upload(file.getBytes(), options);
            String url = uploadResult.get("secure_url").toString();
            return url;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
