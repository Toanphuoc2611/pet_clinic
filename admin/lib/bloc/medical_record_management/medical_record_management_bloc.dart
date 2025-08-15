import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin/bloc/medical_record_management/medical_record_management_event.dart';
import 'package:admin/bloc/medical_record_management/medical_record_management_state.dart';
import 'package:admin/repository/medical_record/medical_record_repository.dart';
import 'package:admin/repository/prescription/prescription_repository.dart';
import 'package:admin/dto/medical_record/medical_record_dto.dart';

class MedicalRecordManagementBloc
    extends Bloc<MedicalRecordManagementEvent, MedicalRecordManagementState> {
  final MedicalRecordRepository medicalRecordRepository;
  final PrescriptionRepository prescriptionRepository;

  MedicalRecordManagementBloc({
    required this.medicalRecordRepository,
    required this.prescriptionRepository,
  }) : super(MedicalRecordManagementInitial()) {
    on<LoadMedicalRecordsEvent>(_onLoadMedicalRecords);
    on<SearchMedicalRecordsEvent>(_onSearchMedicalRecords);
    on<FilterMedicalRecordsByStatusEvent>(_onFilterMedicalRecordsByStatus);
    on<ChangePaginationEvent>(_onChangePagination);
    on<LoadPrescriptionDetailsEvent>(_onLoadPrescriptionDetails);
  }

  Future<void> _onLoadMedicalRecords(
    LoadMedicalRecordsEvent event,
    Emitter<MedicalRecordManagementState> emit,
  ) async {
    emit(MedicalRecordManagementLoading());
    try {
      final medicalRecords =
          await medicalRecordRepository.getAllMedicalRecords();
      _emitLoadedState(emit, medicalRecords, '', null, 0);
    } catch (e) {
      emit(
        MedicalRecordManagementError(
          'Không thể tải dữ liệu hồ sơ bệnh án: ${e.toString()}',
        ),
      );
    }
  }

  void _onSearchMedicalRecords(
    SearchMedicalRecordsEvent event,
    Emitter<MedicalRecordManagementState> emit,
  ) {
    if (state is MedicalRecordManagementLoaded) {
      final currentState = state as MedicalRecordManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allMedicalRecords,
        event.query,
        currentState.selectedStatus,
        0,
      );
    }
  }

  void _onFilterMedicalRecordsByStatus(
    FilterMedicalRecordsByStatusEvent event,
    Emitter<MedicalRecordManagementState> emit,
  ) {
    if (state is MedicalRecordManagementLoaded) {
      final currentState = state as MedicalRecordManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allMedicalRecords,
        currentState.searchQuery,
        event.status,
        0,
      );
    }
  }

  void _onChangePagination(
    ChangePaginationEvent event,
    Emitter<MedicalRecordManagementState> emit,
  ) {
    if (state is MedicalRecordManagementLoaded) {
      final currentState = state as MedicalRecordManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allMedicalRecords,
        currentState.searchQuery,
        currentState.selectedStatus,
        event.page,
      );
    }
  }

  Future<void> _onLoadPrescriptionDetails(
    LoadPrescriptionDetailsEvent event,
    Emitter<MedicalRecordManagementState> emit,
  ) async {
    // Lưu lại state hiện tại
    final previousState = state;

    emit(PrescriptionDetailsLoading());
    try {
      final prescriptions = await prescriptionRepository
          .getPrescriptionsByMedicalRecordId(event.medicalRecordId);

      // Tìm medical record tương ứng
      MedicalRecordDto? medicalRecord;
      if (previousState is MedicalRecordManagementLoaded) {
        try {
          medicalRecord = previousState.allMedicalRecords.firstWhere(
            (record) => record.id == event.medicalRecordId,
          );
        } catch (e) {
          // Không tìm thấy record
          medicalRecord = null;
        }
      }

      if (medicalRecord != null) {
        emit(
          PrescriptionDetailsLoaded(
            prescriptions: prescriptions,
            medicalRecord: medicalRecord,
          ),
        );
      } else {
        emit(PrescriptionDetailsError('Không tìm thấy hồ sơ bệnh án'));
      }
    } catch (e) {
      emit(
        PrescriptionDetailsError(
          'Không thể tải chi tiết đơn thuốc: ${e.toString()}',
        ),
      );
    }
  }

  void _emitLoadedState(
    Emitter<MedicalRecordManagementState> emit,
    List<MedicalRecordDto> allMedicalRecords,
    String searchQuery,
    int? selectedStatus,
    int currentPage,
  ) {
    // Lọc theo tìm kiếm
    List<MedicalRecordDto> filteredRecords = allMedicalRecords;

    if (searchQuery.isNotEmpty) {
      filteredRecords =
          filteredRecords.where((record) {
            final query = searchQuery.toLowerCase();
            return record.pet.name.toLowerCase().contains(query) ||
                (record.user.fullname?.toLowerCase().contains(query) ??
                    false) ||
                (record.doctor.fullname?.toLowerCase().contains(query) ??
                    false) ||
                record.id.toString().contains(query);
          }).toList();
    }

    // Lọc theo trạng thái
    if (selectedStatus != null) {
      filteredRecords =
          filteredRecords
              .where((record) => record.status == selectedStatus)
              .toList();
    }

    // Phân trang
    const itemsPerPage = 10;
    final totalItems = filteredRecords.length;
    final totalPages = (totalItems / itemsPerPage).ceil();
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, totalItems);
    final currentRecords = filteredRecords.sublist(startIndex, endIndex);

    emit(
      MedicalRecordManagementLoaded(
        allMedicalRecords: allMedicalRecords,
        filteredMedicalRecords: filteredRecords,
        currentMedicalRecords: currentRecords,
        currentPage: currentPage,
        totalPages: totalPages,
        totalItems: totalItems,
        searchQuery: searchQuery,
        selectedStatus: selectedStatus,
        itemsPerPage: itemsPerPage,
      ),
    );
  }
}
