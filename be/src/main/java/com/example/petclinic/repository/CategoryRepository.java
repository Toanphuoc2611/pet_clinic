package com.example.petclinic.repository;

import com.example.petclinic.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Integer> {

    @Query(value = "select * from categories", nativeQuery = true)
    List<Category> getAllCategories();
}
