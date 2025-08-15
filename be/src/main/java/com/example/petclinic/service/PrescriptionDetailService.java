package com.example.petclinic.service;

import com.example.petclinic.dto.request.prescription.PrescriptionDetailReq;
import com.example.petclinic.entity.Prescription;
import com.example.petclinic.entity.PrescriptionDetail;
import com.example.petclinic.repository.PrescriptionDetailRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import java.util.List;
@Service
@Data
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class PrescriptionDetailService {
    PrescriptionDetailRepository repository;

    public int totalPricePrescriptionDetail(List<PrescriptionDetailReq> request, Prescription prescription) {
        int totalPrice = 0;
        for (PrescriptionDetailReq preDetail : request) {
            PrescriptionDetail prescriptionDetail = new PrescriptionDetail();
            prescriptionDetail.setPrescription(prescription);
            prescriptionDetail.setDosage(preDetail.getDosage());
            prescriptionDetail.setQuantity(preDetail.getQuantity());
            prescriptionDetail.setMedication(preDetail.getMedication());
            repository.save(prescriptionDetail);
            totalPrice+=  prescriptionDetail.getQuantity() * prescriptionDetail.getMedication().getPrice();
        }
        return totalPrice;
    }

    public List<PrescriptionDetail> findAllByPrescription(Prescription prescription) {
        return repository.findAllByPrescription(prescription);
    }
}
