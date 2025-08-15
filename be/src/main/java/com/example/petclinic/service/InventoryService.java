package com.example.petclinic.service;

import com.example.petclinic.dto.request.inventory.ImportInventory;
import com.example.petclinic.dto.request.inventory.MedicationImportRequest;
import com.example.petclinic.dto.request.inventory.MedicationUpdate;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Inventory;
import com.example.petclinic.entity.Medication;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.CategoryRepository;
import com.example.petclinic.repository.InventoryRepository;
import com.example.petclinic.repository.MedicationRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import java.util.List;

@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
public class InventoryService {
    InventoryRepository inventoryRepository;
    MedicationRepository medicationRepository;
    CategoryRepository categoryRepository;

    public ApiResponse<List<Inventory>> getAllInventory() {
        List<Inventory> list = inventoryRepository.findAll();
        return ApiResponse.<List<Inventory>>builder().code(200).message("Get inventory success").data(list).build();
    }
    public boolean paymentMedication(Medication medication, int quantity) {
        Inventory inventory = inventoryRepository.findByMedication(medication);
        inventory.setSoldOut(inventory.getSoldOut() + quantity);
        medication.setStockQuantity(medication.getStockQuantity() - quantity);
        inventoryRepository.save(inventory);
        medicationRepository.save(medication);
        return true;
    }

    public boolean importInventory(ImportInventory request) {
        Inventory inventory = inventoryRepository.findByMedication_Id(request.getMedicationId());


        inventory.setQuantity(inventory.getQuantity() + request.getQuantity());
        inventory.setPrice(request.getPrice());

        inventoryRepository.save(inventory);
        Medication medication = inventory.getMedication();
        medication.setStockQuantity(inventory.getQuantity() - inventory.getSoldOut());
        medicationRepository.save(medication);
        return true;
    }

    public boolean importNewMedication(MedicationImportRequest request) {
        Medication medication = new Medication();
        medication.setName(request.getName());
        medication.setDescription(request.getDescription());
        medication.setUnit(request.getUnit());
        medication.setPrice(request.getPrice());
        medication.setStockQuantity(request.getQuantity());
        medication.setIsSale(1);
        medication.setCategory(categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new AppException(ErrorCode.SERVICE_NOT_EXISTED)));

        Medication savedMedication = medicationRepository.save(medication);

        Inventory inventory = new Inventory();
        inventory.setMedication(savedMedication);
        inventory.setQuantity(request.getQuantity());
        inventory.setSoldOut(0);
        inventory.setPrice(request.getPrice());

        inventoryRepository.save(inventory);
        return true;
    }

    public ApiResponse<Boolean> updateStatusMedication(MedicationUpdate request) {
        Inventory inventory = inventoryRepository.findByMedication_Id(request.getMedicationId());
        inventory.getMedication().setIsSale(request.getIsSale());
        medicationRepository.save(inventory.getMedication());
        return ApiResponse.<Boolean>builder().code(200).message("Update medication").data(true).build();
    }
}
