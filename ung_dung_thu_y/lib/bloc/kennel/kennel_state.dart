import 'package:ung_dung_thu_y/dto/kennel/get_kennel_dto.dart';

sealed class KennelState {}

class KennelInitial extends KennelState {}

class KennelGetInProgress extends KennelState {}

class KennelGetSuccess extends KennelState {
  final List<KennelDto> kennels;
  KennelGetSuccess(this.kennels);
}

class KennelGetFailure extends KennelState {
  final String message;
  KennelGetFailure(this.message);
}
