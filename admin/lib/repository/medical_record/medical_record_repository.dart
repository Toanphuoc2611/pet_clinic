import 'package:admin/dto/medical_record/medical_record_dto.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/remote/medical_record/medical_record_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class MedicalRecordRepository {
  final MedicalRecordApiClient medicalRecordApiClient;
  final AuthRepository authRepository;
  MedicalRecordRepository(this.medicalRecordApiClient, this.authRepository);

  Future<List<MedicalRecordDto>> getAllMedicalRecords() async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await medicalRecordApiClient.getAllMedicalRecords(token.data);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }
}
