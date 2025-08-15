package com.example.petclinic.repository;

import com.example.petclinic.entity.Invoice;
import com.example.petclinic.entity.InvoiceServiceClinic;
import com.example.petclinic.entity.ServiceClinic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
public interface InvoiceServiceRepository extends JpaRepository<InvoiceServiceClinic, Integer> {

    List<InvoiceServiceClinic> findByInvoice(Invoice invoice);

    @Query("SELECT isc.serviceClinic FROM InvoiceServiceClinic isc WHERE isc.invoice.id = :invoiceId")
    List<ServiceClinic> getAllServiceClinicByInvoice(@Param("invoiceId") int invoiceId);
}
