package com.example.petclinic.dto.request.prescription;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import java.util.List;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@AllArgsConstructor
public class CreationPrescriptionReq {
    String diagnose;
    String note;
    String reExamDate;
    String petId;
    int idAppointment;
    List<PrescriptionDetailReq> prescriptionDetail;
}
