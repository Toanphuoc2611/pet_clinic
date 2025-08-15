package com.example.petclinic.mapper;

import com.example.petclinic.dto.request.user.UserCreationRequest;
import com.example.petclinic.dto.request.user.UserUpdatedRequest;
import com.example.petclinic.entity.User;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserMapper {
    User toUser(UserCreationRequest request);
    User updateUser(UserUpdatedRequest request);
}
