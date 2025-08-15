import 'package:admin/dto/result_file.dart';
import 'package:admin/dto/medication/category_dto.dart';
import 'package:admin/remote/medication/medication_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class MedicationRepository {
  final MedicationApiClient medicationApiClient;
  final AuthRepository authRepository;

  MedicationRepository(this.medicationApiClient, this.authRepository);

  Future<List<CategoryDto>> getAllCategories() async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('Token không tồn tại');
    }
    if (token is Success<String>) {
      return await medicationApiClient.getAllCategories(token.data);
    } else if (token is Failure<String>) {
      throw Exception(token.message);
    } else {
      throw Exception('Lỗi không xác định');
    }
  }
}
