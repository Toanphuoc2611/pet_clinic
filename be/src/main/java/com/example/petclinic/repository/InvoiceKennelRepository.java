package com.example.petclinic.repository;

import com.example.petclinic.entity.Invoice;
import com.example.petclinic.entity.InvoiceKennel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface InvoiceKennelRepository extends JpaRepository<InvoiceKennel, Integer> {

    @Query(value = "select * from invoice_kennels where status = 1 and doctor_id = :doctorId", nativeQuery = true)
    List<InvoiceKennel> findAllByDoctor(String doctorId);

    @Query(value = "select * from invoice_kennels where user_id = :userId", nativeQuery = true)
    List<InvoiceKennel> findAllByUser(String userId);

    @Query(value = "select sum(total_amount) from invoice_kennels where status = 1 and created_at between :start and :end", nativeQuery = true)
    int getRevenue(String start, String end);
    @Query(value = "select sum(total_amount) from invoice_kennels where doctor_id = :doctorId and status = 1 and created_at between :start and :end", nativeQuery = true)
    int getRevenueByDoctor(String start, String end, String doctorId);
}
