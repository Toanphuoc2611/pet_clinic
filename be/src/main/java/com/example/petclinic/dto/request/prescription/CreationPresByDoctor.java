package com.example.petclinic.dto.request.prescription;
import java.util.List;
import com.example.petclinic.entity.ServiceClinic;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@AllArgsConstructor
public class CreationPresByDoctor {
    String userId;
    String petId;
    List<ServiceClinic> services;
    String diagnose;
    String note;
    String reExamDate;
    List<PrescriptionDetailReq> prescriptionDetail;
}
