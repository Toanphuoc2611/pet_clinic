package com.example.petclinic.dto.request.prescription;

import com.example.petclinic.entity.Medication;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@AllArgsConstructor
public class PrescriptionDetailReq {
    String dosage;
    int quantity;
    Medication medication;
}
