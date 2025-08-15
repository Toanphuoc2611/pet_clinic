package com.example.petclinic.repository;

import com.example.petclinic.entity.InvoiceDeposit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface InvoiceDepositRepository extends JpaRepository<InvoiceDeposit, Integer> {

    @Query(value = "select * from invoice_deposits where user_id = :userId order by created_at desc ", nativeQuery = true)
    List<InvoiceDeposit> getInvoiceDepositByUser(String userId);

    @Modifying
    @Query(value = "UPDATE invoice_deposits SET status = 4 WHERE expired_at < CURRENT_TIMESTAMP AND status = 0", nativeQuery = true)
    void updateExpiredInvoices();
}
