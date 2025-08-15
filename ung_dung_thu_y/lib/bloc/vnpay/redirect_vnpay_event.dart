import 'package:ung_dung_thu_y/dto/vnpay/vnpay_request_dto.dart';

class RedirectVnPayEvent {}

class RedirectVnpayStarted extends RedirectVnPayEvent {
  final VnPayRequestDto vnPayRequestDto;
  RedirectVnpayStarted(this.vnPayRequestDto);
}
