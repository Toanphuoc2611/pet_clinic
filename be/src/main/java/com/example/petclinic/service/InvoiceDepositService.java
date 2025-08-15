package com.example.petclinic.service;

import com.example.petclinic.dto.request.invoicedeposit.CreateInvoiceDepositReq;
import com.example.petclinic.dto.request.kennel.KennelNotification;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.invoice.InvoiceDepoAppointResp;
import com.example.petclinic.dto.response.invoice.InvoiceDepoKennelResp;
import com.example.petclinic.entity.*;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.*;
import com.google.firebase.messaging.FirebaseMessagingException;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.context.annotation.Lazy;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
@Transactional
public class InvoiceDepositService {
    static final int PERCENT = 20;
    InvoiceDepositRepository repository;
    UserRepository userRepository;
    KennelRepository kennelRepository;
    @Lazy
    AppointmentService appointmentService;
    ServiceKennelRepository serviceKennelRepository;
    UserCreditService userCreditService;
    KennelDetailRepository kennelDetailRepository;
    PushNotificationService pushNotificationService;
    SimpMessagingTemplate messagingTemplate;

    @Scheduled(fixedRate = 300000) // 5 minutes
    public void updateExpiredInvoices() {
        repository.updateExpiredInvoices();
    }

    public ApiResponse<Boolean> paymentInvoice(int id)  {
        Appointment appointment = appointmentService.findAppointmentByInvoice(id);
        KennelDetail kennelDetail = kennelDetailRepository.findKennelByInvoiceDeposit(id);
        InvoiceDeposit invoiceDeposit;
        if (appointment != null) {
            if (appointment.getInvoiceDeposit().getExpiredAt().before(new Timestamp(System.currentTimeMillis()))) {
                return ApiResponse.<Boolean>builder().code(200).message("Payment invoice expired payment failure").data(false).build();
            }
            invoiceDeposit = appointment.getInvoiceDeposit();
            userCreditService.paymentCreditAppo(appointment.getUser().getId(), invoiceDeposit.getDeposit(), appointment.getId());
            appointmentService.updateStatusAppoinment(appointment.getId() + "", "1");
            invoiceDeposit.setStatus(1);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            String formattedTime = appointment.getAppointmentTime().toLocalDateTime().format(formatter);
            pushNotificationService.sendPushNotification(
                    "Lịch hẹn khám bệnh",
                    "Bạn đã xác nhận thành công lịch hẹn khám bệnh vào lúc " + formattedTime,
                    new String[] {appointment.getUser().getId()});
        } else if (kennelDetail != null) {
            if (kennelDetail.getInvoiceDeposit().getExpiredAt().before(new Timestamp(System.currentTimeMillis()))) {
                return ApiResponse.<Boolean>builder().code(200).message("Payment invoice expired payment failure").data(false).build();
            }
            invoiceDeposit = kennelDetail.getInvoiceDeposit();
            userCreditService.paymentCreditKennel(kennelDetail.getUser().getId(), invoiceDeposit.getDeposit(), kennelDetail.getId());
            kennelDetail.setStatus(1);
            kennelDetailRepository.save(kennelDetail);
            sendNotifyClient(kennelDetail);
            invoiceDeposit.setStatus(1);
            pushNotificationService.sendPushNotification(
                    "Lịch lưu chuồng",
                    "Bạn đã xác nhận thành công lịch lưu chuồng",
                    new String[] {kennelDetail.getUser().getId()});
        } else {
            return ApiResponse.<Boolean>builder().code(200).message("Payment invoice deposit failure").data(false).build();
        }

        repository.save(invoiceDeposit);
        return ApiResponse.<Boolean>builder().code(200).message("Payment invoice deposit success").data(true).build();
    }

    public ApiResponse<List<InvoiceDeposit>> getInvoiceDepositUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        List<InvoiceDeposit> list = repository.getInvoiceDepositByUser(userId);
        return  ApiResponse.<List<InvoiceDeposit>>builder().message("List invoice deposit").code(200).data(list).build();
    }

    public InvoiceDeposit createInvoice(CreateInvoiceDepositReq req) {
        InvoiceDeposit invoiceDeposit = new InvoiceDeposit();
        invoiceDeposit.setUser(req.getUser());
        invoiceDeposit.setTotalAmount(req.getTotalAmount());
        int deposit = req.getTotalAmount() * 20 / 100;
        invoiceDeposit.setDeposit(deposit);
        invoiceDeposit.setStatus(0);
        repository.save(invoiceDeposit);
        return invoiceDeposit;
    }

    public ApiResponse<InvoiceDepoKennelResp> getInvoiceDepoKennel(int id) {
        InvoiceDeposit invoiceDeposit = repository.findById(id).orElseThrow(() -> new AppException(ErrorCode.INVOICE_NOT_EXISTED));
        KennelDetail kennelDetail = kennelDetailRepository.findKennelByInvoiceDeposit(id);
        ServiceKennel serviceKennel = serviceKennelRepository.findById(1).orElseThrow(() -> new AppException(ErrorCode.SERVICE_KENNEL_NOT_EXISTED));
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        String createdAtStr = invoiceDeposit.getCreatedAt().toLocalDateTime().format(formatter);
        String inTimeStr = kennelDetail.getInTime().toLocalDateTime().format(formatter);
        String outTimeStr = kennelDetail.getOutTime().toLocalDateTime().format(formatter);

        InvoiceDepoKennelResp response = new InvoiceDepoKennelResp(
                invoiceDeposit.getId(),
                invoiceDeposit.getInvoiceCode(),
                createdAtStr,
                invoiceDeposit.getTotalAmount(),
                inTimeStr,
                outTimeStr,
                serviceKennel.getPrice(),
                invoiceDeposit.getStatus(),
                invoiceDeposit.getDeposit(),
                kennelDetail.getKennel(),
                invoiceDeposit.getUser(),
                kennelDetail.getPet()
        );
        return ApiResponse.<InvoiceDepoKennelResp>builder().code(200).message("Get invoice deposit kennel success").data(response).build();
    }

    public ApiResponse<InvoiceDepoAppointResp> getInvoiceDepoAppoint(int id) {
        InvoiceDeposit invoiceDeposit = repository.findById(id).orElseThrow(() -> new AppException(ErrorCode.INVOICE_NOT_EXISTED));
        Appointment appointment = appointmentService.findAppointmentByInvoice(id);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        String createdAtStr = invoiceDeposit.getCreatedAt().toLocalDateTime().format(formatter);
        String appointmentTimeStr = appointment.getAppointmentTime().toLocalDateTime().format(formatter);
        InvoiceDepoAppointResp response = new InvoiceDepoAppointResp(
                invoiceDeposit.getId(),
                invoiceDeposit.getInvoiceCode(),
                createdAtStr,
                invoiceDeposit.getTotalAmount(),
                appointmentTimeStr,
                appointment.getServices(),
                invoiceDeposit.getStatus(),
                invoiceDeposit.getDeposit(),
                invoiceDeposit.getUser()
        );
        return ApiResponse.<InvoiceDepoAppointResp>builder()
                .code(200).message("Get invoice deposit appointment success").data(response).build();
    }

    public void sendNotifyClient(KennelDetail kennelDetail) {
        KennelNotification kennelNotification = new KennelNotification(kennelDetail.getUser().getId(), kennelDetail.getDoctor().getId());
        messagingTemplate.convertAndSend("/topic/kennels", kennelNotification);
    }


}
