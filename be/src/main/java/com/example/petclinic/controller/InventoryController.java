package com.example.petclinic.controller;

import com.example.petclinic.dto.request.inventory.ImportInventory;
import com.example.petclinic.dto.request.inventory.MedicationImportRequest;
import com.example.petclinic.dto.request.inventory.MedicationUpdate;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Inventory;
import com.example.petclinic.service.InventoryService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;
@RestController
@RequestMapping("/inventory")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class InventoryController {

    InventoryService inventoryService;

    @GetMapping
    public ApiResponse<List<Inventory>> getAllInventory(){
        return inventoryService.getAllInventory();
    }

    @PutMapping("/import")
    public ApiResponse<Boolean> importInventory(@RequestBody ImportInventory importInventory) {
        return ApiResponse.<Boolean>builder().code(200).message("import inventory success").data(inventoryService.importInventory(importInventory)).build();
    }

    @PostMapping("/import")
    public ApiResponse<Boolean> importNewMedication(@RequestBody MedicationImportRequest request) {
        return ApiResponse.<Boolean>builder().code(200).message("import inventory success")
                .data(inventoryService.importNewMedication(request)).build();
    }


    @PutMapping("/status")
    public ApiResponse<Boolean> updateStatusMedication(@RequestBody MedicationUpdate request) {
        return inventoryService.updateStatusMedication(request);
    }
}
