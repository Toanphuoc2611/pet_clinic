import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_creation_by_doctor.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_creation_dto.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/remote/prescription/prescription_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class PrescriptionRepository {
  final PrescriptionApiClient prescriptionApiClient;
  final AuthRepository authRepository;
  PrescriptionRepository(this.prescriptionApiClient, this.authRepository);

  Future<Result<InvoiceResponse>> createPrescription(
    CreationPrescriptionReq request,
  ) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await prescriptionApiClient.createPrescription(
        token,
        request,
      );
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<InvoiceResponse>> createPrescriptionByDoctor(
    PrescriptionCreationByDoctor request,
  ) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await prescriptionApiClient.createPrescriptionByDoctor(
        token,
        request,
      );
      return Success(result);
    } else if (tokenResult is Failure<String>) {
      final String message = tokenResult.message;
      return Failure(message);
    } else {
      return Failure("Error retrieving token");
    }
  }

  Future<Result<List<PrescriptionDto>>> getPrescriptionsByPetId(
    int medicalRecordId,
  ) async {
    final tokenResult = await authRepository.getToken();
    if (tokenResult is Success<String>) {
      final token = tokenResult.data;
      final result = await prescriptionApiClient.getPrescriptionsByPetId(
        token,
        medicalRecordId,
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
