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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

@Entity
@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "invoice_kennels")
public class InvoiceKennel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    String invoiceCode;
    @CreationTimestamp
    @Column(name ="created_at", nullable = false, updatable = false)
    Timestamp createdAt;
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    Timestamp updatedAt;
    @Column(name = "total_amount")
    int totalAmount;
    @ManyToOne
    @JoinColumn(name = "pet_id")
    Pet pet;

    @ManyToOne
    @JoinColumn(name = "user_id")
    User user;

    @ManyToOne
    @JoinColumn(name = "doctor_id")
    User doctor;

    int status;

    @ManyToOne
    @JoinColumn(name = "id_kennel_detail")
    KennelDetail kennelDetail;

    @PrePersist
    public void prePersist() {
        if (this.invoiceCode == null || this.invoiceCode.isEmpty()) {
            String generatedId = "#K"+ String.format("%03d", new Random().nextInt(10)) +
                    LocalDateTime.now().format(DateTimeFormatter.ofPattern("ddMMHHmmss"));

            this.invoiceCode = generatedId;
        }
    }
}
