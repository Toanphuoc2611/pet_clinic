package com.example.petclinic.entity;


import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.CreationTimestamp;

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
@Table(name = "otp_codes")
public class OTPCode {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;
    @Column(name = "email")
    String email;
    String otp;
    @CreationTimestamp
    @Column(name = "created_at", updatable = false, nullable = false)
    Timestamp createdAt;

    @Column(name = "expired_at", updatable = false, nullable = false)
    Timestamp expiredAt;

    @Column(name = "is_verify")
    boolean isVerify;

    @PrePersist
    public void prePersist() {
        if (this.createdAt == null) {
            this.createdAt = Timestamp.from(Instant.now());
        }
        if (this.expiredAt == null) {
            this.expiredAt = Timestamp.from(this.createdAt.toInstant().plusSeconds(5 * 60)); // otp 5 minutes
        }
    }
}
