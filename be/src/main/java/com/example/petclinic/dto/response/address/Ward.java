package com.example.petclinic.dto.response.address;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Ward {
    String WardCode;
    int DistrictID;
    String WardName;
}
