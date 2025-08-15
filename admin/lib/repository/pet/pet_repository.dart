import 'package:admin/dto/pet/pet_get_dto.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/remote/pet/pet_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class PetRepository {
  final PetApiClient petApiClient;
  final AuthRepository authRepository;
  PetRepository({required this.petApiClient, required this.authRepository});

  Future<Result<List<PetGetDto>>> getPetListByUser(String userId) async {
    try {
      final resultToken = await authRepository.getToken();
      if (resultToken is Success<String>) {
        final pets = await petApiClient.getPetListByUser(
          resultToken.data,
          userId,
        );
        return Success(pets);
      } else if (resultToken is Failure<String>) {
        return Failure(resultToken.message);
      }
      throw Exception();
    } catch (e) {
      return Failure('Lỗi khi lấy danh sách thú cưng: ${e.toString()}');
    }
  }
}
