import 'package:admin/dto/prescription/prescription_dto.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/remote/prescription/prescription_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class PrescriptionRepository {
  final PrescriptionApiClient prescriptionApiClient;
  final AuthRepository authRepository;
  PrescriptionRepository(this.prescriptionApiClient, this.authRepository);

  Future<List<PrescriptionDto>> getPrescriptionsByMedicalRecordId(
    int medicalRecordId,
  ) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await prescriptionApiClient.getPrescriptionsByPetId(
        token.data,
        medicalRecordId,
      );
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }
}
