package com.example.petclinic.controller;

import com.example.petclinic.dto.request.prescription.CreationPresByDoctor;
import com.example.petclinic.dto.request.prescription.CreationPrescriptionReq;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.invoice.InvoiceResponse;
import com.example.petclinic.dto.response.prescription.PrescriptionResponse;
import com.example.petclinic.entity.Prescription;
import com.example.petclinic.service.PrescriptionService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;
import java.util.List;
@RestController
@RequestMapping("/prescriptions")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PrescriptionController {
    PrescriptionService prescriptionService;

    @PostMapping("/create")
    public ApiResponse<InvoiceResponse> createPrescription(@RequestBody CreationPrescriptionReq req) {
        return prescriptionService.createPrescription(req);
    }

    @PostMapping("/doctor/create")
    public ApiResponse<InvoiceResponse> createPrescriptionByDoctor(@RequestBody CreationPresByDoctor req) {
        return prescriptionService.createPrescriptionByDoctor(req);
    }

    @GetMapping("/medical_record/{id}")
    public ApiResponse<List<PrescriptionResponse>> getPrescriptionByMedicalRecord(@PathVariable String id) {
        return prescriptionService.getPrescriptionByMedicalRecord(id);
    }
}

