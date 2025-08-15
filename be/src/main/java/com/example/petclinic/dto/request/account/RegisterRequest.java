package com.example.petclinic.dto.request.account;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class RegisterRequest {
    String email;
    @JsonProperty("phone_number")
    String phoneNumber;
    String password;
    String fullname;
    String birthday;
    int gender;
    String address;
    @JsonProperty("role_id")
    int roleId;
    String otp;
}
