package com.example.petclinic.service;

import com.example.petclinic.dto.request.prescription.PrescriptionDetailReq;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.invoice.InvoiceResponse;
import com.example.petclinic.entity.*;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.*;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
public class InvoiceService {
    InvoiceRepository invoiceRepository;
    InvoiceServiceRepository invoiceAppRepository;
    InvoicePresRepository invoicePresRepository;
    PrescriptionDetailRepository prescriptionDetailRepository;
    AppointmentRepository appointmentRepository;
    InventoryService inventoryService;

    public Invoice createInvoice(Appointment appointment, int price, Prescription prescription) {
        appointment.setStatus(2);
        appointmentRepository.save(appointment);
        int priceApp = 0;
        if (appointment.getInvoiceDeposit() != null) {
            priceApp= appointment.getInvoiceDeposit().getTotalAmount() - appointment.getInvoiceDeposit().getDeposit();
        }
        int totalPrice = price + priceApp;
        Invoice invoice = new Invoice();
        invoice.setStatus(0);
        invoice.setPet(prescription.getPet());
        invoice.setUser(appointment.getUser());
        invoice.setDoctor(appointment.getDoctor());
        invoice.setTotalAmount(totalPrice);
        invoiceRepository.save(invoice);
        List<ServiceClinic> serviceClinics = appointment.getServices();
        for (ServiceClinic services : serviceClinics) {
            InvoiceServiceClinic invoiceServiceClinic = new InvoiceServiceClinic();
            invoiceServiceClinic.setInvoice(invoice);
            invoiceServiceClinic.setServiceClinic(services);
            invoiceAppRepository.save(invoiceServiceClinic);
        }
        if (prescription != null) {
            InvoicePrescription invoicePrescription = new InvoicePrescription();
            invoicePrescription.setPrescription(prescription);
            invoicePrescription.setInvoice(invoice);
            invoicePresRepository.save(invoicePrescription);
        }
        return invoice;
    }

    public Invoice createInvoiceByDoctor(List<ServiceClinic> services, User user, User doctor,
                                         int price, Prescription prescription) {
        int priceApp = 0;
        Invoice invoice = new Invoice();
        invoice.setStatus(0);
        invoice.setPet(prescription.getPet());
        invoice.setUser(user);
        invoice.setDoctor(doctor);
        invoiceRepository.save(invoice);
        for (ServiceClinic service : services) {
            InvoiceServiceClinic invoiceServiceClinic = new InvoiceServiceClinic();
            invoiceServiceClinic.setInvoice(invoice);
            invoiceServiceClinic.setServiceClinic(service);
            invoiceAppRepository.save(invoiceServiceClinic);
            priceApp += service.getPrice();
        }
        int totalPrice = priceApp + price;
        invoice.setTotalAmount(totalPrice);
        invoiceRepository.save(invoice);
        if (prescription != null) {
            InvoicePrescription invoicePrescription = new InvoicePrescription();
            invoicePrescription.setPrescription(prescription);
            invoicePrescription.setInvoice(invoice);
            invoicePresRepository.save(invoicePrescription);
        }
        return invoice;
    }


    public ApiResponse<Boolean> paymentInvoice(int idInvoice) {
        Invoice invoice = invoiceRepository.findById(idInvoice).orElseThrow(() -> new AppException(ErrorCode.INVOICE_NOT_EXISTED));
        boolean isPayment = true;
        InvoicePrescription ip = invoicePresRepository.findAllByInvoice(invoice);
        List<PrescriptionDetail> listPd = prescriptionDetailRepository.findAllByPrescription(ip.getPrescription());
        for (PrescriptionDetail pd: listPd) {
            isPayment = inventoryService.paymentMedication(pd.getMedication(), pd.getQuantity());
        }
        if (isPayment) {
            invoice.setStatus(1);
            invoiceRepository.save(invoice);
            return ApiResponse.<Boolean>builder().code(200).message("Payment success").data(true).build();
        } else {
            return ApiResponse.<Boolean>builder().code(200).message("Payment failure").data(false).build();
        }
    }


    public ApiResponse<List<Invoice>> getInvoiceByDoctor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String doctorId = authentication.getName();
        List<Invoice> invoices = invoiceRepository.findAllByDoctor(doctorId);
        return ApiResponse.<List<Invoice>>builder().code(200).message("Get invoice success").data(invoices).build();
    }

    public ApiResponse<List<InvoiceResponse>> getInvoiceByUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        List<Invoice> invoices = invoiceRepository.findAllByUser(userId);
        List<InvoiceResponse> response = new ArrayList<>();
        for (Invoice invoice : invoices) {
            List<ServiceClinic> serviceClinics = invoiceAppRepository.getAllServiceClinicByInvoice(invoice.getId());
            InvoicePrescription ip = invoicePresRepository.findAllByInvoice(invoice);
            List<PrescriptionDetail> listPd = prescriptionDetailRepository.findAllByPrescription(ip.getPrescription());
            List<PrescriptionDetailReq> details = new ArrayList<>();
            for (PrescriptionDetail pd : listPd) {
                PrescriptionDetailReq prescriptionDetailReq = new PrescriptionDetailReq(pd.getDosage(), pd.getQuantity(), pd.getMedication());
                details.add(prescriptionDetailReq);
            }
            InvoiceResponse invoiceResponse = new InvoiceResponse(
                        invoice.getId(), invoice.getInvoiceCode(), invoice.getTotalAmount(),
                        invoice.getUser(), invoice.getDoctor(), invoice.getStatus(),
                    serviceClinics, details, invoice.getCreatedAt().toString());

                response.add(invoiceResponse);
            }
        return ApiResponse.<List<InvoiceResponse>>builder().code(200).message("Get invoice success").data(response).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Integer> getRevenue(String start, String end) {
        int revenue  = invoiceRepository.getRevenue(start, end);
        return ApiResponse.<Integer>builder().code(200).message("Get revenue").data(revenue).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Integer> getRevenueByDoctor(String start, String end, String doctorId) {
        Integer revenue  = Optional.ofNullable( invoiceRepository.getRevenueByDoctor(start, end, doctorId)).orElse(0);
        return ApiResponse.<Integer>builder().code(200).message("Get revenue by doctor").data(revenue).build();
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<InvoiceResponse>> getAllInvoices() {
        List<Invoice> invoices = invoiceRepository.findAll();
        List<InvoiceResponse> response = new ArrayList<>();
        for (Invoice invoice : invoices) {
            List<ServiceClinic> serviceClinics = invoiceAppRepository.getAllServiceClinicByInvoice(invoice.getId());
            InvoicePrescription ip = invoicePresRepository.findAllByInvoice(invoice);
            List<PrescriptionDetailReq> details = new ArrayList<>();
            if (ip !=null) {
                List<PrescriptionDetail> listPd = prescriptionDetailRepository.findAllByPrescription(ip.getPrescription());
                for (PrescriptionDetail pd : listPd) {
                    PrescriptionDetailReq prescriptionDetailReq = new PrescriptionDetailReq(pd.getDosage(), pd.getQuantity(), pd.getMedication());
                    details.add(prescriptionDetailReq);
                }
            }
            InvoiceResponse invoiceResponse = new InvoiceResponse(
                    invoice.getId(), invoice.getInvoiceCode(), invoice.getTotalAmount(),
                    invoice.getUser(), invoice.getDoctor(), invoice.getStatus(),
                    serviceClinics, details, invoice.getCreatedAt().toString());

            response.add(invoiceResponse);
        }
        return ApiResponse.<List<InvoiceResponse>>builder().code(200).message("Get invoice success").data(response).build();
    }
}
