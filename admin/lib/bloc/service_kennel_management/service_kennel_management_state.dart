import 'package:admin/dto/service/services_get_dto.dart';
import 'package:admin/dto/kennel/get_kennel_dto.dart';

abstract class ServiceKennelManagementState {}

class ServiceKennelManagementInitial extends ServiceKennelManagementState {}

class ServiceKennelManagementLoading extends ServiceKennelManagementState {}

class ServiceKennelManagementError extends ServiceKennelManagementState {
  final String message;
  ServiceKennelManagementError(this.message);
}

class ServiceKennelManagementLoaded extends ServiceKennelManagementState {
  // Tab management
  final int currentTab; // 0 = services, 1 = kennels

  // Services data
  final List<ServicesGetDto> allServices;
  final List<ServicesGetDto> filteredServices;
  final List<ServicesGetDto> currentServices;
  final int serviceCurrentPage;
  final int serviceTotalPages;
  final String serviceSearchQuery;
  final int? selectedServiceStatus;

  // Kennels data
  final List<KennelDto> allKennels;
  final List<KennelDto> filteredKennels;
  final List<KennelDto> currentKennels;
  final int kennelCurrentPage;
  final int kennelTotalPages;
  final String kennelSearchQuery;
  final int? selectedKennelStatus;

  final int itemsPerPage;

  ServiceKennelManagementLoaded({
    required this.currentTab,
    required this.allServices,
    required this.filteredServices,
    required this.currentServices,
    required this.serviceCurrentPage,
    required this.serviceTotalPages,
    required this.serviceSearchQuery,
    this.selectedServiceStatus,
    required this.allKennels,
    required this.filteredKennels,
    required this.currentKennels,
    required this.kennelCurrentPage,
    required this.kennelTotalPages,
    required this.kennelSearchQuery,
    this.selectedKennelStatus,
    this.itemsPerPage = 10,
  });

  ServiceKennelManagementLoaded copyWith({
    int? currentTab,
    List<ServicesGetDto>? allServices,
    List<ServicesGetDto>? filteredServices,
    List<ServicesGetDto>? currentServices,
    int? serviceCurrentPage,
    int? serviceTotalPages,
    String? serviceSearchQuery,
    int? selectedServiceStatus,
    List<KennelDto>? allKennels,
    List<KennelDto>? filteredKennels,
    List<KennelDto>? currentKennels,
    int? kennelCurrentPage,
    int? kennelTotalPages,
    String? kennelSearchQuery,
    int? selectedKennelStatus,
    int? itemsPerPage,
  }) {
    return ServiceKennelManagementLoaded(
      currentTab: currentTab ?? this.currentTab,
      allServices: allServices ?? this.allServices,
      filteredServices: filteredServices ?? this.filteredServices,
      currentServices: currentServices ?? this.currentServices,
      serviceCurrentPage: serviceCurrentPage ?? this.serviceCurrentPage,
      serviceTotalPages: serviceTotalPages ?? this.serviceTotalPages,
      serviceSearchQuery: serviceSearchQuery ?? this.serviceSearchQuery,
      selectedServiceStatus:
          selectedServiceStatus ?? this.selectedServiceStatus,
      allKennels: allKennels ?? this.allKennels,
      filteredKennels: filteredKennels ?? this.filteredKennels,
      currentKennels: currentKennels ?? this.currentKennels,
      kennelCurrentPage: kennelCurrentPage ?? this.kennelCurrentPage,
      kennelTotalPages: kennelTotalPages ?? this.kennelTotalPages,
      kennelSearchQuery: kennelSearchQuery ?? this.kennelSearchQuery,
      selectedKennelStatus: selectedKennelStatus ?? this.selectedKennelStatus,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }
}

class ServiceKennelManagementActionLoading
    extends ServiceKennelManagementState {}

class ServiceKennelManagementActionSuccess
    extends ServiceKennelManagementState {
  final String message;
  ServiceKennelManagementActionSuccess(this.message);
}

class ServiceKennelManagementActionError extends ServiceKennelManagementState {
  final String message;
  ServiceKennelManagementActionError(this.message);
}
