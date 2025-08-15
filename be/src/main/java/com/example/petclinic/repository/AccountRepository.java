package com.example.petclinic.repository;

import com.example.petclinic.entity.Account;
import com.example.petclinic.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface AccountRepository extends JpaRepository<Account, Integer> {
    Optional<Account> findByEmail(String email);
    @Query("SELECT u FROM User u LEFT JOIN Account a ON a.user = u WHERE a.role.id = 1 OR a.id IS NULL")
    List<User> findAllUsersWithRole1OrNoAccount();

    List<Account> findAllByRoleIdNot(int roleId);
}
