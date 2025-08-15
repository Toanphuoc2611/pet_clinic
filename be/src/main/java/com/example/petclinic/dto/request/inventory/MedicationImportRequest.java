package com.example.petclinic.dto.request.inventory;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class MedicationImportRequest {
    String name;
    String description;
    String unit;
    int price;
    int quantity;
    int categoryId;
}
