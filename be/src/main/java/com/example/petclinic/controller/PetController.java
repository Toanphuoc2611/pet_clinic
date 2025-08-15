package com.example.petclinic.controller;

import com.example.petclinic.dto.request.pet.PetCreationRequest;
import com.example.petclinic.dto.request.pet.PetUpdateRequest;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Pet;
import com.example.petclinic.service.PetService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/pets")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PetController {
    PetService petService;

    @PostMapping("/pet")
    public ApiResponse<Pet> createPet(@RequestBody PetCreationRequest request) {
        return petService.createPet(request);
    }
    @GetMapping
    public ApiResponse<List<Pet>> getPets() {
        return petService.getPets();
    }

    @GetMapping("/search")
    public ApiResponse<List<Pet>> searchPetsByName(@RequestParam String name) {
        return petService.searchPetsByName(name);
    }

    @DeleteMapping ("/pet/{id}")
    public ApiResponse deletePet(@PathVariable String id) {
        return petService.deletePet(id);
    }

    @PutMapping("/pet/{id}")
    public ApiResponse<Pet> updatePet(@PathVariable String id, @RequestBody PetUpdateRequest request) {
        return petService.updatePet(id, request);
    }

    @GetMapping("/user/{id}")
    public ApiResponse<List<Pet>> getPetsByUser(@PathVariable String id) {
        return petService.getPetByUser(id);
    }

    @GetMapping("/kennel/valid")
    public ApiResponse<List<Pet>> getPetByUserValidKennel() {
        return petService.getPetByUserValidKennel();
    }
}
