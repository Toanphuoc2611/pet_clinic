package com.example.petclinic.repository;

import com.example.petclinic.entity.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface InvoiceRepository extends JpaRepository<Invoice, Integer> {

    @Query(value = "select * from invoices where status = 1 and doctor_id = :doctorId", nativeQuery = true)
    List<Invoice> findAllByDoctor(String doctorId);
    @Query(value = "select * from invoices where user_id = :userId", nativeQuery = true)
    List<Invoice> findAllByUser(String userId);

    @Query(value = "select sum(total_amount) from invoices where status = 1 and created_at between :start and :end", nativeQuery = true)
    int getRevenue(String start, String end);
    @Query(value = "select sum(total_amount) from invoices where doctor_id = :doctorId and status = 1 and created_at between :start and :end", nativeQuery = true)
    Integer getRevenueByDoctor(String start, String end, String doctorId);
}
