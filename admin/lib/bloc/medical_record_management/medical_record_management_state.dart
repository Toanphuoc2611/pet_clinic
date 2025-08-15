import 'package:admin/dto/medical_record/medical_record_dto.dart';
import 'package:admin/dto/prescription/prescription_dto.dart';

abstract class MedicalRecordManagementState {}

class MedicalRecordManagementInitial extends MedicalRecordManagementState {}

class MedicalRecordManagementLoading extends MedicalRecordManagementState {}

class MedicalRecordManagementError extends MedicalRecordManagementState {
  final String message;
  MedicalRecordManagementError(this.message);
}

class MedicalRecordManagementLoaded extends MedicalRecordManagementState {
  final List<MedicalRecordDto> allMedicalRecords;
  final List<MedicalRecordDto> filteredMedicalRecords;
  final List<MedicalRecordDto> currentMedicalRecords;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String searchQuery;
  final int? selectedStatus;
  final int itemsPerPage;

  MedicalRecordManagementLoaded({
    required this.allMedicalRecords,
    required this.filteredMedicalRecords,
    required this.currentMedicalRecords,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.searchQuery,
    this.selectedStatus,
    this.itemsPerPage = 10,
  });

  MedicalRecordManagementLoaded copyWith({
    List<MedicalRecordDto>? allMedicalRecords,
    List<MedicalRecordDto>? filteredMedicalRecords,
    List<MedicalRecordDto>? currentMedicalRecords,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    String? searchQuery,
    int? selectedStatus,
    int? itemsPerPage,
  }) {
    return MedicalRecordManagementLoaded(
      allMedicalRecords: allMedicalRecords ?? this.allMedicalRecords,
      filteredMedicalRecords:
          filteredMedicalRecords ?? this.filteredMedicalRecords,
      currentMedicalRecords:
          currentMedicalRecords ?? this.currentMedicalRecords,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }
}

class PrescriptionDetailsLoading extends MedicalRecordManagementState {}

class PrescriptionDetailsLoaded extends MedicalRecordManagementState {
  final List<PrescriptionDto> prescriptions;
  final MedicalRecordDto medicalRecord;

  PrescriptionDetailsLoaded({
    required this.prescriptions,
    required this.medicalRecord,
  });
}

class PrescriptionDetailsError extends MedicalRecordManagementState {
  final String message;
  PrescriptionDetailsError(this.message);
}
