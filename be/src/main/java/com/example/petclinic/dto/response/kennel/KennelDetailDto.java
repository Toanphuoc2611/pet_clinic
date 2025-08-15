package com.example.petclinic.dto.response.kennel;

import com.example.petclinic.entity.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class KennelDetailDto {
    int id;

    Pet pet;
    User user;
    User doctor;
    Kennel kennel;
    InvoiceDeposit invoiceDeposit;

    @JsonFormat(pattern = "dd/MM/yyyy HH:mm:ss")
    LocalDateTime inTime;

    @JsonFormat(pattern = "dd/MM/yyyy HH:mm:ss")
    LocalDateTime outTime;

    @JsonFormat(pattern = "dd/MM/yyyy HH:mm:ss")
    LocalDateTime actualCheckin;

    @JsonFormat(pattern = "dd/MM/yyyy HH:mm:ss")
    LocalDateTime actualCheckout;

    @JsonFormat(pattern = "dd/MM/yyyy HH:mm:ss")
    LocalDateTime createdAt;

    @JsonFormat(pattern = "dd/MM/yyyy HH:mm:ss")
    LocalDateTime updatedAt;

    int status;
    String note;
}
