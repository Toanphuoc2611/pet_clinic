import 'package:bloc/bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medication/medication_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medication/medication_state.dart';
import 'package:ung_dung_thu_y/dto/medication/category_dto.dart';
import 'package:ung_dung_thu_y/dto/medication/medication_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/medication/medication_repository.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final MedicationRepository medicationRepository;
  MedicationBloc(this.medicationRepository) : super(MedicationInitial()) {
    on<MedicationGetStarted>(_onGetMedicationStarted);
    on<MedicationCategoriesGetStarted>(_onGetCategoriesStarted);
    on<MedicationAndCategoriesGetStarted>(_onGetMedicationAndCategoriesStarted);
  }

  void _onGetMedicationStarted(
    MedicationGetStarted event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationGetInProgress());
    final result = await medicationRepository.getAllMedications();
    return (switch (result) {
      Success() => emit(MedicationGetSuccess(result.data)),
      Failure() => emit(MedicationGetFailure()),
    });
  }

  void _onGetCategoriesStarted(
    MedicationCategoriesGetStarted event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationCategoriesGetInProgress());
    final result = await medicationRepository.getAllCategories();
    return (switch (result) {
      Success() => emit(MedicationCategoriesGetSuccess(result.data)),
      Failure() => emit(MedicationGetFailure()),
    });
  }

  void _onGetMedicationAndCategoriesStarted(
    MedicationAndCategoriesGetStarted event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationGetInProgress());

    // Get both medications and categories
    final medicationsResult = await medicationRepository.getAllMedications();
    final categoriesResult = await medicationRepository.getAllCategories();

    if (medicationsResult is Success<List<MedicationDto>> &&
        categoriesResult is Success<List<CategoryDto>>) {
      emit(
        MedicationAndCategoriesGetSuccess(
          medicationsResult.data,
          categoriesResult.data,
        ),
      );
    } else {
      emit(MedicationGetFailure());
    }
  }
}
