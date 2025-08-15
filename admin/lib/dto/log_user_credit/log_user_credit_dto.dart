import 'package:admin/dto/user/user_get_dto.dart';

class LogUserCreditDto {
  final int id;
  final String content;
  final String action;
  final String createdAt;
  final int balanceCurr;
  final int balanceAfter;
  final UserGetDto user;

  LogUserCreditDto({
    required this.id,
    required this.content,
    required this.action,
    required this.createdAt,
    required this.balanceCurr,
    required this.balanceAfter,
    required this.user,
  });

  factory LogUserCreditDto.fromJson(Map<String, dynamic> json) {
    return LogUserCreditDto(
      id: json['id'],
      content: json['content'],
      action: json['action'],
      createdAt: json['createdAt'],
      balanceCurr: json['balance_curr'],
      balanceAfter: json['balance_after'],
      user: UserGetDto.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'action': action,
      'createdAt': createdAt,
      'balance_curr': balanceCurr,
      'balance_after': balanceAfter,
      'user': user,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogUserCreditDto &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
