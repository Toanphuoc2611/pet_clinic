class UpdateAccountStatusRequest {
  final int accountId;
  final int status; // 1 = active, 0 = inactive

  UpdateAccountStatusRequest({required this.accountId, required this.status});

  Map<String, dynamic> toJson() {
    return {'accountId': accountId, 'status': status};
  }
}
