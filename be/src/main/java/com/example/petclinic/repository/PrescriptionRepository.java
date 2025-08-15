package com.example.petclinic.repository;

import com.example.petclinic.entity.MedicalRecord;
import com.example.petclinic.entity.Pet;
import com.example.petclinic.entity.Prescription;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface PrescriptionRepository extends JpaRepository<Prescription, Integer> {
    List<Prescription> findAllByPet(Pet pet);
    List<Prescription> findAllByMedicalRecord(MedicalRecord medicalRecord);
}
