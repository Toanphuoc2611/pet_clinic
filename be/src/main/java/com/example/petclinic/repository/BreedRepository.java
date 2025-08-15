package com.example.petclinic.repository;

import com.example.petclinic.entity.Breed;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface BreedRepository extends JpaRepository<Breed, Integer> {

    @Query(value = "SELECT * from breeds where species_id = :species_id", nativeQuery = true)
    List<Breed> findAllBySpeciesId(int species_id);
}
