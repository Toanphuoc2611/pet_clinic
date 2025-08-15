package com.example.petclinic.dto.response.address;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class District {
    int DistrictID;
    int ProvinceID;
    String DistrictName;
}
