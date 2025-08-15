package com.example.petclinic.dto.request.pet;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@AllArgsConstructor
public class PetCreationRequest {
    String name;
    String birthday;
    String type;
    String breed;
    String color;
    int gender;
    double weight;
    @JsonProperty("is_neutered")
    int isNeutered;
    String note;
    String avatar;
    String userId;
}
