package com.example.petclinic.service;

import com.example.petclinic.dto.request.pet.PetCreationRequest;
import com.example.petclinic.dto.request.pet.PetUpdateRequest;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Pet;
import com.example.petclinic.entity.User;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.mapper.PetMapper;
import com.example.petclinic.repository.PetRepository;
import com.example.petclinic.repository.UserRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import java.util.List;
@Service
@Data
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class PetService {
    PetRepository petRepository;
    UserRepository userRepository;
    PetMapper petMapper;
    MedicalHistoryService medicalHistoryService;

    public ApiResponse<Pet> createPet(PetCreationRequest request) {
        String userId;
        if (request.getUserId() != null) {
            userId = request.getUserId();
        } else {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            userId = authentication.getName();
        }
        User user = userRepository.findById(userId).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        Pet pet = petMapper.toPet(request);
        pet.setUser(user);
        petRepository.save(pet);
        medicalHistoryService.createMedicalHistory(pet);
        return  ApiResponse.<Pet>builder().code(200).message("Add success").data(pet).build();
    }

    public ApiResponse<List<Pet>> getPets() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        List<Pet> listPet = petRepository.findAllByUserId(userId);
        return ApiResponse.<List<Pet>>builder().code(200).message("Success").data(listPet).build();
    }

    public ApiResponse<List<Pet>> searchPetsByName(String name) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        List<Pet> listPet = petRepository.findAllByUserIdAndName(userId, name);
        return ApiResponse.<List<Pet>>builder().code(200).message("Search success").data(listPet).build();
    }


    public ApiResponse deletePet(String id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        Pet pet = petRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.PET_NOT_EXISTED));
        if (!pet.getUser().getId().equals(userId)) {
            return ApiResponse.builder().code(403).message("You are not allowed to delete a pet that does not belong to you").build();
        } else {
            pet.setStatus(0);
            petRepository.save(pet);
            return ApiResponse.builder().code(200).message("Delete pet success").build();
        }
    }

    public ApiResponse<Pet> updatePet(String id, PetUpdateRequest request) {
        Pet pet = petRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.PET_NOT_EXISTED));
        pet.setBreed(request.getBreed());
        pet.setWeight(request.getWeight());
        pet.setIsNeutered(request.getIsNeutered());
        pet.setNote(request.getNote());
        petRepository.save(pet);
        return ApiResponse.<Pet>builder().code(200).message("Update pet success").data(pet).build();
    }

    public ApiResponse<List<Pet>> getPetByUser(String userId) {
        List<Pet> listPet = petRepository.findAllByUserId(userId);
        return ApiResponse.<List<Pet>>builder().code(200).message("Success").data(listPet).build();
    }

    public ApiResponse<List<Pet>> getPetByUserValidKennel() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        List<Pet> listPet = petRepository.getPetByUserValidKennel(userId);
        return ApiResponse.<List<Pet>>builder().code(200).message("Success").data(listPet).build();
    }

}
