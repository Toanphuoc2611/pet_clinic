package com.example.petclinic.repository;

import com.example.petclinic.entity.Pet;
import com.example.petclinic.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
public interface PetRepository extends JpaRepository<Pet, String> {
    @Query(value = "Select * From pets where user_id = :userId and status = 1", nativeQuery = true)
    List<Pet> findAllByUserId(@Param("userId") String userId);

    @Query(value = "select * from pets where user_id = :userId and name like %:name% and status = 1", nativeQuery = true)
    List<Pet> findAllByUserIdAndName(@Param("userId") String userId, @Param("name") String name);

    @Query(value = "select count(*) from pets", nativeQuery = true)
    int totalPets();

    @Query(value = "select * from pets where user_id = :userId and " +
            "id not in (select pet_id from kennel_details where status IN (0, 1, 2))", nativeQuery = true)
    List<Pet> getPetByUserValidKennel(String userId);
}
