package com.example.petclinic.dto.response.invoice;

import com.example.petclinic.dto.request.prescription.PrescriptionDetailReq;
import com.example.petclinic.entity.ServiceClinic;
import com.example.petclinic.entity.User;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import java.util.List;
@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
public class InvoiceResponse {
    int id;
    String invoiceCode;
    int totalAmount;
    User user;
    User doctor;
    int status;
    List<ServiceClinic> services;
    List<PrescriptionDetailReq> prescriptionDetail;
    String createdAt;
}
