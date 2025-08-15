package com.example.petclinic.mapper;

import com.example.petclinic.dto.response.kennel.KennelDetailDto;
import com.example.petclinic.entity.KennelDetail;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;

public class KennelDetailMapper {
    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    public static KennelDetailDto toDTO(KennelDetail kd) {
        return KennelDetailDto.builder()
                .id(kd.getId())
                .pet(kd.getPet())
                .user(kd.getUser())
                .doctor(kd.getDoctor())
                .kennel(kd.getKennel())
                .invoiceDeposit(kd.getInvoiceDeposit())
                .inTime(convert(kd.getInTime()))
                .outTime(convert(kd.getOutTime()))
                .actualCheckin(convert(kd.getActualCheckin()))
                .actualCheckout(convert(kd.getActualCheckout()))
                .createdAt(convert(kd.getCreatedAt()))
                .updatedAt(convert(kd.getUpdatedAt()))
                .status(kd.getStatus())
                .note(kd.getNote())
                .build();
    }

    private static LocalDateTime convert(Timestamp ts) {
        return ts == null ? null : ts.toInstant().atZone(VIETNAM_ZONE).toLocalDateTime();
    }
}