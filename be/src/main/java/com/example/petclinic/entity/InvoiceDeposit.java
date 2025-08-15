package com.example.petclinic.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

@Entity
@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "invoice_deposits")
public class InvoiceDeposit {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;

    String invoiceCode;

    int deposit;

    @Column(name = "total_amount")
    int totalAmount;

    @CreationTimestamp
    @Column(name ="created_at", nullable = false, updatable = false)
    Timestamp createdAt;
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    Timestamp updatedAt;
    @Column(name ="expired_at", nullable = false, updatable = false)
    Timestamp expiredAt;
    @JoinColumn(name = "user_id")
    @ManyToOne
    User user;
    int status;
    @Column(name = "type")
    int type; // type of invoice_deposit:  (0: invoice_deposit of kennel, 1: invoice_deposit of appointment)

    @PrePersist
    public void prePersist() {
        if (this.invoiceCode == null || this.invoiceCode.isEmpty()) {
            String generatedId = "#"+ String.format("%03d", new Random().nextInt(10)) +
                    LocalDateTime.now().format(DateTimeFormatter.ofPattern("ddMMHHmmss"));

            this.invoiceCode = generatedId;
        }
        if (this.createdAt == null) {
            this.createdAt = Timestamp.from(Instant.now());
        }
        if (this.expiredAt == null) {
            this.expiredAt = Timestamp.from(this.createdAt.toInstant().plusSeconds(30 * 60));
        }
    }
}
