package com.example.petclinic.dto.response.invoice;

import com.example.petclinic.entity.Pet;
import com.example.petclinic.entity.ServiceClinic;
import com.example.petclinic.entity.User;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import java.util.List;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
public class InvoiceDepoAppointResp {
    int idInvoiceDepo;
    String invoiceCode;
    String createdAt;
    int totalAmount;
    String appointmentTime;
    List<ServiceClinic> services;
    int status;
    int deposit;
    User user;
}
