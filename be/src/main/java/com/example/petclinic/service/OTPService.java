    package com.example.petclinic.service;

    import com.example.petclinic.entity.OTPCode;
    import com.example.petclinic.repository.OTPCodeRepository;
    import lombok.AccessLevel;
    import lombok.Data;
    import lombok.RequiredArgsConstructor;
    import lombok.experimental.FieldDefaults;
    import lombok.extern.slf4j.Slf4j;
    import org.springframework.mail.SimpleMailMessage;
    import org.springframework.mail.javamail.JavaMailSender;
    import org.springframework.stereotype.Service;


    import java.util.Random;

    @Data
    @Slf4j
    @RequiredArgsConstructor
    @Service
    @FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
    public class OTPService {
        JavaMailSender mailSender;
        OTPCodeRepository repository;

        public int verifyOtp(String otp, String email) {
            return repository.verifyOTP(otp, email);
        }

        public boolean sendOtp(String email) {
            String otp = String.format("%06d", new Random().nextInt(1000000));
            String content = "Ma xac minh cua ban la: " + otp + " mã xác minh này có thời hạn 5 phút";
            OTPCode otpCode = new OTPCode();
            otpCode.setOtp(otp);
            otpCode.setEmail(email);
            repository.save(otpCode);
            sendVerifyEmail(email, "Mã OTP Pet clinic", content);
            return true;
        }

        private void sendVerifyEmail(String toEmail, String subject, String content) {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(toEmail);
            message.setSubject(subject);
            message.setText(content);
            message.setFrom("shopplq123@gmail.com");
            mailSender.send(message);
        }

    }
