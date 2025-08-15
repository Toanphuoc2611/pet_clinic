import 'package:ung_dung_thu_y/dto/medical_record/medical_record_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/remote/medical_record/medical_record_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class MedicalRecordRepository {
  final MedicalRecordApiClient medicalRecordApiClient;
  final AuthRepository authRepository;
  MedicalRecordRepository(this.medicalRecordApiClient, this.authRepository);

  Future<Result<List<MedicalRecordDto>>> getMedicalRecords() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await medicalRecordApiClient.getMedicalRecords(token);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<MedicalRecordDto>> getMedicalRecordByUser(String petId) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await medicalRecordApiClient.getMedicalRecordsByUser(
        token,
        petId,
      );
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<List<MedicalRecordDto>>> getListMedicalRecordByPet(
    String petId,
  ) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await medicalRecordApiClient.getListMedicalRecordByPet(
        token,
        petId,
      );
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }
}
