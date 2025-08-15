package com.example.petclinic.service;

import com.example.petclinic.dto.request.service.CreationService;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.ServiceClinic;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.ServiceRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import  java.util.List;
@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ServiceClinicService {
    ServiceRepository serviceRepository;

    public ApiResponse<List<ServiceClinic>> getAllServices() {
        List<ServiceClinic> list = serviceRepository.findAllByStatus(1).stream().toList();
        return ApiResponse.<List<ServiceClinic>>builder().code(200).message("Get list services success").data(list).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<ServiceClinic>> getAllServicesAdmin() {
        List<ServiceClinic> list = serviceRepository.findAll().stream().toList();
        return ApiResponse.<List<ServiceClinic>>builder().code(200).message("Get list services success").data(list).build();
    }

    public ApiResponse<Boolean> addServices(CreationService request) {
        ServiceClinic serviceClinic = new ServiceClinic();
        serviceClinic.setName(request.getName());
        serviceClinic.setPrice(request.getPrice());
        serviceClinic.setStatus(1);
        serviceRepository.save(serviceClinic);
        return ApiResponse.<Boolean>builder().message("Add service success").code(200).data(true).build();
    }

    public ApiResponse<Boolean> updateServices(int price, int id) {
        ServiceClinic serviceClinic = serviceRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.SERVICE_NOT_EXISTED));
        serviceClinic.setPrice(price);
        serviceRepository.save(serviceClinic);
        return ApiResponse.<Boolean>builder().message("update service success").code(200).data(true).build();
    }

    public ApiResponse<Boolean> updateStatusServices(int status, int id) {
        ServiceClinic serviceClinic = serviceRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.SERVICE_NOT_EXISTED));
        serviceClinic.setStatus(status);
        serviceRepository.save(serviceClinic);
        return ApiResponse.<Boolean>builder().message("update service success").code(200).data(true).build();
    }
}
