package com.example.petclinic.repository;

import com.example.petclinic.entity.Inventory;
import com.example.petclinic.entity.Medication;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryRepository extends JpaRepository<Inventory, Integer> {
    Inventory findByMedication(Medication medication);
    Inventory findByMedication_Id(int id);
}
