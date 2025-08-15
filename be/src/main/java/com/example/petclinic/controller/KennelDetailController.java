package com.example.petclinic.controller;


import com.example.petclinic.dto.request.kennel.BookKennelRequest;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.invoice.InvoiceKennelResp;
import com.example.petclinic.dto.response.kennel.KennelDetailDto;
import com.example.petclinic.entity.KennelDetail;
import com.example.petclinic.service.KennelDetailService;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.web.bind.annotation.*;

import java.util.List;
@RestController
@RequestMapping("/kennels/book")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class KennelDetailController {
    KennelDetailService kennelDetailService;

    @GetMapping
    public ApiResponse<List<KennelDetailDto>> getAllKennelByUser() {
        return kennelDetailService.getAllKennelByUser();
    }

    @PostMapping
    public ApiResponse<Boolean> bookKennel(@RequestBody BookKennelRequest request) {
        return kennelDetailService.bookKennel(request);
    }

    @PutMapping("/cancel/{id}")
    public ApiResponse<KennelDetailDto> cancelBookKennel(@PathVariable String id) {
        return kennelDetailService.cancelKennel(id);
    }

    @GetMapping("/doctor/today")
    public ApiResponse<List<KennelDetailDto>> getKennelToday() {
        return kennelDetailService.getKennelToday();
    }

    @GetMapping("/pet/{id}")
    public ApiResponse<List<KennelDetailDto>> getKennelByPetId(@PathVariable String id) {
        return kennelDetailService.getKennelByPetId(id);
    }

    @PutMapping("/{id}")
    public ApiResponse<KennelDetailDto> updateKennelStatus(@PathVariable String id, @RequestParam String status) {
        return kennelDetailService.updateKennelStatus(Integer.parseInt(id), Integer.parseInt(status));
    }

    @PutMapping("/complete/{id}")
    public ApiResponse<InvoiceKennelResp> completeKennelBooking(@PathVariable String id) {
        return kennelDetailService.completeKennelBooking(Integer.parseInt(id));
    }
}