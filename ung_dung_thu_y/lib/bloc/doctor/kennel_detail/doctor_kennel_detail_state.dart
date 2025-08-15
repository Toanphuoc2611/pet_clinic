import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';

sealed class DoctorKennelDetailState {}

class DoctorKennelDetailInitial extends DoctorKennelDetailState {}

class DoctorKennelDetailStartedInProgress extends DoctorKennelDetailState {}

class DoctorKennelDetailGetSuccess extends DoctorKennelDetailState {
  final List<KennelDetailDto> kennels;
  DoctorKennelDetailGetSuccess(this.kennels);
}

class DoctorKennelDetailGetFailure extends DoctorKennelDetailState {
  final String message;
  DoctorKennelDetailGetFailure(this.message);
}

class DoctorKennelDetailGetByPetStartedInProgress
    extends DoctorKennelDetailState {}

class DoctorKennelDetailGetByPetSuccess extends DoctorKennelDetailState {
  final List<KennelDetailDto> kennels;
  DoctorKennelDetailGetByPetSuccess(this.kennels);
}

class DoctorKennelDetailGetByPetFailure extends DoctorKennelDetailState {
  final String message;
  DoctorKennelDetailGetByPetFailure(this.message);
}

class DoctorKennelDetailUpdateStartedInProgress
    extends DoctorKennelDetailState {}

class DoctorKennelDetailUpdateSuccess extends DoctorKennelDetailState {
  final KennelDetailDto kennel;
  DoctorKennelDetailUpdateSuccess(this.kennel);
}

class DoctorKennelDetailUpdateFailure extends DoctorKennelDetailState {
  final String message;
  DoctorKennelDetailUpdateFailure(this.message);
}

class DoctorKennelDetailCompleteBookingInProgress
    extends DoctorKennelDetailState {}

class DoctorKennelDetailCompleteBookingSuccess extends DoctorKennelDetailState {
  final InvoiceKennelDto invoiceKennelDto;
  DoctorKennelDetailCompleteBookingSuccess(this.invoiceKennelDto);
}

class DoctorKennelDetailCompleteBookingFailure extends DoctorKennelDetailState {
  final String message;
  DoctorKennelDetailCompleteBookingFailure(this.message);
}
