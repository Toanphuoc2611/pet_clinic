package com.example.petclinic.controller;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.MedicalRecord;
import com.example.petclinic.service.MedicalRecordService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/medical_records")
@RequiredArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class MedicalRecordController {
    MedicalRecordService medicalRecordService;
    @GetMapping("/doctor")
    public ApiResponse<List<MedicalRecord>> getMedicalRecordPets() {
        return medicalRecordService.getMedicalRecordPets();
    }

    @GetMapping("/pet/{id}")
    public ApiResponse<MedicalRecord> getMedicalRecordByUser(@PathVariable String id) {
        return medicalRecordService.getMedicalRecordUser(id);
    }

    @GetMapping("/admin")
    public ApiResponse<List<MedicalRecord>> getAllMedicalRecord() {
        return medicalRecordService.getAllMedicalRecord();
    }
}
