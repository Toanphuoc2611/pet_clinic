package com.example.petclinic.controller;

import com.example.petclinic.dto.request.kennel.CreationKennel;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Kennel;
import com.example.petclinic.service.KennelService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;
@RestController
@RequestMapping("/kennels")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class KennelController {
    KennelService kennelService;

    @GetMapping
    public ApiResponse<List<Kennel>> getAllKennelValid() {
        return kennelService.getKennelInvalid();
    }
    @GetMapping("/all")
    public ApiResponse<List<Kennel>> getAllKennel() {
        return kennelService.getAllKennel();
    }
    @PutMapping("/{id}")
    public ApiResponse<Boolean> updateStatusKennel(@PathVariable String id, @RequestParam String status) {
        return kennelService.updateStatusKennel(Integer.parseInt(id), Integer.parseInt(status));
    }

    @PostMapping()
    public ApiResponse<Boolean> addKennel(@RequestBody CreationKennel request) {
        return kennelService.addKennel(request);
    }
}
