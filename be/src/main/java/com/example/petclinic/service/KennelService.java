package com.example.petclinic.service;

import com.example.petclinic.dto.request.kennel.CreationKennel;
import com.example.petclinic.dto.response.ApiResponse;
import com.example.petclinic.entity.Kennel;
import com.example.petclinic.exception.AppException;
import com.example.petclinic.exception.ErrorCode;
import com.example.petclinic.repository.KennelRepository;
import lombok.AccessLevel;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import java.util.List;

@Data
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true,level = AccessLevel.PRIVATE)
@Service
public class KennelService {
    KennelRepository kennelRepository;

    public ApiResponse<Boolean> updateStatusKennel(int id, int status) {
        Kennel kennel = findKennelById(id);
        kennel.setStatus(status);
        kennelRepository.save(kennel);
        return ApiResponse.<Boolean>builder().code(200).message("update kennel success").data(true).build();
    }

    public Kennel findKennelById(int id) {
        return kennelRepository.findById(id).orElseThrow(() -> new AppException(ErrorCode.KENNEL_NOT_EXISTED));
    }
    public ApiResponse<Boolean> addKennel(CreationKennel request) {
        Kennel kennel = new Kennel();
        kennel.setStatus(1);
        kennel.setName(request.getName());
        kennel.setType(request.getType());
        kennel.setPriceMultiplier(request.getMulti());
        kennelRepository.save(kennel);
        return ApiResponse.<Boolean>builder().code(200).message("Add kennel success").data(true).build();
    }


    public ApiResponse<List<Kennel>> getKennelInvalid() {
        List<Kennel> kennels = kennelRepository.getKennelInvalid();
        return ApiResponse.<List<Kennel>>builder().code(200)
                .message("Get list kennel valid success").data(kennels).build();
    }

    public ApiResponse<List<Kennel>> getAllKennel() {
        List<Kennel> kennels = kennelRepository.getKennelInvalid();
        return ApiResponse.<List<Kennel>>builder().code(200)
                .message("Get list kennel valid success").data(kennels).build();
    }
}
