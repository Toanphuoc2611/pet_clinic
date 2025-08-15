package com.example.petclinic.repository;

import com.example.petclinic.entity.ServiceClinic;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ServiceRepository extends JpaRepository<ServiceClinic, Integer> {
    List<ServiceClinic> findAllByStatus(int status);
}
