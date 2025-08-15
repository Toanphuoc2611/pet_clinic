package com.example.petclinic.dto.request.pet;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class PetUpdateRequest {
    String breed;
    double weight;
    @JsonProperty("is_neutered")
    int isNeutered;
    String note;
}
