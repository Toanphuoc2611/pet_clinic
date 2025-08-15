import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_dto.dart';

sealed class PrescriptionState {}

class PrescriptionInitial extends PrescriptionState {}

class PrescriptionCreatedInProgress extends PrescriptionState {}

class PrescriptionCreatedSuccess extends PrescriptionState {
  final InvoiceResponse invoice;
  PrescriptionCreatedSuccess(this.invoice);
}

class PrescriptionCreatedFailure extends PrescriptionState {
  final String message;
  PrescriptionCreatedFailure(this.message);
}

class PrescriptionCreatedByDoctorInProgress extends PrescriptionState {}

class PrescriptionCreatedByDoctorSuccess extends PrescriptionState {
  final InvoiceResponse invoice;
  PrescriptionCreatedByDoctorSuccess(this.invoice);
}

class PrescriptionCreatedByDoctorFailure extends PrescriptionState {
  final String message;
  PrescriptionCreatedByDoctorFailure(this.message);
}

class PrescriptionGetByPetInProgress extends PrescriptionState {}

class PrescriptionGetByPetSuccess extends PrescriptionState {
  final List<PrescriptionDto> prescriptions;
  PrescriptionGetByPetSuccess(this.prescriptions);
}

class PrescriptionGetByPetFailure extends PrescriptionState {
  final String message;
  PrescriptionGetByPetFailure(this.message);
}
