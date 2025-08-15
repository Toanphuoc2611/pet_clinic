import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin/bloc/service_kennel_management/service_kennel_management_event.dart';
import 'package:admin/bloc/service_kennel_management/service_kennel_management_state.dart';
import 'package:admin/repository/service/service_repository.dart';
import 'package:admin/repository/kennel/kennel_repository.dart';
import 'package:admin/dto/service/services_get_dto.dart';
import 'package:admin/dto/kennel/get_kennel_dto.dart';
import 'package:admin/dto/service/creation_service.dart';
import 'package:admin/dto/kennel/creation_kennel.dart';

class ServiceKennelManagementBloc
    extends Bloc<ServiceKennelManagementEvent, ServiceKennelManagementState> {
  final ServiceRepository serviceRepository;
  final KennelRepository kennelRepository;

  ServiceKennelManagementBloc({
    required this.serviceRepository,
    required this.kennelRepository,
  }) : super(ServiceKennelManagementInitial()) {
    on<LoadServicesEvent>(_onLoadServices);
    on<LoadKennelsEvent>(_onLoadKennels);
    on<SearchServicesEvent>(_onSearchServices);
    on<SearchKennelsEvent>(_onSearchKennels);
    on<FilterKennelsByStatusEvent>(_onFilterKennelsByStatus);
    on<AddServiceEvent>(_onAddService);
    on<UpdateServiceEvent>(_onUpdateService);
    on<UpdateServiceStatusEvent>(_onUpdateServiceStatus);
    on<AddKennelEvent>(_onAddKennel);
    on<UpdateKennelStatusEvent>(_onUpdateKennelStatus);
    on<SwitchTabEvent>(_onSwitchTab);
    on<ChangeServicePaginationEvent>(_onChangeServicePagination);
    on<ChangeKennelPaginationEvent>(_onChangeKennelPagination);
  }

  Future<void> _onLoadServices(
    LoadServicesEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) async {
    emit(ServiceKennelManagementLoading());
    try {
      final services = await serviceRepository.getAllServices();
      final kennels = await kennelRepository.getAllKennels();

      _emitLoadedState(
        emit,
        services: services,
        kennels: kennels,
        currentTab: 0,
        serviceSearchQuery: '',
        kennelSearchQuery: '',
        serviceCurrentPage: 0,
        kennelCurrentPage: 0,
        selectedServiceStatus: null,
        selectedKennelStatus: null,
      );
    } catch (e) {
      emit(
        ServiceKennelManagementError(
          'Không thể tải dữ liệu dịch vụ: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadKennels(
    LoadKennelsEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) async {
    emit(ServiceKennelManagementLoading());
    try {
      final services = await serviceRepository.getAllServices();
      final kennels = await kennelRepository.getAllKennels();

      _emitLoadedState(
        emit,
        services: services,
        kennels: kennels,
        currentTab: 1,
        serviceSearchQuery: '',
        kennelSearchQuery: '',
        serviceCurrentPage: 0,
        kennelCurrentPage: 0,
        selectedServiceStatus: null,
        selectedKennelStatus: null,
      );
    } catch (e) {
      emit(
        ServiceKennelManagementError(
          'Không thể tải dữ liệu chuồng: ${e.toString()}',
        ),
      );
    }
  }

  void _onSearchServices(
    SearchServicesEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      _emitLoadedState(
        emit,
        services: currentState.allServices,
        kennels: currentState.allKennels,
        currentTab: currentState.currentTab,
        serviceSearchQuery: event.query,
        kennelSearchQuery: currentState.kennelSearchQuery,
        serviceCurrentPage: 0,
        kennelCurrentPage: currentState.kennelCurrentPage,
        selectedServiceStatus: currentState.selectedServiceStatus,
        selectedKennelStatus: currentState.selectedKennelStatus,
      );
    }
  }

  void _onSearchKennels(
    SearchKennelsEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      _emitLoadedState(
        emit,
        services: currentState.allServices,
        kennels: currentState.allKennels,
        currentTab: currentState.currentTab,
        serviceSearchQuery: currentState.serviceSearchQuery,
        kennelSearchQuery: event.query,
        serviceCurrentPage: currentState.serviceCurrentPage,
        kennelCurrentPage: 0,
        selectedServiceStatus: currentState.selectedServiceStatus,
        selectedKennelStatus: currentState.selectedKennelStatus,
      );
    }
  }

  void _onFilterKennelsByStatus(
    FilterKennelsByStatusEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      _emitLoadedState(
        emit,
        services: currentState.allServices,
        kennels: currentState.allKennels,
        currentTab: currentState.currentTab,
        serviceSearchQuery: currentState.serviceSearchQuery,
        kennelSearchQuery: currentState.kennelSearchQuery,
        serviceCurrentPage: currentState.serviceCurrentPage,
        kennelCurrentPage: 0,
        selectedServiceStatus: currentState.selectedServiceStatus,
        selectedKennelStatus: event.status,
      );
    }
  }

  Future<void> _onAddService(
    AddServiceEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) async {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      emit(ServiceKennelManagementActionLoading());

      try {
        final request = CreationService(name: event.name, price: event.price);
        await serviceRepository.addService(request);

        // Reload services
        final services = await serviceRepository.getAllServices();

        // Thông báo thành công
        emit(ServiceKennelManagementActionSuccess('Thêm dịch vụ thành công'));

        // Sau đó cập nhật lại trạng thái loaded
        _emitLoadedState(
          emit,
          services: services,
          kennels: currentState.allKennels,
          currentTab: currentState.currentTab,
          serviceSearchQuery: currentState.serviceSearchQuery,
          kennelSearchQuery: currentState.kennelSearchQuery,
          serviceCurrentPage: currentState.serviceCurrentPage,
          kennelCurrentPage: currentState.kennelCurrentPage,
          selectedKennelStatus: currentState.selectedKennelStatus,
        );
      } catch (e) {
        // Thông báo lỗi
        emit(
          ServiceKennelManagementActionError(
            'Không thể thêm dịch vụ: ${e.toString()}',
          ),
        );

        // Sau đó quay lại trạng thái loaded trước đó
        _emitLoadedState(
          emit,
          services: currentState.allServices,
          kennels: currentState.allKennels,
          currentTab: currentState.currentTab,
          serviceSearchQuery: currentState.serviceSearchQuery,
          kennelSearchQuery: currentState.kennelSearchQuery,
          serviceCurrentPage: currentState.serviceCurrentPage,
          kennelCurrentPage: currentState.kennelCurrentPage,
          selectedKennelStatus: currentState.selectedKennelStatus,
        );
      }
    }
  }

  Future<void> _onUpdateService(
    UpdateServiceEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) async {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      emit(ServiceKennelManagementActionLoading());

      try {
        await serviceRepository.updateService(event.id, event.price);

        // Reload services
        final services = await serviceRepository.getAllServices();

        // Thông báo thành công
        emit(
          ServiceKennelManagementActionSuccess('Cập nhật dịch vụ thành công'),
        );

        // Sau đó cập nhật lại trạng thái loaded
        _emitLoadedState(
          emit,
          services: services,
          kennels: currentState.allKennels,
          currentTab: currentState.currentTab,
          serviceSearchQuery: currentState.serviceSearchQuery,
          kennelSearchQuery: currentState.kennelSearchQuery,
          serviceCurrentPage: currentState.serviceCurrentPage,
          kennelCurrentPage: currentState.kennelCurrentPage,
          selectedKennelStatus: currentState.selectedKennelStatus,
        );
      } catch (e) {
        // Thông báo lỗi
        emit(
          ServiceKennelManagementActionError(
            'Không thể cập nhật dịch vụ: ${e.toString()}',
          ),
        );

        // Sau đó quay lại trạng thái loaded trước đó
        _emitLoadedState(
          emit,
          services: currentState.allServices,
          kennels: currentState.allKennels,
          currentTab: currentState.currentTab,
          serviceSearchQuery: currentState.serviceSearchQuery,
          kennelSearchQuery: currentState.kennelSearchQuery,
          serviceCurrentPage: currentState.serviceCurrentPage,
          kennelCurrentPage: currentState.kennelCurrentPage,
          selectedKennelStatus: currentState.selectedKennelStatus,
        );
      }
    }
  }

  Future<void> _onUpdateServiceStatus(
    UpdateServiceStatusEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) async {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      emit(ServiceKennelManagementActionLoading());

      try {
        await serviceRepository.updateServiceStatus(event.id, event.status);

        // Reload services
        final services = await serviceRepository.getAllServices();

        // Thông báo thành công
        emit(
          ServiceKennelManagementActionSuccess(
            'Cập nhật trạng thái dịch vụ thành công',
          ),
        );

        // Sau đó cập nhật lại trạng thái loaded
        _emitLoadedState(
          emit,
          services: services,
          kennels: currentState.allKennels,
          currentTab: currentState.currentTab,
          serviceSearchQuery: currentState.serviceSearchQuery,
          kennelSearchQuery: currentState.kennelSearchQuery,
          serviceCurrentPage: currentState.serviceCurrentPage,
          kennelCurrentPage: currentState.kennelCurrentPage,
          selectedServiceStatus: currentState.selectedServiceStatus,
          selectedKennelStatus: currentState.selectedKennelStatus,
        );
      } catch (e) {
        // Thông báo lỗi
        emit(
          ServiceKennelManagementActionError(
            'Không thể cập nhật trạng thái dịch vụ: ${e.toString()}',
          ),
        );

        // Sau đó quay lại trạng thái loaded trước đó
        _emitLoadedState(
          emit,
          services: currentState.allServices,
          kennels: currentState.allKennels,
          currentTab: currentState.currentTab,
          serviceSearchQuery: currentState.serviceSearchQuery,
          kennelSearchQuery: currentState.kennelSearchQuery,
          serviceCurrentPage: currentState.serviceCurrentPage,
          kennelCurrentPage: currentState.kennelCurrentPage,
          selectedServiceStatus: currentState.selectedServiceStatus,
          selectedKennelStatus: currentState.selectedKennelStatus,
        );
      }
    }
  }

  Future<void> _onAddKennel(
    AddKennelEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) async {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      emit(ServiceKennelManagementActionLoading());

      try {
        final request = CreationKennel(
          name: event.name,
          type: event.type,
          priceMultiplier: event.priceMultiplier,
        );
        await kennelRepository.addKennel(request);

        // Reload kennels
        final kennels = await kennelRepository.getAllKennels();

        // Thông báo thành công
        emit(ServiceKennelManagementActionSuccess('Thêm chuồng thành công'));

        // Sau đó cập nhật lại trạng thái loaded
        _emitLoadedState(
          emit,
          services: currentState.allServices,
          kennels: kennels,
          currentTab: currentState.currentTab,
          serviceSearchQuery: currentState.serviceSearchQuery,
          kennelSearchQuery: currentState.kennelSearchQuery,
          serviceCurrentPage: currentState.serviceCurrentPage,
          kennelCurrentPage: currentState.kennelCurrentPage,
          selectedKennelStatus: currentState.selectedKennelStatus,
        );
      } catch (e) {
        // Thông báo lỗi
        emit(
          ServiceKennelManagementActionError(
            'Không thể thêm chuồng: ${e.toString()}',
          ),
        );

        // Sau đó quay lại trạng thái loaded trước đó
        _emitLoadedState(
          emit,
          services: currentState.allServices,
          kennels: currentState.allKennels,
          currentTab: currentState.currentTab,
          serviceSearchQuery: currentState.serviceSearchQuery,
          kennelSearchQuery: currentState.kennelSearchQuery,
          serviceCurrentPage: currentState.serviceCurrentPage,
          kennelCurrentPage: currentState.kennelCurrentPage,
          selectedKennelStatus: currentState.selectedKennelStatus,
        );
      }
    }
  }

  Future<void> _onUpdateKennelStatus(
    UpdateKennelStatusEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) async {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      emit(ServiceKennelManagementActionLoading());

      try {
        await kennelRepository.updateKennelStatus(event.id, event.status);

        // Reload kennels
        final kennels = await kennelRepository.getAllKennels();

        // Thông báo thành công
        emit(
          ServiceKennelManagementActionSuccess(
            'Cập nhật trạng thái chuồng thành công',
          ),
        );

        // Sau đó cập nhật lại trạng thái loaded
        _emitLoadedState(
          emit,
          services: currentState.allServices,
          kennels: kennels,
          currentTab: currentState.currentTab,
          serviceSearchQuery: currentState.serviceSearchQuery,
          kennelSearchQuery: currentState.kennelSearchQuery,
          serviceCurrentPage: currentState.serviceCurrentPage,
          kennelCurrentPage: currentState.kennelCurrentPage,
          selectedKennelStatus: currentState.selectedKennelStatus,
        );
      } catch (e) {
        // Thông báo lỗi
        emit(
          ServiceKennelManagementActionError(
            'Không thể cập nhật trạng thái chuồng: ${e.toString()}',
          ),
        );

        // Sau đó quay lại trạng thái loaded trước đó
        _emitLoadedState(
          emit,
          services: currentState.allServices,
          kennels: currentState.allKennels,
          currentTab: currentState.currentTab,
          serviceSearchQuery: currentState.serviceSearchQuery,
          kennelSearchQuery: currentState.kennelSearchQuery,
          serviceCurrentPage: currentState.serviceCurrentPage,
          kennelCurrentPage: currentState.kennelCurrentPage,
          selectedKennelStatus: currentState.selectedKennelStatus,
        );
      }
    }
  }

  void _onSwitchTab(
    SwitchTabEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      emit(currentState.copyWith(currentTab: event.tabIndex));
    }
  }

  void _onChangeServicePagination(
    ChangeServicePaginationEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      _emitLoadedState(
        emit,
        services: currentState.allServices,
        kennels: currentState.allKennels,
        currentTab: currentState.currentTab,
        serviceSearchQuery: currentState.serviceSearchQuery,
        kennelSearchQuery: currentState.kennelSearchQuery,
        serviceCurrentPage: event.page,
        kennelCurrentPage: currentState.kennelCurrentPage,
        selectedKennelStatus: currentState.selectedKennelStatus,
      );
    }
  }

  void _onChangeKennelPagination(
    ChangeKennelPaginationEvent event,
    Emitter<ServiceKennelManagementState> emit,
  ) {
    if (state is ServiceKennelManagementLoaded) {
      final currentState = state as ServiceKennelManagementLoaded;
      _emitLoadedState(
        emit,
        services: currentState.allServices,
        kennels: currentState.allKennels,
        currentTab: currentState.currentTab,
        serviceSearchQuery: currentState.serviceSearchQuery,
        kennelSearchQuery: currentState.kennelSearchQuery,
        serviceCurrentPage: currentState.serviceCurrentPage,
        kennelCurrentPage: event.page,
        selectedKennelStatus: currentState.selectedKennelStatus,
      );
    }
  }

  void _emitLoadedState(
    Emitter<ServiceKennelManagementState> emit, {
    required List<ServicesGetDto> services,
    required List<KennelDto> kennels,
    required int currentTab,
    required String serviceSearchQuery,
    required String kennelSearchQuery,
    required int serviceCurrentPage,
    required int kennelCurrentPage,
    int? selectedServiceStatus,
    int? selectedKennelStatus,
  }) {
    // Filter services
    List<ServicesGetDto> filteredServices = services;
    if (serviceSearchQuery.isNotEmpty) {
      filteredServices =
          filteredServices.where((service) {
            final query = serviceSearchQuery.toLowerCase();
            return service.name.toLowerCase().contains(query) ||
                service.price.toString().contains(query);
          }).toList();
    }

    // Filter kennels
    List<KennelDto> filteredKennels = kennels;
    if (kennelSearchQuery.isNotEmpty) {
      filteredKennels =
          filteredKennels.where((kennel) {
            final query = kennelSearchQuery.toLowerCase();
            return kennel.name.toLowerCase().contains(query) ||
                kennel.type.toLowerCase().contains(query);
          }).toList();
    }

    if (selectedKennelStatus != null) {
      filteredKennels =
          filteredKennels
              .where((kennel) => kennel.status == selectedKennelStatus)
              .toList();
    }

    // Pagination for services
    const itemsPerPage = 10;
    final serviceTotalPages = (filteredServices.length / itemsPerPage).ceil();
    final serviceStartIndex = serviceCurrentPage * itemsPerPage;
    final serviceEndIndex = (serviceStartIndex + itemsPerPage).clamp(
      0,
      filteredServices.length,
    );
    final currentServices = filteredServices.sublist(
      serviceStartIndex,
      serviceEndIndex,
    );

    // Pagination for kennels
    final kennelTotalPages = (filteredKennels.length / itemsPerPage).ceil();
    final kennelStartIndex = kennelCurrentPage * itemsPerPage;
    final kennelEndIndex = (kennelStartIndex + itemsPerPage).clamp(
      0,
      filteredKennels.length,
    );
    final currentKennels = filteredKennels.sublist(
      kennelStartIndex,
      kennelEndIndex,
    );

    emit(
      ServiceKennelManagementLoaded(
        currentTab: currentTab,
        allServices: services,
        filteredServices: filteredServices,
        currentServices: currentServices,
        serviceCurrentPage: serviceCurrentPage,
        serviceTotalPages: serviceTotalPages,
        serviceSearchQuery: serviceSearchQuery,
        selectedServiceStatus: selectedServiceStatus,
        allKennels: kennels,
        filteredKennels: filteredKennels,
        currentKennels: currentKennels,
        kennelCurrentPage: kennelCurrentPage,
        kennelTotalPages: kennelTotalPages,
        kennelSearchQuery: kennelSearchQuery,
        selectedKennelStatus: selectedKennelStatus,
      ),
    );
  }
}
