import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';
import 'package:ung_dung_thu_y/remote/service/service_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class ServiceRepository {
  final AuthRepository authRepository;
  final ServiceApiClient serviceApiClient;
  ServiceRepository(this.authRepository, this.serviceApiClient);

  Future<Result<List<ServicesGetDto>>> getAllServices() async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final listService = await serviceApiClient.getAllServices(token);
        return Success(listService);
      } else if (tokenResult is Failure<String>) {
        return Failure(tokenResult.message);
      } else {
        return Failure("Error get all services");
      }
    } catch (e) {
      return Failure('$e');
    }
  }
}
