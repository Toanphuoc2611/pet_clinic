package com.example.petclinic.controller;

import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.address.District;
import com.example.petclinic.dto.response.address.Province;
import com.example.petclinic.dto.response.address.Ward;
import com.example.petclinic.service.AddressService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/address")
@RequiredArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AddressController {
    AddressService addressService;

    @GetMapping("/provinces")
    public ApiResponse<List<Province>> getProvince() throws IOException {
        return addressService.getProvince();
    }

    @GetMapping("/districts/{id}")
    public ApiResponse<List<District>> getDistrict(@PathVariable String id) throws IOException {
        return addressService.getDistrict(Integer.parseInt(id));
    }

    @GetMapping("/wards/{id}")
    public ApiResponse<List<Ward>> getWard(@PathVariable String id) throws IOException {
        return addressService.getWard(Integer.parseInt(id));
    }
}
