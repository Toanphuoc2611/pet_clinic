import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/medication/category_dto.dart';
import 'package:admin/remote/api_service.dart';

class MedicationApiClient {
  final ApiService apiService;
  MedicationApiClient(this.apiService);
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
