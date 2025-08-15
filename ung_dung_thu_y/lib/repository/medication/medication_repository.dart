import 'package:ung_dung_thu_y/dto/medication/category_dto.dart';
import 'package:ung_dung_thu_y/dto/medication/medication_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/remote/medication/medication_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class MedicationRepository {
  final MedicationApiClient medicationApiClient;
  final AuthRepository authRepository;

  MedicationRepository(this.medicationApiClient, this.authRepository);

  Future<Result<List<MedicationDto>>> getAllMedications() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await medicationApiClient.getAllMedication(token);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<List<CategoryDto>>> getAllCategories() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await medicationApiClient.getAllCategories(token);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }
}
