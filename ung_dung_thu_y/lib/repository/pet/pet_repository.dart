import 'package:ung_dung_thu_y/dto/pet/pet_add_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_update_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/remote/pet/pet_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class PetRepository {
  final PetApiClient petApiClient;
  final AuthRepository authRepository;
  PetRepository({required this.petApiClient, required this.authRepository});

  Future<Result<String>> createPet(PetAddDto request) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final String token = tokenResult.data;
        final result = await petApiClient.createPet(request, token);
        if (result == "Add success") {
          return Success(result);
        } else {
          return Failure(result);
        }
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error retrieving token");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<List<PetGetDto>>> getPets() async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final result = await petApiClient.getPets(token);
        return Success(result);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error retrieving token");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<List<PetGetDto>>> searchByName(String name) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final result = await petApiClient.searchPetByName(token, name);
        return Success(result);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error retrieving token");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<bool>> deletePet(String petId) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final result = await petApiClient.deletePet(token, petId);
        return Success(result);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error retrieving token");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<List<String>>> getBreedsBySpecies(String species) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await petApiClient.getBreedsBySpecies(token, species);
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<PetGetDto>> updatePet(String id, PetUpdateDto request) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final result = await petApiClient.updatePet(token, id, request);
        return Success(result);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error retrieving token");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<List<PetGetDto>>> getPetsByUserId(String userId) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final result = await petApiClient.getPetsByUserId(token, userId);
        return Success(result);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error retrieving token");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<List<PetGetDto>>> getPetsKennelValid() async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final result = await petApiClient.getPetsKennelValid(token);
        return Success(result);
      } else if (tokenResult is Failure<String>) {
        final String message = tokenResult.message;
        return Failure(message);
      } else {
        return Failure("Error retrieving token");
      }
    } catch (e) {
      return Failure('$e');
    }
  }
}
