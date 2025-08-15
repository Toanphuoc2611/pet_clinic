import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/medication/category_dto.dart';
import 'package:ung_dung_thu_y/dto/medication/medication_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class MedicationApiClient {
  final ApiService apiService;
  MedicationApiClient(this.apiService);

  Future<List<MedicationDto>> getAllMedication(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getAllMedications,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      } else {
        final medications =
            (data).map((e) => MedicationDto.fromJson(e)).toList();
        return medications;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<CategoryDto>> getAllCategories(String token) async {
    try {
      final response = await apiService.getRequest(
        url: EndPoints.getAllCategories,
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      } else {
        final categories = (data).map((e) => CategoryDto.fromJson(e)).toList();
        return categories;
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
