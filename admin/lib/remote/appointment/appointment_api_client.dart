import 'package:admin/core/endpoints/end_points.dart';
import 'package:admin/dto/appointment/appointment_get_dto.dart';
import 'package:admin/remote/api_service.dart';
import 'package:dio/dio.dart';

class AppointmentApiClient {
  final ApiService apiService;
  AppointmentApiClient(this.apiService);

  Future<List<AppointmentGetDto>> getAllDoctorsAppointmentsInWeek(
    String token,
    String startDate,
  ) async {
    try {
      final response = await apiService.getRequest(
        url:
            '${EndPoints.getAllDoctorsAppointmentsInWeek}?startDate=$startDate',
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) return [];
      final listAppointments =
          data
              .map(
                (item) =>
                    AppointmentGetDto.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      return listAppointments;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
