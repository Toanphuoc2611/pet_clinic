package com.example.petclinic.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.hibernate.annotations.CreationTimestamp;

import java.sql.Timestamp;

@Entity
@FieldDefaults(level = AccessLevel.PRIVATE)
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "log_user_credits")
public class LogUserCredit {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    int id;

    String content;
    String action;
    @CreationTimestamp
    @Column(name = "created_at",  nullable = false, updatable = false)
    Timestamp createdAt;
    int balance_curr;
    int balance_after;
    @ManyToOne
    @JoinColumn(name = "user_id")
    User user;
}
