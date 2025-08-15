package com.example.petclinic.controller;

import com.example.petclinic.dto.request.appointment.AppointmentCreation;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Appointment;
import com.example.petclinic.service.AppointmentService;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("appointments")
@RequiredArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AppointmentController {
    AppointmentService appointmentService;

    @GetMapping("/doctor")
    public ApiResponse<List<LocalDateTime>> getTimeAppointmentByDoctor(@RequestParam String id) {
        return appointmentService.getTimeAppointmentByDoctor(id);
    }

    @PostMapping("/doctor")
    public ApiResponse<Appointment> createAppointment(@RequestBody AppointmentCreation request) throws FirebaseMessagingException {
        return appointmentService.createAppointment(request);
    }

    @GetMapping()
    public ApiResponse<List<Appointment>> getAllAppointmentsByStatus(@RequestParam String status) {
        if (status.equals("-1")) return appointmentService.getAllAppointments();
        return appointmentService.getAllAppointmentsByStatus(status);
    }

    @GetMapping("/appointment/{id}")
    public ApiResponse<Appointment> getAppointment(@PathVariable String id) {
        return appointmentService.getAppointment(id);
    }

    @PutMapping("/appointment/{id}")
    public ApiResponse<Appointment> updateAppointmentByUser(@PathVariable String id) {
        return appointmentService.updateAppointmentByUser(id);
    }

    @GetMapping("/doctor/date")
    public ApiResponse<List<Appointment>> getAppointmentsByDate(@RequestParam String date) {
        return appointmentService.getAppointmentByDate(date);
    }

    @GetMapping("/doctors/week")
    public ApiResponse<List<Appointment>> getAllDoctorsAppointmentsInWeek(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate
    ) {
        return appointmentService.getAllDoctorAppointmentsInWeek(startDate);
    }
}
