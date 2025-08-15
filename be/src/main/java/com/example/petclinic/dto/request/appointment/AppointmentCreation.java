package com.example.petclinic.dto.request.appointment;

import com.example.petclinic.entity.ServiceClinic;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import java.util.List;
import java.sql.Timestamp;

@Data
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AppointmentCreation {
    String userId;
    String doctorId;
    List<ServiceClinic> services;
    Timestamp appointmentTime;
    int status;
}
