package com.example.petclinic.repository;

import com.example.petclinic.entity.Invoice;
import com.example.petclinic.entity.InvoicePrescription;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface InvoicePresRepository extends JpaRepository<InvoicePrescription, Integer> {
    InvoicePrescription findAllByInvoice(Invoice invoice);
}
