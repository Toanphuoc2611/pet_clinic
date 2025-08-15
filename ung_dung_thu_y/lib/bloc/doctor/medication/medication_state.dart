import 'package:ung_dung_thu_y/dto/medication/category_dto.dart';
import 'package:ung_dung_thu_y/dto/medication/medication_dto.dart';

sealed class MedicationState {}

class MedicationInitial extends MedicationState {}

class MedicationGetInProgress extends MedicationState {}

class MedicationGetSuccess extends MedicationState {
  final List<MedicationDto> medications;
  MedicationGetSuccess(this.medications);
}

class MedicationCategoriesGetInProgress extends MedicationState {}

class MedicationCategoriesGetSuccess extends MedicationState {
  final List<CategoryDto> categories;
  MedicationCategoriesGetSuccess(this.categories);
}

class MedicationAndCategoriesGetSuccess extends MedicationState {
  final List<MedicationDto> medications;
  final List<CategoryDto> categories;
  MedicationAndCategoriesGetSuccess(this.medications, this.categories);
}

class MedicationGetFailure extends MedicationState {}
