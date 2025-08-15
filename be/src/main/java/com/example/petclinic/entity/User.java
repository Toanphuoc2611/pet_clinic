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
import java.time.LocalDate;

@Entity
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    String id;
    @Column(name = "fullname")
    String fullname;
    @Column(name = "birthday")
    LocalDate birthday;
    @Column(name = "gender")
    int gender; // 0: male, 1: female
    @Column(name = "phone_number", nullable = false, unique = true)
    String phoneNumber;
    @Column(name = "address")
    String address;

    @CreationTimestamp
    @Column(name = "created_at",  nullable = false, updatable = false)
    Timestamp createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    Timestamp updatedAt;

    @Column(name = "avatar")
    String avatar;
}
