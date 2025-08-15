import 'package:dio/dio.dart';
import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_update_avatar.dart';
import 'package:ung_dung_thu_y/dto/user/user_update_avatar.dart';

class UploadAvatarApi {
  final Dio dio;
  UploadAvatarApi(this.dio);

  Future<String> uploadAvatarPet(String token, PetUpdateAvatar file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.avatar.path),
      'id': file.id,
    });
    final response = await dio.put(
      EndPoints.uploadAvatarPet,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    final result = response.data['code'] as int;
    if (result == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      final url = data['url'] as String;
      return url;
    } else {
      return "";
    }
  }

  Future<String> uploadAvatarUser(String token, UserUpdateAvatar file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.avatar.path),
    });
    final response = await dio.put(
      EndPoints.uploadAvatarUser,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    final result = response.data['code'] as int;
    if (result == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      final url = data['url'] as String;
      return url;
    } else {
      return "";
    }
  }
}
