package com.example.petclinic.dto.request.account;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CreationDoctorRequest {
    String email;
    String fullname;
    String phoneNumber;
    String address;
    String birthday;
    int gender;
}
