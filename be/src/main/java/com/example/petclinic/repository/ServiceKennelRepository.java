package com.example.petclinic.repository;

import com.example.petclinic.entity.ServiceKennel;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ServiceKennelRepository extends JpaRepository<ServiceKennel, Integer> {
}
