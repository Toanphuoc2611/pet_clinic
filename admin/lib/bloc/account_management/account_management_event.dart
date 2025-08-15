abstract class AccountManagementEvent {}

class LoadAccountsEvent extends AccountManagementEvent {}

class SearchAccountsEvent extends AccountManagementEvent {
  final String query;
  SearchAccountsEvent(this.query);
}

class FilterAccountsByRoleEvent extends AccountManagementEvent {
  final String? role; // 'DOCTOR', 'CUSTOMER', null for all
  FilterAccountsByRoleEvent(this.role);
}

class FilterAccountsByStatusEvent extends AccountManagementEvent {
  final int? status; // 1 = active, 0 = inactive, null for all
  FilterAccountsByStatusEvent(this.status);
}

class CreateDoctorAccountEvent extends AccountManagementEvent {
  final String email;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String? birthday;
  final int? gender;

  CreateDoctorAccountEvent({
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    this.birthday,
    this.gender,
  });
}

class UpdateAccountStatusEvent extends AccountManagementEvent {
  final int accountId;
  final int status;

  UpdateAccountStatusEvent({required this.accountId, required this.status});
}

class ChangePaginationEvent extends AccountManagementEvent {
  final int page;
  ChangePaginationEvent(this.page);
}

class RefreshAccountsEvent extends AccountManagementEvent {}
