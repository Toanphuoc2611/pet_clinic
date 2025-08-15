import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_add_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_update_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class PetApiClient {
  final ApiService apiService;
  PetApiClient(this.apiService);

  Future<String> createPet(PetAddDto request, String token) async {
    final data = request.toJson();
    final response = await apiService.postRequest(
      url: EndPoints.handlePet,
      data: data,
      token: token,
    );
    String message = response.data['message'] as String;
    return message;
  }

  Future<List<PetGetDto>> getPets(String token) async {
    final response = await apiService.getRequest(
      url: EndPoints.getPets,
      token: token,
    );
    final List<dynamic> data = response.data['data'];
    return data.map((item) => PetGetDto.fromJson(item)).toList();
  }

  Future<List<PetGetDto>> searchPetByName(String token, String name) async {
    final response = await apiService.getRequest(
      url: "${EndPoints.searchPetByName}?name=$name",
      token: token,
    );
    final List<dynamic> data = response.data['data'];
    return data.map((item) => PetGetDto.fromJson(item)).toList();
  }

  Future<bool> deletePet(String token, String petId) async {
    final response = await apiService.deleteRequestWithoutData(
      url: "${EndPoints.handlePet}/$petId",
      token: token,
    );
    if (response.data['code'] == 200) {
      return true;
    } else if (response.data['code'] == 403) {
      return false;
    } else {
      throw Exception("Failed to delete pet: ${response.data['message']}");
    }
  }

  Future<List<String>> getBreedsBySpecies(String token, String species) async {
    final response = await apiService.getRequest(
      url: "${EndPoints.getBreedsBySpecies}/$species",
      token: token,
    );
    if (response.data['code'] == 200) {
      final List<dynamic> data = response.data['data'];
      if (data.isEmpty) {
        return [];
      }
      return data.map((item) => item['name'] as String).toList();
    } else {
      throw Exception("Failed to get breeds: ${response.data['message']}");
    }
  }

  Future<PetGetDto> updatePet(
    String token,
    String id,
    PetUpdateDto request,
  ) async {
    final data = request.toJson();
    final response = await apiService.putRequest(
      url: "${EndPoints.handlePet}/$id",
      data: data,
      token: token,
    );
    if (response.data['code'] == 200) {
      if (response.data['data'] == null) {
        throw Exception("No data returned from update pet");
      } else {
        return PetGetDto.fromJson(response.data['data']);
      }
    } else {
      throw Exception("Failed to update pet: ${response.data['message']}");
    }
  }

  Future<List<PetGetDto>> getPetsByUserId(String token, String userId) async {
    final response = await apiService.getRequest(
      url: "${EndPoints.getPetByUserId}/$userId",
      token: token,
    );
    final List<dynamic> data = response.data['data'];
    return data.map((item) => PetGetDto.fromJson(item)).toList();
  }

  Future<List<PetGetDto>> getPetsKennelValid(String token) async {
    final response = await apiService.getRequest(
      url: EndPoints.getPetKennelvalid,
      token: token,
    );
    final List<dynamic> data = response.data['data'];
    return data.map((item) => PetGetDto.fromJson(item)).toList();
  }
}
