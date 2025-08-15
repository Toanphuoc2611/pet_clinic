package com.example.petclinic.controller;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.MedicalRecord;
import com.example.petclinic.service.MedicalHistoryService;
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
@RequestMapping("/medical_history")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class MedicalHistoryController {
    MedicalHistoryService medicalHistoryService;
    @GetMapping("/pet/{id}")
    public ApiResponse<List<MedicalRecord>> getMedicalHistoryByPet(@PathVariable String id) {
        return medicalHistoryService.getMedicalHistoryByPet(id);
    }
}
