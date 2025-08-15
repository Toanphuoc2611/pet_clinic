package com.example.petclinic.controller;

import com.example.petclinic.dto.request.service.CreationService;
import com.example.petclinic.dto.request.service.UpdateService;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.ServiceClinic;
import com.example.petclinic.service.ServiceClinicService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/services")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ServiceClinicController {
    ServiceClinicService service;

    @GetMapping()
    public ApiResponse<List<ServiceClinic>> getAllServices() {
        return service.getAllServices();
    }

    @GetMapping("/admin")
    public ApiResponse<List<ServiceClinic>> getAllServicesAdmin() {
        return service.getAllServicesAdmin();
    }

    @PostMapping()
    public ApiResponse<Boolean> addService(@RequestBody  CreationService creationService) {
        return service.addServices(creationService);
    }

    @PutMapping("/{id}")
    public ApiResponse<Boolean> updateService(@PathVariable String id, @RequestBody UpdateService request) {
        return service.updateServices(request.getPrice(), Integer.parseInt(id));
    }

    @PutMapping("/{id}/status")
    public ApiResponse<Boolean> updateStatusService(@PathVariable String id, @RequestParam String status) {
        return service.updateStatusServices(Integer.parseInt(status), Integer.parseInt(id));
    }
}
