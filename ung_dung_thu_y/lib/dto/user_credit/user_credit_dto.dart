class UserCreditDto {
  final int id;
  final int balance;

  UserCreditDto(this.id, this.balance);
  factory UserCreditDto.fromJson(Map<String, dynamic> json) =>
      UserCreditDto(json['id'], json['balance']);
}
