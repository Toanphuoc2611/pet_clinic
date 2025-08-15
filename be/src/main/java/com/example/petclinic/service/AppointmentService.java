package com.example.petclinic.service;

import com.example.petclinic.dto.request.appointment.AppointmentCreation;
import com.example.petclinic.dto.request.appointment.AppointmentNotifycation;
import com.example.petclinic.dto.request.invoicedeposit.CreateInvoiceDepositReq;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.*;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.*;
import com.google.firebase.messaging.FirebaseMessagingException;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.cglib.core.Local;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.parameters.P;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@Transactional
public class AppointmentService {
    AppointmentRepository appointmentRepository;
    UserRepository userRepository;
    InvoiceDepositRepository depositRepository;
    UserCreditService userCreditService;
    SimpMessagingTemplate messagingTemplate;
    PushNotificationService pushNotificationService;

    @Scheduled(fixedRate = 300000) // 5 minutes
    public void updateExpiredInvoices()  {
        List<Appointment> appointments = appointmentRepository.findExpiredAppointments();
        for (Appointment a : appointments) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            String formattedTime = a.getAppointmentTime().toLocalDateTime().format(formatter);
            pushNotificationService.sendPushNotification(
                    "Lịch hẹn khám bệnh",
                    "Lịch bạn đăt vào lúc " + formattedTime + " đã hết hạn", new String[]{a.getUser().getId()} );
        }
        appointmentRepository.updateExpiredAppointment();
    }

    public ApiResponse<List<LocalDateTime>> getTimeAppointmentByDoctor(String doctorId) {
        List<Timestamp> timestamps = appointmentRepository.findTimeAppointmentByDoctorId(doctorId);
        ZoneId vietnamZone = ZoneId.of("Asia/Ho_Chi_Minh");

        List<LocalDateTime> listTimeAppointments = timestamps.stream()
                .map(ts -> ts.toInstant().atZone(vietnamZone).toLocalDateTime())
                .collect(Collectors.toList());
        return ApiResponse.<List<LocalDateTime>>builder().data(listTimeAppointments).code(200).message("List appointment time ").build();
    }

    public ApiResponse<Appointment> createAppointment(AppointmentCreation request) throws FirebaseMessagingException {
        boolean appointmentExisted = appointmentRepository.existsAppointmentByAppointmentTimeAndDoctorId(request.getAppointmentTime(), request.getDoctorId());
        if (appointmentExisted) {
            return ApiResponse.<Appointment>builder().code(200).message("Appointment existed").build();
        }
        User user;
        if (request.getUserId() == null) {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
             user = userRepository.findById(authentication.getName())
                    .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        } else {
            user = userRepository.findById(request.getUserId())
                    .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        }
        User doctor = userRepository.findById(request.getDoctorId())
                .orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        int totalPrice = 0;
        for (ServiceClinic service : request.getServices()) {
            totalPrice += service.getPrice();
        }
        InvoiceDeposit invoiceDeposit = createInvoice(new CreateInvoiceDepositReq(user, totalPrice));
        if (invoiceDeposit == null) {
            return ApiResponse.<Appointment>builder().code(401).message("Create Invoice deposit failure").build();
        }
        Appointment appointment = new Appointment();
        appointment.setUser(user);
        appointment.setDoctor(doctor);
        appointment.setServices(request.getServices());
        appointment.setAppointmentTime(request.getAppointmentTime());
        appointment.setStatus(request.getStatus());
        appointment.setInvoiceDeposit(invoiceDeposit);
        appointmentRepository.save(appointment);
        pushNotificationService.sendPushNotification(
                "Lịch hẹn khám bệnh",
                "Bạn đã đặt lịch hẹn thành công vui lòng thanh toán để xác nhận",
                new String[]{appointment.getUser().getId()} );
        return ApiResponse.<Appointment>builder().code(200).message("Create appointment success").data(appointment).build();
    }

    public ApiResponse<List<Appointment>> getAllAppointments() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        List<Appointment> listAppointments = appointmentRepository.findAllByUser(authentication.getName());
        return ApiResponse.<List<Appointment>>builder().code(200).message("Get list appointment success").data(listAppointments).build();
    }

    public ApiResponse<List<Appointment>> getAllAppointmentsByStatus(String status) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        List<Appointment> listAppointments = appointmentRepository.findAllByUserAndStatus(authentication.getName(), Integer.parseInt(status));
        return ApiResponse.<List<Appointment>>builder().code(200).message("Get list appointment success").data(listAppointments).build();
    }

    public ApiResponse<Appointment> updateStatusAppoinment(String id,String status) {
        Appointment appointment = appointmentRepository.findById(Integer.parseInt(id)).orElseThrow(() -> new AppException(ErrorCode.APPOINTMENT_NOT_EXISTED));
        appointment.setStatus(Integer.parseInt(status));
        appointmentRepository.save(appointment);
        sendNotifyAppointment(appointment);
        return ApiResponse.<Appointment>builder().code(200).message("UPDATED STATUS APPOINTMENT SUCCESS").data(appointment).build();
    }

    public ApiResponse<Appointment> getAppointment(String id) {
        Appointment appointment = appointmentRepository.findById(Integer.parseInt(id)).orElseThrow(() -> new AppException(ErrorCode.APPOINTMENT_NOT_EXISTED));
        return ApiResponse.<Appointment>builder().code(200).message("GET APPOINTMENT SUCCESS").data(appointment).build();
    }

    public ApiResponse<Appointment> updateAppointmentByUser(String id) {
        Appointment appointment = appointmentRepository.findById(Integer.parseInt(id)).orElseThrow(() -> new AppException(ErrorCode.APPOINTMENT_NOT_EXISTED));
        LocalDateTime appointmentTime = appointment.getAppointmentTime().toLocalDateTime();
        LocalDateTime now = LocalDateTime.now();
        Duration duration = Duration.between(now, appointmentTime);
        InvoiceDeposit invoiceDeposit = depositRepository
                .findById(appointment.getInvoiceDeposit().getId())
                .orElseThrow(() -> new AppException(ErrorCode.INVOICE_NOT_EXISTED));
        if (appointment.getStatus() != 0) {
            if (duration.toHours() > 24) {
                userCreditService.refundBalanceAppo(
                        appointment.getUser().getId(), invoiceDeposit.getDeposit(), appointment.getId());

            }
        }
        appointment.setStatus(3);
        invoiceDeposit.setStatus(2);
        depositRepository.save(invoiceDeposit);
        appointmentRepository.save(appointment);
        sendNotifyAppointment(appointment);
        return ApiResponse.<Appointment>builder().code(200).message("Cancel appointment success").data(appointment).build();
    }

    public InvoiceDeposit createInvoice(CreateInvoiceDepositReq req) {
        InvoiceDeposit invoiceDeposit = new InvoiceDeposit();
        invoiceDeposit.setUser(req.getUser());
        invoiceDeposit.setTotalAmount(req.getTotalAmount());
        int deposit = req.getTotalAmount() * 20 / 100;
        invoiceDeposit.setDeposit(deposit);
        invoiceDeposit.setStatus(0);
        invoiceDeposit.setType(1);
        depositRepository.save(invoiceDeposit);
        return invoiceDeposit;
    }

    public Appointment findAppointmentByInvoice(int invoiceDepositId) {
        Appointment appointment = appointmentRepository.findAppointmentByInvoiceDeposit(invoiceDepositId);
        return  appointment;
    }

    @PreAuthorize("hasRole('DOCTOR')")
    public ApiResponse<List<Appointment>> getAppointmentByDate(String date) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        System.out.println("Doctor get");
        String doctorId = authentication.getName();
        LocalDate today = LocalDate.parse(date);
        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime endOfDay = today.atTime(LocalTime.MAX);
        List<Appointment> appointments = appointmentRepository.getAppointmentsToday(doctorId, startOfDay.toString(), endOfDay.toString());
        return ApiResponse.<List<Appointment>>builder().message("List appointments " + date).code(200).data(appointments).build();
    }

    public void sendNotifyAppointment(Appointment appointment) {
        AppointmentNotifycation notification = new AppointmentNotifycation(appointment.getUser().getId(), appointment.getDoctor().getId());
        messagingTemplate.convertAndSend("/topic/appointments", notification);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<List<Appointment>> getAllDoctorAppointmentsInWeek(LocalDate startDate) {
        LocalDate endDate = startDate.plusDays(7);

        Timestamp startTimestamp = Timestamp.valueOf(startDate.atStartOfDay());
        Timestamp endTimestamp = Timestamp.valueOf(endDate.atStartOfDay());
        List<Appointment> appointments = appointmentRepository.findAllDoctorAppointmentsInWeek(startTimestamp, endTimestamp);
        return ApiResponse.<List<Appointment>>builder().code(200).message("Get appointment in week").data(appointments).build();
    }

    public static void main(String[] args) {

    }
}
