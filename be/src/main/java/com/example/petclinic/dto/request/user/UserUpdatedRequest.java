package com.example.petclinic.dto.request.user;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@AllArgsConstructor
public class UserUpdatedRequest {
    String id;
    String fullname;
    String birthday;
    int gender;
    String address;
}
