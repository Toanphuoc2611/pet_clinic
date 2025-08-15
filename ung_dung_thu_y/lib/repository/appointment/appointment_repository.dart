import 'package:ung_dung_thu_y/dto/appointment/appointment_creation.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/remote/appointment/appointment_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';

class AppointmentRepository {
  final AuthRepository authRepository;
  final AppointmentApiClient appointmentApiClient;
  AppointmentRepository(this.appointmentApiClient, this.authRepository);

  Future<Result<List<AppointmentGetDto>>> getAppointments(String status) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final listAppointments = await appointmentApiClient.getAppointments(
          status,
          token,
        );
        return Success(listAppointments);
      } else if (tokenResult is Failure<String>) {
        return Failure(tokenResult.message);
      } else {
        return Failure("Error get appointments");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<List<String>>> getScheduleByDoctor(String id) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final listSchedule = await appointmentApiClient.getScheduleByDoctor(
          id,
          token,
        );
        return Success(listSchedule);
      } else if (tokenResult is Failure<String>) {
        return Failure(tokenResult.message);
      } else {
        return Failure("Error get schedule appointments");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<bool>> createAppointment(
    AppointmentCreation appointmentCreation,
  ) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final isSuccess = await appointmentApiClient.createAppointment(
          appointmentCreation,
          token,
        );
        return Success(isSuccess);
      } else if (tokenResult is Failure<String>) {
        return Failure(tokenResult.message);
      } else {
        return Failure("Error create appointments");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<AppointmentGetDto>> getAppointmentById(int id) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final appointment = await appointmentApiClient.getAppointmentById(
          id,
          token,
        );
        return Success(appointment);
      } else if (tokenResult is Failure<String>) {
        return Failure(tokenResult.message);
      } else {
        return Failure("Error get appointment by id");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<bool>> updateAppointmentByUser(int id) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final code = await appointmentApiClient.updateAppointmentByUser(
          id,
          token,
        );
        if (code == 200) {
          return Success(true);
        } else if (code == 400) {
          return Success(false);
        } else {
          return Failure("Error update appointment");
        }
      } else if (tokenResult is Failure<String>) {
        return Failure(tokenResult.message);
      } else {
        return Failure("Error update appointment");
      }
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<List<AppointmentGetDto>>> getAppointmentOfDoctorByDate(
    String date,
  ) async {
    try {
      final tokenResult = await authRepository.getToken();
      if (tokenResult is Success<String>) {
        final token = tokenResult.data;
        final result = await appointmentApiClient.getAppointmentOfDoctorByDate(
          token,
          date,
        );
        return Success(result);
      } else if (tokenResult is Failure<String>) {
        return Failure(tokenResult.message);
      } else {
        return Failure("Error update appointment");
      }
    } catch (e) {
      return Failure('$e');
    }
  }
}
