import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';

sealed class KennelDetailState {}

class KennelDetailGetInitial extends KennelDetailState {}

class BookKennelDetailInProgress extends KennelDetailState {}

class BookKennelDetailSuccess extends KennelDetailState {}

class BookKennelDetailFailure extends KennelDetailState {
  final String message;
  BookKennelDetailFailure(this.message);
}

class KennelDetailGetSuccess extends KennelDetailState {
  final List<KennelDetailDto> kennels;
  KennelDetailGetSuccess(this.kennels);
}

class KennelDetailGetFailure extends KennelDetailState {
  final String message;
  KennelDetailGetFailure(this.message);
}

class KennelDetailGetInProgress extends KennelDetailState {}

class KennelDetailCancelInProgress extends KennelDetailState {}

class KennelDetailCancelSuccess extends KennelDetailState {
  final KennelDetailDto kennelDetailDto;
  KennelDetailCancelSuccess(this.kennelDetailDto);
}

class KennelDetailCancelFailure extends KennelDetailState {
  final String message;
  KennelDetailCancelFailure(this.message);
}
