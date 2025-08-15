package com.example.petclinic.repository;

import com.example.petclinic.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;
import java.util.List;

public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByPhoneNumber(String phoneNumber);
    @Query(value = "SELECT u.* FROM users u INNER JOIN accounts a ON u.id = a.user_id WHERE a.role_id = 3 AND status = 1", nativeQuery = true)
    List<User> findUsersByRole();

    @Query(value = "select count(*) from users", nativeQuery = true)
    int totalUser();

    @Query(value = "select * from users", nativeQuery = true)
    List<User> getListUsers();

    @Query(value = "select * from users where fullname like %:search%", nativeQuery = true)
    List<User> searchUsersByFullname(String search);
}
