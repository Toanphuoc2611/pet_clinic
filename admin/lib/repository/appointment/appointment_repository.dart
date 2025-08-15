import 'package:admin/dto/appointment/appointment_get_dto.dart';
import 'package:admin/dto/result_file.dart';
import 'package:admin/remote/appointment/appointment_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class AppointmentRepository {
  final AuthRepository authRepository;
  final AppointmentApiClient appointmentApiClient;
  AppointmentRepository(this.appointmentApiClient, this.authRepository);

  Future<Result<List<AppointmentGetDto>>> getAllDoctorsAppointmentsInWeek(
    String startDate,
  ) async {
    try {
      final resultToken = await authRepository.getToken();
      if (resultToken is Success<String>) {
        final appointments = await appointmentApiClient
            .getAllDoctorsAppointmentsInWeek(resultToken.data, startDate);
        return Success(appointments);
      } else if (resultToken is Failure<String>) {
        return Failure(resultToken.message);
      }
      throw Exception();
    } catch (e) {
      return Failure('Lỗi khi lấy danh sách lịch hẹn: ${e.toString()}');
    }
  }
}
