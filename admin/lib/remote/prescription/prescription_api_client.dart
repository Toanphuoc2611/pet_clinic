import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/prescription/prescription_dto.dart';
import 'package:admin/remote/api_service.dart';

class PrescriptionException implements Exception {
  final String message;
  PrescriptionException(this.message);
  @override
  String toString() => message;
}

class PrescriptionApiClient {
  final ApiService apiService;
  PrescriptionApiClient(this.apiService);

  Future<List<PrescriptionDto>> getPrescriptionsByPetId(
    String token,
    int medicalRecordId,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.getPrescriptionByMedicalRecord}/$medicalRecordId",
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return (data).map((item) => PrescriptionDto.fromJson(item)).toList();
    } catch (e) {
      throw PrescriptionException("Không thể lấy dữ liệu");
    }
  }
}
