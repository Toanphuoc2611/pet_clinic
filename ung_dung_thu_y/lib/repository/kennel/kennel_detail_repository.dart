import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/kennel/book_kennel_request.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/remote/kennel/kennel_detail_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class KennelDetailRepository {
  final KennelDetailApiClient kennelDetailApiClient;
  final AuthRepository authRepository;
  KennelDetailRepository(this.authRepository, this.kennelDetailApiClient);

  Future<Result<bool>> bookKennnel(BookKennelRequest request) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await kennelDetailApiClient.bookKennel(token, request);
      if (result['data'] == false) {
        return Failure(result['message']);
      }
      return Success(true);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<List<KennelDetailDto>>> getAllKennelByUser() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await kennelDetailApiClient.getAllKennelByUser(token);
      if (result.isEmpty) {
        return Failure("Không có dữ liệu");
      }
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<KennelDetailDto>> cancelBookKennel(String id) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await kennelDetailApiClient.cancelBookKennel(token, id);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<List<KennelDetailDto>>> getKennelOfDoctorToday() async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await kennelDetailApiClient.getKennelOfDoctorToday(token);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<List<KennelDetailDto>>> getKennelsByPetId(String petId) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await kennelDetailApiClient.getKennelsByPetId(
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

  Future<Result<KennelDetailDto>> updateKennelStatus(
    String id,
    String status,
  ) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await kennelDetailApiClient.updateKennelStatus(
        token,
        id,
        status,
      );
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<InvoiceKennelDto>> completeKennelBooking(String id) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await kennelDetailApiClient.completeKennelBooking(
        token,
        id,
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
