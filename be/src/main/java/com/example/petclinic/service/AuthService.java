package com.example.petclinic.service;

import com.example.petclinic.config.JwtConfig;
import com.example.petclinic.dto.request.auth.LoginRequest;
import com.example.petclinic.dto.request.auth.LogoutRequest;
import com.example.petclinic.dto.request.auth.RefreshToken;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.dto.response.auth.TokenResponse;
import com.example.petclinic.entity.Account;
import com.example.petclinic.entity.InvalidToken;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.AccountRepository;
import com.example.petclinic.repository.InvalidTokenRepository;
import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Calendar;
import java.util.Date;
import java.util.UUID;

@Data
@RequiredArgsConstructor
@Service
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuthService {
    JwtConfig jwtConfig;
    AccountRepository accountRepository;
    InvalidTokenRepository invalidTokenRepository;
    private boolean checkPassword(String password, String request) {
        PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(10);
        return passwordEncoder.matches(request, password);
    }

    private String generateToken(String userId, String role) {
        JWSHeader jwsHeader = new JWSHeader(JWSAlgorithm.HS512);
        JWTClaimsSet claimsSet = new JWTClaimsSet.Builder()
                .subject(userId)
                .issuer("ung_dung_thu_y")
                .issueTime(new Date())
                .expirationTime(new Date(Instant.now().plus(1, ChronoUnit.HOURS).toEpochMilli()))
                .claim("scope", role)
                .jwtID(UUID.randomUUID().toString())
                .build();

        Payload payload = new Payload(claimsSet.toJSONObject());
        JWSObject jwsObject = new JWSObject(jwsHeader, payload);
        try {
            jwsObject.sign(new MACSigner(jwtConfig.getSignKey().getBytes()));
        } catch (JOSEException e) {
            throw new AppException(ErrorCode.TOKEN_FAILD);
        }
        return jwsObject.serialize();
    }

    public ApiResponse<TokenResponse> login(LoginRequest request) {
        Account account = accountRepository.findByEmail(request.getEmail()).orElseThrow(() -> new AppException(ErrorCode.USER_NOT_EXISTED));
        if (account.getStatus() == 0) {
            return ApiResponse.<TokenResponse>builder().code(200).message("Account is blocked").build();
        }
        if (checkPassword(account.getPassword(), request.getPassword())) {
            String token = generateToken(account.getUser().getId(), account.getRole().getName());
            return ApiResponse.<TokenResponse>builder().code(200).message("Login success").data(new TokenResponse(token)).build();
        } else {
            return ApiResponse.<TokenResponse>builder().code(200).message("Password incorrect").build();
        }
    }

    public void logout(LogoutRequest request) throws ParseException {
        try {
            SignedJWT signedJWT = verifyToken(request.getToken(), true);
            String jId = signedJWT.getJWTClaimsSet().getJWTID();
            Date expire = signedJWT.getJWTClaimsSet().getExpirationTime();
            InvalidToken invalidToken = new InvalidToken(jId, expire);
            invalidTokenRepository.save(invalidToken);
        } catch (AppException e) {
            throw new AppException(ErrorCode.TOKEN_IS_EXPIRED);
        }
    }

    public SignedJWT verifyToken(String token, boolean isRefresh) {
        try {
            JWSVerifier verifier = new MACVerifier(jwtConfig.getSignKey().getBytes());
            SignedJWT signedJWT = SignedJWT.parse(token);
            Date expiriedDate;
            if (isRefresh) {
                expiriedDate = new Date(
                        signedJWT.getJWTClaimsSet()
                                .getExpirationTime()
                                .toInstant().plus(Integer.parseInt(jwtConfig.getRefreshDuration()) *24, ChronoUnit.HOURS).toEpochMilli()
                );
            } else {
                expiriedDate = signedJWT.getJWTClaimsSet().getExpirationTime();
            }
            boolean check = signedJWT.verify(verifier);

            if (!(check && expiriedDate.after(new Date()))) {
                throw new AppException(ErrorCode.UNAUTHENTICATED);
            }
            if (invalidTokenRepository.existsById(signedJWT.getJWTClaimsSet().getJWTID())) {
                throw new AppException(ErrorCode.UNAUTHENTICATED);
            }
            return signedJWT;

        } catch (ParseException | JOSEException e ) {
            throw new RuntimeException(e);
        }
    }

//    public ApiResponse<TokenResponse> refreshToken(RefreshToken request) throws ParseException {
//        var signedJWT = verifyToken(request.getToken(), true);
//
//        var jit = signedJWT.getJWTClaimsSet().getJWTID();
//        var expiryTime = signedJWT.getJWTClaimsSet().getExpirationTime();
//
//        InvalidToken invalidatedToken =
//                new InvalidToken(jit, expiryTime);
//
//        invalidTokenRepository.save(invalidatedToken);
//
//        String userId = signedJWT.getJWTClaimsSet().getSubject();
//
////        String token = generateToken(userId);
//
//        return ApiResponse.<TokenResponse>builder().code(200).message("Refresh Token success").data(new TokenResponse(token)).build();
//    }
}
