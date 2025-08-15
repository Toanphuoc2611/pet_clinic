import 'package:ung_dung_thu_y/dto/kennel/book_kennel_request.dart';

class KennelDetailEvent {}

class BookKennelDetailStarted extends KennelDetailEvent {
  final BookKennelRequest request;
  BookKennelDetailStarted(this.request);
}

class KennelDetailGetStarted extends KennelDetailEvent {}

class KennelDetailCancelStarted extends KennelDetailEvent {
  final String id;
  KennelDetailCancelStarted(this.id);
}
