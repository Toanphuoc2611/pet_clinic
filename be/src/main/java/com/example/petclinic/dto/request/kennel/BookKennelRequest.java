package com.example.petclinic.dto.request.kennel;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;

@Data
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BookKennelRequest {
    String inTime;
    String outTime;
    String note;
    String doctorId;
    String petId;
    int kennelId;
}
