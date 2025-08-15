package com.example.petclinic.dto.request.user;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@AllArgsConstructor
public class UserCreationRequest {
    String fullname;
    String birthday;
    @JsonProperty("phone_number")
    String phoneNumber;
    String email;
    int gender;
    String address;
}
