package com.example.petclinic.controller;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.invoice.InvoiceResponse;
import com.example.petclinic.entity.Invoice;
import com.example.petclinic.repository.InvoiceRepository;
import com.example.petclinic.service.InvoiceService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/invoices")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class InvoiceController {
    InvoiceService invoiceService;

    @PutMapping("/payment/{id}")
    public ApiResponse<Boolean> paymentInvoice(@PathVariable String id) {
        return invoiceService.paymentInvoice(Integer.parseInt(id));
    }

    @GetMapping("/doctor")
    public ApiResponse<List<Invoice>> getInvoiceByDoctor() {
        return invoiceService.getInvoiceByDoctor();
    }

    @GetMapping("/user")
    public ApiResponse<List<InvoiceResponse>> getInvoiceByUser() {
        return invoiceService.getInvoiceByUser();
    }

    @GetMapping("/admin/revenue")
    public ApiResponse<Integer> getRevenue(@RequestParam String start, @RequestParam String end) {
        return invoiceService.getRevenue(start, end);
    }

    @GetMapping("/admin/revenue/{id}")
    public ApiResponse<Integer> getRevenue(@PathVariable String id,@RequestParam String start, @RequestParam String end) {
        return invoiceService.getRevenueByDoctor(start, end,id);
    }

    @GetMapping("/admin")
    public ApiResponse<List<InvoiceResponse>> getAllInvoices() {
        return invoiceService.getAllInvoices();
    }
}
