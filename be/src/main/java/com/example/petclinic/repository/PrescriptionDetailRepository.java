package com.example.petclinic.repository;

import com.example.petclinic.entity.Prescription;
import com.example.petclinic.entity.PrescriptionDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PrescriptionDetailRepository extends JpaRepository<PrescriptionDetail, Integer> {

    List<PrescriptionDetail> findAllByPrescription(Prescription prescription);
}
