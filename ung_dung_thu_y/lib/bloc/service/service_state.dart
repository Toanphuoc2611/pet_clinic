import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';

sealed class ServiceState {}

class ServiceGetInitial extends ServiceState {}

class ServiceGetInProgress extends ServiceState {}

class ServiceGetSuccess extends ServiceState {
  final List<ServicesGetDto> services;
  ServiceGetSuccess(this.services);
}

class ServiceGetFailure extends ServiceState {
  final String message;
  ServiceGetFailure(this.message);
}
