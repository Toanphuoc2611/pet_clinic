import 'package:dio/dio.dart';
import 'package:ung_dung_thu_y/core/endpoints/end_points.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_creation.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';

class AppointmentApiClient {
  final ApiService apiService;
  AppointmentApiClient(this.apiService);

  Future<List<AppointmentGetDto>> getAppointments(
    String status,
    String token,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.getListAppointment}?status=$status",
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      final listAppointment =
          data
              .map(
                (item) =>
                    AppointmentGetDto.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      return listAppointment;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message']);
      } else {
        throw Exception(e.message);
      }
    }
  }

  Future<List<String>> getScheduleByDoctor(
    String idDoctor,
    String token,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.appointment}?id=$idDoctor",
        token: token,
      );
      final schedule =
          (response.data['data'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
      return schedule;
    } on DioException catch (e) {
      if (e.response != null) {
        return throw Exception(e.response!.data['message']);
      } else {
        return throw Exception(e.message);
      }
    }
  }

  Future<bool> createAppointment(
    AppointmentCreation appointmentCreation,
    String token,
  ) async {
    try {
      final response = await apiService.postRequest(
        url: EndPoints.appointment,
        data: appointmentCreation.toJson(),
        token: token,
      );
      final data = response.data['data'];
      if (data.isEmpty) return false;
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        return throw Exception(e.response!.data['message']);
      } else {
        return throw Exception(e.message);
      }
    }
  }

  Future<AppointmentGetDto> getAppointmentById(int id, String token) async {
    // try {
    final response = await apiService.getRequest(
      url: "${EndPoints.handleAppointment}/$id",
      token: token,
    );
    final data = response.data['data'];
    if (data.isEmpty) return throw Exception("No appointment found");
    return AppointmentGetDto.fromJson(data);
    // } on DioException catch (e) {
    //   if (e.response != null) {
    //     return throw Exception(e.response!.data['message']);
    //   } else {
    //     return throw Exception(e.message);
    //   }
    // }
  }

  Future<int> updateAppointmentByUser(int id, String token) async {
    try {
      final response = await apiService.putRequestWithoutData(
        url: "${EndPoints.handleAppointment}/$id",
        token: token,
      );
      final data = response.data;
      return data['code'] as int;
    } on DioException catch (e) {
      if (e.response != null) {
        return throw Exception(e.response!.data['message']);
      } else {
        return throw Exception(e.message);
      }
    }
  }

  Future<List<AppointmentGetDto>> getAppointmentOfDoctorByDate(
    String token,
    String date,
  ) async {
    try {
      final response = await apiService.getRequest(
        url: "${EndPoints.getAppointmentOfDoctorByDate}?date=$date",
        token: token,
      );
      final data = response.data['data'] as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((e) => AppointmentGetDto.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        return throw Exception(e.response!.data['message']);
      } else {
        return throw Exception(e.message);
      }
    }
  }
}
