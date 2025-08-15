package com.example.petclinic.dto.response.invoice;

import com.example.petclinic.entity.KennelDetail;
import com.example.petclinic.entity.User;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
public class InvoiceKennelResp {
    int id;
    String invoiceCode;
    int status;
    int totalAmount;
    int deposit;
    String createdAt;
    User doctor;
    User user;
    KennelDetail kennelDetail;
}
