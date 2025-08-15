package com.example.petclinic.service;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Medication;
import com.example.petclinic.repository.MedicationRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import java.util.List;
@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
public class MedicationService {
    MedicationRepository repository;

    @PreAuthorize("hasRole('DOCTOR')")
    public ApiResponse<List<Medication>> getAllMedications() {
        List<Medication> medications = repository.getAllMedications();
        return ApiResponse.<List<Medication>>builder().message("Get all medication").code(200).data(medications).build();
    }

    public boolean checkStockBiggerQuantity(Medication medication, int quantity) {
        return medication.getStockQuantity() >= quantity;
    }
}
