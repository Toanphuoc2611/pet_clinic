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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

@Entity
@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "pets")
public class Pet {
    @Id
    String id;
    @Column(name = "name", nullable = false)
    String name;
    @Column(name = "birthday")
    LocalDate birthday;
    @Column(name = "type")
    String type;
    @Column(name = "breed")
    String breed;
    @Column(name = "color")
    String color;
    int gender; // 0: male, 1: female
    double weight;
    @Column(name = "is_neutered")
    int isNeutered; // 0: false, 1: true
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    Timestamp createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    Timestamp updatedAt;

    String note;
    @Column(name = "avatar")
    String avatar;
    @ManyToOne
    @JoinColumn(name = "user_id")
    User user;

    int status = 1; // 1: valid, 0: invalid

    @PrePersist
    public void prePersist() {
        if (this.id == null || this.id.isEmpty()) {
            String generatedId = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) +
                    String.format("%03d", new Random().nextInt(1000));
            this.id = generatedId;
        }
    }
}
