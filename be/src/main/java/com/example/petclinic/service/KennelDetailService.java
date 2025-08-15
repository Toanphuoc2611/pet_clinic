package com.example.petclinic.service;

import com.example.petclinic.dto.request.invoicedeposit.CreateInvoiceDepositReq;
import com.example.petclinic.dto.request.kennel.BookKennelRequest;
import com.example.petclinic.dto.request.kennel.KennelNotification;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.invoice.InvoiceKennelResp;
import com.example.petclinic.dto.response.kennel.KennelDetailDto;
import com.example.petclinic.entity.*;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.mapper.KennelDetailMapper;
import com.example.petclinic.repository.*;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
@Transactional
public class KennelDetailService {
    KennelDetailRepository repository;
    InvoiceDepositService invoiceDepositService;
    UserRepository userRepository;
    ServiceKennelRepository serviceKennelRepository;
    PetRepository petRepository;
    KennelRepository kennelRepository;
    UserCreditService userCreditService;
    InvoiceKennelService invoiceKennelService;
    SimpMessagingTemplate messagingTemplate;
    PushNotificationService pushNotificationService;

    @Scheduled(fixedRate = 300000) // 5 minutes
    public void updateExpiredKennels() {
        repository.updateExpiredKennels();
    }


    public ApiResponse<List<KennelDetailDto>> getAllKennelByUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        List<KennelDetail> list = repository.findAllByUser(userId);
        List<KennelDetailDto> dtoList = list.stream()
                .map(KennelDetailMapper::toDTO)
                .toList();
        return ApiResponse.<List<KennelDetailDto>>builder().code(200).message("Get success").data(dtoList).build();
    }

    public ApiResponse<Boolean> bookKennel(BookKennelRequest request) {
        if (repository.findOverlappingBookings(request.getKennelId()) > 0) {
            return ApiResponse.<Boolean>builder().code(200).message("Kennel is using").data(false).build();
        }
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        User user = userRepository.findById(userId).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        ServiceKennel serviceKennel = serviceKennelRepository.findById(1).orElseThrow(() -> new AppException(ErrorCode.SERVICE_KENNEL_NOT_EXISTED));
        Pet pet = petRepository.findById(request.getPetId()).orElseThrow(() -> new AppException(ErrorCode.PET_NOT_EXISTED));
        User doctor = userRepository.findById(request.getDoctorId()).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        Kennel kennel = kennelRepository.findById(request.getKennelId()).orElseThrow(() -> new AppException(ErrorCode.KENNEL_NOT_EXISTED));
        if (kennel.getStatus() != 1) {
            return ApiResponse.<Boolean>builder().code(200).message("Kennel invalid").data(false).build();
        }
        KennelDetail kennelDetail = new KennelDetail();
        kennelDetail.setKennel(kennel);
        kennelDetail.setNote(request.getNote());
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        Timestamp inTime = Timestamp.valueOf(LocalDateTime.parse(request.getInTime(), formatter));
        Timestamp outTime = Timestamp.valueOf(LocalDateTime.parse(request.getOutTime(), formatter));
        long millisDiff = outTime.getTime() - inTime.getTime();
        int days = (int) TimeUnit.MILLISECONDS.toDays(millisDiff);
        if (days == 0) {
            days = 1;
        }
        double basePricePerDay = serviceKennel.getPrice();
        double totalPrice = days * basePricePerDay * kennel.getPriceMultiplier();
        CreateInvoiceDepositReq createInvoiceDepositReq = new CreateInvoiceDepositReq(user,(int) totalPrice) ;
        InvoiceDeposit invoiceDeposit = invoiceDepositService.createInvoice(createInvoiceDepositReq);
        kennelDetail.setInTime(inTime);
        kennelDetail.setOutTime(outTime);
        kennelDetail.setUser(user);
        kennelDetail.setDoctor(doctor);
        kennelDetail.setPet(pet);
        kennelDetail.setStatus(0);
        kennelDetail.setInvoiceDeposit(invoiceDeposit);
        repository.save(kennelDetail);
        sendNotifyClient(kennelDetail);
        return ApiResponse.<Boolean>builder().code(200).message("Book kennel success").data(true).build();
    }

    public ApiResponse<KennelDetailDto> cancelKennel(String id) {
        KennelDetail kennelDetail = repository.findById(Integer.parseInt(id))
                .orElseThrow(() -> new AppException(ErrorCode.KENNEL_NOT_EXISTED));
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();;
        String userId = authentication.getName();
        Timestamp inTime = kennelDetail.getInTime();
        if (kennelDetail.getStatus() != 0) {
            if (!inTime.before(Timestamp.valueOf(LocalDateTime.now().minusDays(1)))) {
                userCreditService.refundBalanceKennel(
                        userId, kennelDetail.getInvoiceDeposit().getDeposit(), kennelDetail.getId());
            }
        }
        kennelDetail.setStatus(4);
        repository.save(kennelDetail);
        sendNotifyClient(kennelDetail);
        KennelDetailDto dto = KennelDetailMapper.toDTO(kennelDetail);
        return ApiResponse.<KennelDetailDto>builder().code(200).message("Cancel book kennel success").data(dto).build();
    }

    @PreAuthorize("hasRole('DOCTOR')")
    public ApiResponse<List<KennelDetailDto>> getKennelToday() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String doctorId = authentication.getName();
        List<KennelDetail> list = repository.getKennelToday(doctorId);
        List<KennelDetailDto> dtoList = list.stream()
                .map(KennelDetailMapper::toDTO)
                .toList();
        return ApiResponse.<List<KennelDetailDto>>builder().code(200).message("Doctor's kennel today").data(dtoList).build();
    }

    public ApiResponse<List<KennelDetailDto>> getKennelByPetId(String petId) {
        List<KennelDetail> list = repository.getKennelByPetId(petId);
        List<KennelDetailDto> dtoList = list.stream()
                .map(KennelDetailMapper::toDTO)
                .toList();
        return ApiResponse.<List<KennelDetailDto>>builder().code(200).message("Doctor's kennel today").data(dtoList).build();
    }

    @PreAuthorize("hasRole('DOCTOR')")
    public ApiResponse<KennelDetailDto> updateKennelStatus(int id, int status) {
        KennelDetail kennelDetail = repository.findById(id).orElseThrow(() -> new AppException(ErrorCode.KENNEL_NOT_EXISTED));

        if (status == 2) {
            Timestamp now = new Timestamp(System.currentTimeMillis());
            if (kennelDetail.getInTime() != null && kennelDetail.getInTime().after(now)) {
                return ApiResponse.<KennelDetailDto>builder()
                        .code(400)
                        .message("Cannot update status: inTime is in the future")
                        .data(null)
                        .build();
            }
            kennelDetail.setActualCheckin(new Timestamp(System.currentTimeMillis()));
        }
        kennelDetail.setStatus(status);
        repository.save(kennelDetail);
        sendNotifyClient(kennelDetail);
        KennelDetailDto dto = KennelDetailMapper.toDTO(kennelDetail);
        pushNotificationService.sendPushNotification(
                "Lịch hẹn lưu chuồng",
                "Thú cưng của bạn đã được lưu chuồng vào lúc " + dto.getActualCheckin(), new String[]{dto.getUser().getId()} );
        return ApiResponse.<KennelDetailDto>builder().code(200).message("Update status kennel success").data(dto).build();
    }

    @PreAuthorize("hasRole('DOCTOR')")
    public ApiResponse<InvoiceKennelResp> completeKennelBooking(int id) {
        KennelDetail kennelDetail = repository.findById(id).orElseThrow(() -> new AppException(ErrorCode.KENNEL_NOT_EXISTED));
        kennelDetail.setStatus(3);
        kennelDetail.setActualCheckout(new Timestamp(System.currentTimeMillis()));
        repository.save(kennelDetail);
        ServiceKennel serviceKennel = serviceKennelRepository.findById(1).orElseThrow(() -> new AppException(ErrorCode.SERVICE_KENNEL_NOT_EXISTED));
        int numDays = calculateNumDay(kennelDetail.getActualCheckin(), kennelDetail.getActualCheckout());
        int totalAmount = (int) (numDays * serviceKennel.getPrice() * kennelDetail.getKennel().getPriceMultiplier());
        InvoiceKennel invoiceKennel = invoiceKennelService.createInvoiceKennel(
                kennelDetail.getPet(), kennelDetail.getDoctor(), totalAmount, kennelDetail
        );
        int deposit = 0;
        if (kennelDetail.getInvoiceDeposit() != null) {
            deposit = kennelDetail.getInvoiceDeposit().getDeposit();
        }
        InvoiceKennelResp invoiceKennelResp = new InvoiceKennelResp(
                invoiceKennel.getId(), invoiceKennel.getInvoiceCode(), invoiceKennel.getStatus(),
                invoiceKennel.getTotalAmount(),deposit, invoiceKennel.getCreatedAt().toString(), invoiceKennel.getDoctor(),
                invoiceKennel.getUser(), invoiceKennel.getKennelDetail()
        );
        sendNotifyClient(kennelDetail);
        pushNotificationService.sendPushNotification(
                "Lịch hẹn lưu chuồng",
                "Thú cưng của bạn đã được xuất chuồng vào lúc " + kennelDetail.getActualCheckout(), new String[]{kennelDetail.getUser().getId()} );
        return ApiResponse.<InvoiceKennelResp>builder().code(200).message("Check-out success").data(invoiceKennelResp).build();
    }

    private int calculateNumDay(Timestamp checkin, Timestamp checkout) {
        long millisDiff = checkout.getTime() - checkin.getTime();
        long millisPerDay = 24 * 60 * 60 * 1000;

        int numDay = (int) Math.ceil((double) millisDiff / millisPerDay);
        return Math.max(numDay, 1);
    }

    public void sendNotifyClient(KennelDetail kennelDetail) {
        KennelNotification kennelNotification = new KennelNotification(kennelDetail.getUser().getId(), kennelDetail.getDoctor().getId());
        messagingTemplate.convertAndSend("/topic/kennels", kennelNotification);
    }
}
