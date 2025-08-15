package com.example.petclinic.service;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.invoice.InvoiceResponse;
import com.example.petclinic.entity.*;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.InvoiceKennelRepository;
import com.example.petclinic.repository.InvoiceRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
public class InvoiceKennelService {
    InvoiceKennelRepository invoiceKennelRepository;

    public InvoiceKennel createInvoiceKennel(Pet pet, User doctor, int totalAmount, KennelDetail kennelDetail) {
        InvoiceKennel invoiceKennel = new InvoiceKennel();
        invoiceKennel.setStatus(0);
        invoiceKennel.setPet(pet);
        invoiceKennel.setDoctor(doctor);
        invoiceKennel.setTotalAmount(totalAmount);
        invoiceKennel.setKennelDetail(kennelDetail);
        invoiceKennel.setUser(pet.getUser());
        invoiceKennelRepository.save(invoiceKennel);
        return invoiceKennel;
    }

    public ApiResponse<Boolean> paymentInvoiceKennel(int id) {
        InvoiceKennel invoiceKennel = invoiceKennelRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.INVOICE_NOT_EXISTED));
        invoiceKennel.setStatus(1);
        invoiceKennelRepository.save(invoiceKennel);
        return ApiResponse.<Boolean>builder().code(200).message("payment invoice kennel success").data(true).build();
    }

    public ApiResponse<List<InvoiceKennel>> getInvoiceByDoctor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String doctorId = authentication.getName();
        List<InvoiceKennel> invoices = invoiceKennelRepository.findAllByDoctor(doctorId);
        return ApiResponse.<List<InvoiceKennel>>builder().code(200).message("Get invoice success").data(invoices).build();
    }


    public ApiResponse<List<InvoiceKennel>> getInvoiceByUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        List<InvoiceKennel> invoices = invoiceKennelRepository.findAllByUser(userId);
        return ApiResponse.<List<InvoiceKennel>>builder().code(200).message("Get invoice success").data(invoices).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Integer> getRevenue(String start, String end) {
        int revenue  = invoiceKennelRepository.getRevenue(start, end);
        return ApiResponse.<Integer>builder().code(200).message("Get revenue kennel").data(revenue).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Integer> getRevenueByDoctor(String start, String end, String doctorId) {
        int revenue  = invoiceKennelRepository.getRevenueByDoctor(start, end, doctorId);
        return ApiResponse.<Integer>builder().code(200).message("Get revenue kennel by doctor").data(revenue).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<InvoiceKennel>> getAllInvoiceKennels() {
        List<InvoiceKennel> invoices = invoiceKennelRepository.findAll();
        return ApiResponse.<List<InvoiceKennel>>builder().code(200).message("Get invoice success").data(invoices).build();
    }

}
