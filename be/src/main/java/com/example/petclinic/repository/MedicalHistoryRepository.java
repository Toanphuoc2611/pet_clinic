package com.example.petclinic.repository;

import com.example.petclinic.entity.MedicalHistory;
import com.example.petclinic.entity.MedicalRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface MedicalHistoryRepository  extends JpaRepository<MedicalHistory, Integer> {
    MedicalHistory findByPetId(String petId);
}
