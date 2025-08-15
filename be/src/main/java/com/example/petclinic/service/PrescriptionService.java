package com.example.petclinic.service;

import com.example.petclinic.dto.request.appointment.AppointmentNotifycation;
import com.example.petclinic.dto.request.prescription.CreationPresByDoctor;
import com.example.petclinic.dto.request.prescription.CreationPrescriptionReq;
import com.example.petclinic.dto.request.prescription.PrescriptionDetailReq;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.invoice.InvoiceResponse;
import com.example.petclinic.dto.response.prescription.PrescriptionResponse;
import com.example.petclinic.entity.*;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.AppointmentRepository;
import com.example.petclinic.repository.PetRepository;
import com.example.petclinic.repository.PrescriptionRepository;
import com.example.petclinic.repository.UserRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;

@Service
@Data
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class PrescriptionService {
    PrescriptionRepository prescriptionRepository;
    PrescriptionDetailService prescriptionDetailService;
    AppointmentRepository appointmentRepository;
    MedicalRecordService medicalRecordService;
    PetRepository petRepository;
    UserRepository userRepository;
    InvoiceService invoiceService;
    MedicalHistoryService medicalHistoryService;
    SimpMessagingTemplate messagingTemplate;

    public ApiResponse<InvoiceResponse> createPrescription(CreationPrescriptionReq request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        int totalPrice = 0;
        String doctorId = authentication.getName();
        MedicalHistory medicalHistory = medicalHistoryService.findMedicalByPetId(request.getPetId());
        if (medicalHistory == null)  {
            throw new AppException(ErrorCode.PET_NOT_EXISTED);
        }
        User doctor = userRepository.findById(doctorId).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        Appointment appointment =appointmentRepository.findById(request.getIdAppointment()).orElseThrow(() -> new AppException(ErrorCode.APPOINTMENT_NOT_EXISTED));
        int statusMedicalRecord = 1;// complete
        List<PrescriptionDetailReq> details;
        if (request.getPrescriptionDetail() != null && !request.getPrescriptionDetail().isEmpty()) {
            details = request.getPrescriptionDetail();
            // Check quantity < stock medication
            for (PrescriptionDetailReq p : request.getPrescriptionDetail()) {
                if (p.getQuantity() > p.getMedication().getStockQuantity()) {
                    return ApiResponse.
                            <InvoiceResponse>builder()
                            .message("Not enough "+p.getMedication().getName() + " in stock").code(409).build();
                }
            }
        } else {
            details = new ArrayList<>();
        }
        Prescription prescription = new Prescription();
        prescription.setDoctor(doctor);
        prescription.setPet(medicalHistory.getPet());
        prescription.setDiagnose(request.getDiagnose());
        prescription.setNote(request.getNote());
        if (request.getReExamDate() != null && !request.getReExamDate().isBlank()) {
            LocalDate reExamDate = LocalDate.parse(request.getReExamDate());
            prescription.setReExamDate(reExamDate);
            statusMedicalRecord = 0; //treatment
            if (!createAppointmentReExam(reExamDate, appointment.getUser(), doctor)) {
                return ApiResponse.<InvoiceResponse>builder()
                        .message("Failed to create the re-examination appointment")
                        .code(409)
                        .build();
            }
        }

        MedicalRecord medicalRecord;
        if (appointment.getStatus() != 10) {
            medicalRecord = medicalRecordService.createMedicalRecord(medicalHistory, doctor, statusMedicalRecord);
        } else {
            medicalRecord = medicalRecordService.findMedicalRecordByPet(medicalHistory.getPet());
        }
        prescription.setMedicalRecord(medicalRecord);
        prescriptionRepository.save(prescription);
        totalPrice = prescriptionDetailService.totalPricePrescriptionDetail(details, prescription);
        Invoice invoice = invoiceService.createInvoice(appointment, totalPrice, prescription);
        InvoiceResponse response = new InvoiceResponse(
                invoice.getId(), invoice.getInvoiceCode(), invoice.getTotalAmount(),
                invoice.getUser(), invoice.getDoctor(), invoice.getStatus(),
                appointment.getServices(), details, invoice.getCreatedAt().toString()
                );
        sendNotifyAppointment(appointment);
        return ApiResponse.<InvoiceResponse>builder().message("create prescription success").code(200).data(response).build();
    }


    @PreAuthorize("hasRole('DOCTOR')")
    public ApiResponse<InvoiceResponse> createPrescriptionByDoctor(CreationPresByDoctor request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        int totalPrice = 0;
        String doctorId = authentication.getName();
        MedicalHistory medicalHistory = medicalHistoryService.findMedicalByPetId(request.getPetId());
        if (medicalHistory == null)  {
            throw new AppException(ErrorCode.PET_NOT_EXISTED);
        }
        User doctor = userRepository.findById(doctorId).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        User user = userRepository.findById(request.getUserId()).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        int statusMedicalRecord = 1;// complete
        List<PrescriptionDetailReq> details;
        if (request.getPrescriptionDetail() != null && !request.getPrescriptionDetail().isEmpty()) {
            details = request.getPrescriptionDetail();
            // Check quantity < stock medication
            for (PrescriptionDetailReq p : request.getPrescriptionDetail()) {
                if (p.getQuantity() > p.getMedication().getStockQuantity()) {
                    return ApiResponse.
                            <InvoiceResponse>builder()
                            .message("Not enough "+p.getMedication().getName() + " in stock").code(409).build();
                }
            }
        } else {
            details = new ArrayList<>();
        }
        Prescription prescription = new Prescription();
        prescription.setDoctor(doctor);
        prescription.setPet(medicalHistory.getPet());
        prescription.setDiagnose(request.getDiagnose());
        prescription.setNote(request.getNote());
        if (request.getReExamDate() != null && !request.getReExamDate().isBlank()) {
            LocalDate reExamDate = LocalDate.parse(request.getReExamDate());
            prescription.setReExamDate(reExamDate);
            statusMedicalRecord = 0; //treatment
            if (!createAppointmentReExam(reExamDate, user, doctor)) {
                return ApiResponse.<InvoiceResponse>builder()
                        .message("Failed to create the re-examination appointment")
                        .code(409)
                        .build();
            }
        }

        MedicalRecord medicalRecord = medicalRecordService.createMedicalRecord(medicalHistory, doctor, statusMedicalRecord);
        prescription.setMedicalRecord(medicalRecord);
        prescriptionRepository.save(prescription);
        totalPrice = prescriptionDetailService.totalPricePrescriptionDetail(details, prescription);
        Invoice invoice = invoiceService.createInvoiceByDoctor(request.getServices(), user, doctor
                , totalPrice, prescription);
        InvoiceResponse response = new InvoiceResponse(
                invoice.getId(), invoice.getInvoiceCode(), invoice.getTotalAmount(),
                invoice.getUser(), invoice.getDoctor(), invoice.getStatus(),
                request.getServices(), details, invoice.getCreatedAt().toString()
        );
        return ApiResponse.<InvoiceResponse>builder().message("create prescription success").code(200).data(response).build();
    }


    public boolean createAppointmentReExam(LocalDate reExamDate, User user, User doctor) {
        for (int i = 8; i <= 18; i++) {
            LocalDateTime dateTime = reExamDate.atTime(i, 0);
            Timestamp appointmentTime = Timestamp.valueOf(dateTime);
            if (!appointmentRepository.existsAppointmentByAppointmentTimeAndDoctorId(appointmentTime, doctor.getId())) {
                Appointment appointment = new Appointment();
                appointment.setStatus(10);
                appointment.setUser(user);
                appointment.setDoctor(doctor);
                appointment.setAppointmentTime(appointmentTime);
                appointmentRepository.save(appointment);
                return true;
            }
        }
        return false;
    }

    public ApiResponse<List<PrescriptionResponse>> getPrescriptionByMedicalRecord(String medicalRecordId) {
        MedicalRecord medicalRecord = medicalRecordService.findMedicalRecordById(Integer.parseInt(medicalRecordId));
        List<Prescription> prescriptions = prescriptionRepository.findAllByMedicalRecord(medicalRecord);
        List<PrescriptionResponse> prs = new ArrayList<>();
        for (Prescription p : prescriptions) {
            String reExamDate = null;
            if (p.getReExamDate() != null) {
                reExamDate = p.getReExamDate().toString();
            }
            List<PrescriptionDetail> listPd = prescriptionDetailService.findAllByPrescription(p);
            List<PrescriptionDetailReq> list = new ArrayList<>();
            for (PrescriptionDetail pd : listPd) {
                PrescriptionDetailReq pdr = new PrescriptionDetailReq(pd.getDosage(), pd.getQuantity(), pd.getMedication());
                list.add(pdr);
            }
            PrescriptionResponse pr = new PrescriptionResponse(p.getId(), p.getDoctor(),
                    p.getDiagnose(), reExamDate,p.getCreatedAt().toString(), p.getNote(), list);
            prs.add(pr);
        }
        return ApiResponse.<List<PrescriptionResponse>>builder().code(200).message("Get list prescription").data(prs).build();
    }
    public void sendNotifyAppointment(Appointment appointment) {
        AppointmentNotifycation notification = new AppointmentNotifycation(appointment.getUser().getId(), appointment.getDoctor().getId());
        messagingTemplate.convertAndSend("/topic/appointments", notification);
    }
}
