package com.example.petclinic.repository;

import com.example.petclinic.entity.Medication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface MedicationRepository extends JpaRepository<Medication, Integer> {

    @Query(value = "SELECT * FROM medications WHERE is_sale = 1", nativeQuery = true)
    List<Medication> getAllMedications();
}
