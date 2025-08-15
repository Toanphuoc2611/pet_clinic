package com.example.petclinic.repository;

import com.example.petclinic.entity.LogUserCredit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
public interface LogUserCreditRepository extends JpaRepository<LogUserCredit, Integer> {
    @Query(value = "select * from log_user_credits where user_id = :userId", nativeQuery = true)
    List<LogUserCredit> getLogByUserId(String userId);
}
