package com.example.petclinic.service;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.MedicalHistory;
import com.example.petclinic.entity.MedicalRecord;
import com.example.petclinic.entity.Pet;
import com.example.petclinic.repository.MedicalHistoryRepository;
import com.example.petclinic.repository.MedicalRecordRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import java.util.List;
@Data
@RequiredArgsConstructor
@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class MedicalHistoryService {
    MedicalHistoryRepository medicalHistoryRepository;
    MedicalRecordRepository medicalRecordRepository;
    public ApiResponse<List<MedicalRecord>> getMedicalHistoryByPet(String petId) {
        MedicalHistory medicalHistory = medicalHistoryRepository.findByPetId(petId);
        List<MedicalRecord> medicalRecords = medicalRecordRepository.findAllByMedicalHistory(medicalHistory);
        return ApiResponse.<List<MedicalRecord>>builder().message("History medical").code(200).data(medicalRecords).build();
    }

    public MedicalHistory findMedicalByPetId(String petId) {
        MedicalHistory medicalHistory = medicalHistoryRepository.findByPetId(petId);
        return medicalHistory;
    }

    public void createMedicalHistory(Pet pet) {
        MedicalHistory medicalHistory = new MedicalHistory();
        medicalHistory.setPet(pet);
        medicalHistoryRepository.save(medicalHistory);
    }

}
