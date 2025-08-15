import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/pet/pet_get_dto.dart';
import 'package:admin/remote/api_service.dart';
import 'package:dio/dio.dart';

class PetApiClient {
  final ApiService apiService;
  PetApiClient(this.apiService);

  Future<List<PetGetDto>> getPetListByUser(String token, String userId) async {
    try {
      final response = await apiService.getRequest(
        url: '${EndPoints.getListPetByUserId}/$userId',
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return [];
      final listPets =
          data
              .map((item) => PetGetDto.fromJson(item as Map<String, dynamic>))
              .toList();
      return listPets;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
