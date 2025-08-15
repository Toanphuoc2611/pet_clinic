import 'package:admin/dto/account/account_dto.dart';

abstract class AccountManagementState {}

class AccountManagementInitial extends AccountManagementState {}

class AccountManagementLoading extends AccountManagementState {}

class AccountManagementError extends AccountManagementState {
  final String message;
  AccountManagementError(this.message);
}

class AccountManagementLoaded extends AccountManagementState {
  final List<AccountDto> allAccounts;
  final List<AccountDto> filteredAccounts;
  final List<AccountDto> currentAccounts;
  final int currentPage;
  final int totalPages;
  final String searchQuery;
  final String? roleFilter;
  final int? statusFilter;
  final int itemsPerPage;

  AccountManagementLoaded({
    required this.allAccounts,
    required this.filteredAccounts,
    required this.currentAccounts,
    required this.currentPage,
    required this.totalPages,
    required this.searchQuery,
    this.roleFilter,
    this.statusFilter,
    this.itemsPerPage = 10,
  });

  AccountManagementLoaded copyWith({
    List<AccountDto>? allAccounts,
    List<AccountDto>? filteredAccounts,
    List<AccountDto>? currentAccounts,
    int? currentPage,
    int? totalPages,
    String? searchQuery,
    String? roleFilter,
    int? statusFilter,
    int? itemsPerPage,
  }) {
    return AccountManagementLoaded(
      allAccounts: allAccounts ?? this.allAccounts,
      filteredAccounts: filteredAccounts ?? this.filteredAccounts,
      currentAccounts: currentAccounts ?? this.currentAccounts,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  // Helper getters
  int get totalItems => filteredAccounts.length;

  int get doctorCount =>
      allAccounts.where((account) => account.role == 'DOCTOR').length;

  int get customerCount =>
      allAccounts.where((account) => account.role == 'CUSTOMER').length;

  int get activeCount =>
      allAccounts.where((account) => account.status == 1).length;

  int get inactiveCount =>
      allAccounts.where((account) => account.status == 0).length;
}

class AccountManagementActionLoading extends AccountManagementState {}

class AccountManagementActionSuccess extends AccountManagementState {
  final String message;
  AccountManagementActionSuccess(this.message);
}

class AccountManagementActionError extends AccountManagementState {
  final String message;
  AccountManagementActionError(this.message);
}
