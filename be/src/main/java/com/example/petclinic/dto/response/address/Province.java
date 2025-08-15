package com.example.petclinic.dto.response.address;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Province {
    @JsonProperty("ProvinceID")
    int ProvinceID;
    @JsonProperty("ProvinceName")
    String ProvinceName;
}
