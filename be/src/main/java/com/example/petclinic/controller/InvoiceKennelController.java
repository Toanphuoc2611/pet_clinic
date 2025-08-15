package com.example.petclinic.controller;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.InvoiceKennel;
import com.example.petclinic.service.InvoiceKennelService;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/invoice/kennels")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class InvoiceKennelController {
    InvoiceKennelService invoiceKennelService;
    @PutMapping("/payment/{id}")
    public ApiResponse<Boolean> paymentInvoiceKennel(@PathVariable String id) {
        return invoiceKennelService.paymentInvoiceKennel(Integer.parseInt(id));
    }

    @GetMapping("/doctor")
    public ApiResponse<List<InvoiceKennel>> getInvoiceByDoctor() {
        return invoiceKennelService.getInvoiceByDoctor();
    }

    @GetMapping("/user")
    public ApiResponse<List<InvoiceKennel>> getInvoiceByUser() {
        return invoiceKennelService.getInvoiceByUser();
    }

    @GetMapping("/admin/revenue")
    public ApiResponse<Integer> getRevenue(@RequestParam String start, @RequestParam String end) {
        return invoiceKennelService.getRevenue(start, end);
    }

    @GetMapping("/admin/revenue/{id}")
    public ApiResponse<Integer> getRevenue(@PathVariable String id,@RequestParam String start, @RequestParam String end) {
        return invoiceKennelService.getRevenueByDoctor(start, end,id);
    }

    @GetMapping("/admin")
    public ApiResponse<List<InvoiceKennel>> getAllInvoiceKennels() {
        return invoiceKennelService.getAllInvoiceKennels();
    }
}
