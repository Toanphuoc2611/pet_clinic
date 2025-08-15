package com.example.petclinic.mapper;

import com.example.petclinic.dto.request.pet.PetCreationRequest;
import com.example.petclinic.entity.Pet;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface PetMapper {
    Pet toPet(PetCreationRequest request);
    void updatePetFromRequest(PetCreationRequest request, @MappingTarget Pet pet);
}
