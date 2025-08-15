package com.example.petclinic.repository;

import com.example.petclinic.entity.Kennel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.sql.Timestamp;
import java.util.List;

public interface KennelRepository extends JpaRepository<Kennel, Integer> {

    @Query(value = "SELECT * from kennels where status = 1", nativeQuery = true)
    List<Kennel> getAllKennel();

    @Query(value = "SELECT * from kennels where id  NOT IN (" +
            "select kennel_id from kennel_details where status <= 2)", nativeQuery = true)
    List<Kennel> getKennelInvalid();
}
