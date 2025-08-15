package com.example.petclinic.service;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Breed;
import com.example.petclinic.repository.BreedRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import java.util.List;
import org.springframework.stereotype.Service;

@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
public class BreedService {
    BreedRepository breedRepository;

    public ApiResponse<List<Breed>> findBreedBySpecies(String species) {
        List<Breed> breeds = breedRepository.findAllBySpeciesId(Integer.parseInt(species));
        return ApiResponse.<List<Breed>>builder().message("List breeds by species").code(200).data(breeds).build();
    }
}
