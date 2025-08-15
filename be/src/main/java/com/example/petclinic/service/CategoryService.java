package com.example.petclinic.service;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Category;
import com.example.petclinic.repository.CategoryRepository;
import jakarta.persistence.PrePersist;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import java.util.List;
@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
public class CategoryService {
    CategoryRepository categoryRepository;

    @PreAuthorize("hasAnyRole('DOCTOR', 'ADMIN')")
    public ApiResponse<List<Category>> getAllCategories() {
        List<Category> categories = categoryRepository.getAllCategories();
        return ApiResponse.<List<Category>>builder().code(200).message("Get all categories").data(categories).build();

    }
}

