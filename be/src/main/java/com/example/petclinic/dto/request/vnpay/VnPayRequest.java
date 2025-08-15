package com.example.petclinic.dto.request.vnpay;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@AllArgsConstructor
public class VnPayRequest {
    String vnp_OrderInfo;
    String invoiceCode;
    int price;
    String ipClient;
}
