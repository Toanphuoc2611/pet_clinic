package com.example.petclinic.service;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.MedicalHistory;
import com.example.petclinic.entity.MedicalRecord;
import com.example.petclinic.entity.Pet;
import com.example.petclinic.entity.User;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.MedicalRecordRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import java.util.List;

@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
public class MedicalRecordService {
    MedicalRecordRepository medicalRecordRepository;
    static PetService petService;
    static UserService userRepository;

    public MedicalRecord createMedicalRecord(MedicalHistory medicalHistory, User doctor, int status) {
            MedicalRecord medicalRecord = new MedicalRecord();
             medicalRecord.setPet(medicalHistory.getPet());
             medicalRecord.setStatus(status);
             medicalRecord.setDoctor(doctor);
             medicalRecord.setMedicalHistory(medicalHistory);
             medicalRecordRepository.save(medicalRecord);
             return medicalRecord;
    }

    public MedicalRecord findMedicalRecordByPet(Pet pet) {
        return medicalRecordRepository.findByPetAndStatus(pet, 0);
    }

    public MedicalRecord findMedicalRecordById(int id) {
        return medicalRecordRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.MEDICAL_RECORD_NOT_EXISTED));
    }

    @PreAuthorize("hasRole('DOCTOR')")
    public ApiResponse<List<MedicalRecord>> getMedicalRecordPets() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String doctorId = authentication.getName();
        List<MedicalRecord> list = medicalRecordRepository.getMedicalRecordByDoctor(doctorId);
        return ApiResponse.<List<MedicalRecord>>builder().code(200)
                .message("Get list medical record success").data(list).build();
    }

    public ApiResponse<MedicalRecord> getMedicalRecordUser(String petId) {
        MedicalRecord medicalRecord = medicalRecordRepository.getMedicalRecordByUser(petId);
        return ApiResponse.<MedicalRecord>builder().code(200)
                .message("Get list medical record success").data(medicalRecord).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<MedicalRecord>> getAllMedicalRecord() {
        List<MedicalRecord> list = medicalRecordRepository.findAll();
        return ApiResponse.<List<MedicalRecord>>builder().code(200)
                .message("Get list medical record success").data(list).build();
    }

}
