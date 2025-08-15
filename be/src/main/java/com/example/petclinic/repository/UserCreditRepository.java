package com.example.petclinic.repository;

import com.example.petclinic.entity.UserCredit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface UserCreditRepository extends JpaRepository<UserCredit, Integer> {

    @Query(value = "select * from user_credits where user_id = :userId", nativeQuery = true)
    UserCredit findByUserId(String userId);
}
