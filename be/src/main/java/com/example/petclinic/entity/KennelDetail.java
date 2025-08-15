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

@Entity
@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "kennel_details")
public class KennelDetail {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;

    @ManyToOne
    @JoinColumn(name = "pet_id")
    Pet pet;
    @ManyToOne
    @JoinColumn(name = "user_id")
    User user;
    @ManyToOne
    @JoinColumn(name = "doctor_id")
    User doctor;
    @Column(name = "in_time", nullable = false)
    Timestamp inTime;
    @Column(name = "out_time", nullable = false)
    Timestamp outTime;
    @Column(name = "actual_checkout")
    Timestamp actualCheckout;
    @Column(name = "actual_checkin")
    Timestamp actualCheckin;
    int status;
    String note;
    @ManyToOne
    @JoinColumn(name = "kennel_id")
    Kennel kennel;
    @CreationTimestamp
    @Column(name = "created_at",  nullable = false, updatable = false)
    Timestamp createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    Timestamp updatedAt;
    @OneToOne
    @JoinColumn(name = "invoice_deposit_id")
    InvoiceDeposit invoiceDeposit;
}
