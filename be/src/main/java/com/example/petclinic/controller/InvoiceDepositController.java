package com.example.petclinic.controller;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.invoice.InvoiceDepoAppointResp;
import com.example.petclinic.dto.response.invoice.InvoiceDepoKennelResp;
import com.example.petclinic.entity.InvoiceDeposit;
import com.example.petclinic.service.InvoiceDepositService;
import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/deposit")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class InvoiceDepositController {
    InvoiceDepositService depositService;

    @GetMapping
    public ApiResponse<List<InvoiceDeposit>> getInvoiceDepositUser() {
        return depositService.getInvoiceDepositUser();
    }

    @PutMapping("/payment/{id}")
    public ApiResponse<Boolean> paymentInvoice(@PathVariable int id) throws FirebaseMessagingException {
        return depositService.paymentInvoice(id);
    }

    @GetMapping("/appointment/{id}")
    public ApiResponse<InvoiceDepoAppointResp> getInvoiceDepoAppoint(@PathVariable String id) {
        return depositService.getInvoiceDepoAppoint(Integer.parseInt(id));
    }

    @GetMapping("/kennel/{id}")
    public ApiResponse<InvoiceDepoKennelResp> getInvoiceDepoKennel(@PathVariable String id) {
        return depositService.getInvoiceDepoKennel(Integer.parseInt(id));
    }
}
