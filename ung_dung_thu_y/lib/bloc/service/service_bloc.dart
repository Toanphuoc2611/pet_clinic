import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/service/service_event.dart';
import 'package:ung_dung_thu_y/bloc/service/service_state.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/service/service_repository.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository serviceRepository;
  ServiceBloc(this.serviceRepository) : super(ServiceGetInitial()) {
    on<ServiceGetStarted>(_onGetServicesStarted);
  }

  void _onGetServicesStarted(
    ServiceGetStarted event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceGetInProgress());
    final result = await serviceRepository.getAllServices();
    return (switch (result) {
      Success() => emit(ServiceGetSuccess(result.data)),
      Failure() => emit(ServiceGetFailure(result.message)),
    });
  }
}
