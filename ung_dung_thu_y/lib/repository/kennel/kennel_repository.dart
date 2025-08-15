import 'package:ung_dung_thu_y/dto/kennel/get_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/remote/kennel/kennel_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class KennelRepository {
  final KennelApiClient kennelApiClient;
  final AuthRepository authRepository;
  KennelRepository(this.kennelApiClient, this.authRepository);

  Future<Result<List<KennelDto>>> getKennels() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await kennelApiClient.getKennels(token);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }
}
