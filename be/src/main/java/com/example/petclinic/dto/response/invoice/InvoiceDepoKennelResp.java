package com.example.petclinic.dto.response.invoice;

import com.example.petclinic.entity.Kennel;
import com.example.petclinic.entity.Pet;
import com.example.petclinic.entity.User;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;


@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
public class InvoiceDepoKennelResp {
    int idInvoiceDepo;
    String invoiceCode;
    String createdAt;
    int totalAmount;
    String inTime;
    String outTime;
    int priceService;
    int status;
    int deposit;
    Kennel kennel;
    User user;
    Pet pet;
}
