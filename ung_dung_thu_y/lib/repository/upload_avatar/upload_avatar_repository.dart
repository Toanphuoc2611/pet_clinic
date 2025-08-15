import 'package:ung_dung_thu_y/dto/pet/pet_update_avatar.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/dto/user/user_update_avatar.dart';
import 'package:ung_dung_thu_y/remote/upload_avatar/upload_avatar_api.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class UploadAvatarRepository {
  final UploadAvatarApi uploadAvatarApi;
  final AuthRepository authRepository;
  UploadAvatarRepository(this.uploadAvatarApi, this.authRepository);

  Future<Result<String>> uploadAvatarPet(PetUpdateAvatar pet) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final response = await uploadAvatarApi.uploadAvatarPet(token, pet);
        if (response.isNotEmpty) {
          return Success(response);
        } else {
          return Failure("Failure");
        }
      } else if (tokenResult is Failure<String>) {
        return Failure(tokenResult.message);
      } else {
        return Failure("Failure");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<String>> uploadAvatarUser(UserUpdateAvatar user) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final response = await uploadAvatarApi.uploadAvatarUser(token, user);
        if (response.isNotEmpty) {
          return Success(response);
        } else {
          return Failure("Failure");
        }
      } else if (tokenResult is Failure<String>) {
        return Failure(tokenResult.message);
      } else {
        return Failure("Failure");
      }
    } catch (e) {
      return Failure('$e');
    }
  }
}
