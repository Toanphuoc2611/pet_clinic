package com.example.petclinic.repository;

import com.example.petclinic.entity.MedicalHistory;
import com.example.petclinic.entity.MedicalRecord;
import com.example.petclinic.entity.Pet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface MedicalRecordRepository extends JpaRepository<MedicalRecord, Integer> {
    MedicalRecord findByPetAndStatus(Pet pet, int status);

    @Query(value = "select * from medical_records where doctor_id = :doctorId", nativeQuery = true)
    List<MedicalRecord> getMedicalRecordByDoctor(String doctorId);

    @Query(value = "select * from medical_records where pet_id = :petId", nativeQuery = true)
    MedicalRecord getMedicalRecordByUser(String petId);

    List<MedicalRecord> findAllByMedicalHistory(MedicalHistory medicalHistory);
}
