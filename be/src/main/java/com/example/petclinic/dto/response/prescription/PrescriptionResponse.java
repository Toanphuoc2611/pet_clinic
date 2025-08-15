package com.example.petclinic.dto.response.prescription;

import com.example.petclinic.dto.request.prescription.PrescriptionDetailReq;
import com.example.petclinic.entity.PrescriptionDetail;
import com.example.petclinic.entity.User;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import java.util.List;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
public class PrescriptionResponse {
    int id;
    User doctor;
    String diagnose;
    String reExamDate;
    String createdAt;
    String note;
    List<PrescriptionDetailReq> prescriptionDetail;
}
