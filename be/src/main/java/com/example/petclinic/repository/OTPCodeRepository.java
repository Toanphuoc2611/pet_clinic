package com.example.petclinic.repository;

import com.example.petclinic.entity.OTPCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface OTPCodeRepository extends JpaRepository<OTPCode, Integer> {
    @Query(value = "SELECT COUNT(*) FROM otp_codes WHERE email = :email AND otp = :otp AND is_verify = false AND expired_at > NOW()", nativeQuery = true)
    int verifyOTP(String otp, String email);
}
