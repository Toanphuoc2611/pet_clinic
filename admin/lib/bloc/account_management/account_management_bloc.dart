import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin/bloc/account_management/account_management_event.dart';
import 'package:admin/bloc/account_management/account_management_state.dart';
import 'package:admin/repository/account/account_repository.dart';
import 'package:admin/dto/account/account_dto.dart';
import 'package:admin/dto/account/create_doctor_request.dart';
import 'package:admin/dto/account/update_account_status_request.dart';

class AccountManagementBloc
    extends Bloc<AccountManagementEvent, AccountManagementState> {
  final AccountRepository accountRepository;

  AccountManagementBloc({required this.accountRepository})
    : super(AccountManagementInitial()) {
    on<LoadAccountsEvent>(_onLoadAccounts);
    on<SearchAccountsEvent>(_onSearchAccounts);
    on<FilterAccountsByRoleEvent>(_onFilterAccountsByRole);
    on<FilterAccountsByStatusEvent>(_onFilterAccountsByStatus);
    on<CreateDoctorAccountEvent>(_onCreateDoctorAccount);
    on<UpdateAccountStatusEvent>(_onUpdateAccountStatus);
    on<ChangePaginationEvent>(_onChangePagination);
    on<RefreshAccountsEvent>(_onRefreshAccounts);
  }

  Future<void> _onLoadAccounts(
    LoadAccountsEvent event,
    Emitter<AccountManagementState> emit,
  ) async {
    emit(AccountManagementLoading());
    try {
      final accounts = await accountRepository.getAllAccounts();
      _emitLoadedState(emit, accounts, '', 0, null, null);
    } catch (e) {
      emit(
        AccountManagementError(
          'Không thể tải dữ liệu tài khoản: ${e.toString()}',
        ),
      );
    }
  }

  void _onSearchAccounts(
    SearchAccountsEvent event,
    Emitter<AccountManagementState> emit,
  ) {
    if (state is AccountManagementLoaded) {
      final currentState = state as AccountManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allAccounts,
        event.query,
        0,
        currentState.roleFilter,
        currentState.statusFilter,
      );
    }
  }

  void _onFilterAccountsByRole(
    FilterAccountsByRoleEvent event,
    Emitter<AccountManagementState> emit,
  ) {
    if (state is AccountManagementLoaded) {
      final currentState = state as AccountManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allAccounts,
        currentState.searchQuery,
        0,
        event.role,
        currentState.statusFilter,
      );
    }
  }

  void _onFilterAccountsByStatus(
    FilterAccountsByStatusEvent event,
    Emitter<AccountManagementState> emit,
  ) {
    if (state is AccountManagementLoaded) {
      final currentState = state as AccountManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allAccounts,
        currentState.searchQuery,
        0,
        currentState.roleFilter,
        event.status,
      );
    }
  }

  Future<void> _onCreateDoctorAccount(
    CreateDoctorAccountEvent event,
    Emitter<AccountManagementState> emit,
  ) async {
    if (state is AccountManagementLoaded) {
      final currentState = state as AccountManagementLoaded;
      emit(AccountManagementActionLoading());

      try {
        final request = CreateDoctorRequest(
          email: event.email,
          fullName: event.fullName,
          phoneNumber: event.phoneNumber,
          address: event.address,
          birthday: event.birthday,
          gender: event.gender,
        );

        await accountRepository.createDoctorAccount(request);

        // Thông báo thành công
        emit(AccountManagementActionSuccess('Tạo tài khoản bác sĩ thành công'));

        // Reload accounts
        final accounts = await accountRepository.getAllAccounts();

        // Sau đó cập nhật lại trạng thái loaded
        _emitLoadedState(
          emit,
          accounts,
          currentState.searchQuery,
          currentState.currentPage,
          currentState.roleFilter,
          currentState.statusFilter,
        );
      } catch (e) {
        // Thông báo lỗi
        emit(
          AccountManagementActionError(
            'Không thể tạo tài khoản: ${e.toString()}',
          ),
        );

        // Sau đó quay lại trạng thái loaded trước đó
        _emitLoadedState(
          emit,
          currentState.allAccounts,
          currentState.searchQuery,
          currentState.currentPage,
          currentState.roleFilter,
          currentState.statusFilter,
        );
      }
    }
  }

  Future<void> _onUpdateAccountStatus(
    UpdateAccountStatusEvent event,
    Emitter<AccountManagementState> emit,
  ) async {
    if (state is AccountManagementLoaded) {
      final currentState = state as AccountManagementLoaded;
      emit(AccountManagementActionLoading());

      try {
        final request = UpdateAccountStatusRequest(
          accountId: event.accountId,
          status: event.status,
        );

        await accountRepository.updateAccountStatus(request);

        final statusText = event.status == 1 ? 'kích hoạt' : 'vô hiệu hóa';

        // Thông báo thành công
        emit(
          AccountManagementActionSuccess('Đã $statusText tài khoản thành công'),
        );

        // Reload accounts
        final accounts = await accountRepository.getAllAccounts();

        // Sau đó cập nhật lại trạng thái loaded
        _emitLoadedState(
          emit,
          accounts,
          currentState.searchQuery,
          currentState.currentPage,
          currentState.roleFilter,
          currentState.statusFilter,
        );
      } catch (e) {
        // Thông báo lỗi
        emit(
          AccountManagementActionError(
            'Không thể cập nhật trạng thái: ${e.toString()}',
          ),
        );

        // Sau đó quay lại trạng thái loaded trước đó
        _emitLoadedState(
          emit,
          currentState.allAccounts,
          currentState.searchQuery,
          currentState.currentPage,
          currentState.roleFilter,
          currentState.statusFilter,
        );
      }
    }
  }

  void _onChangePagination(
    ChangePaginationEvent event,
    Emitter<AccountManagementState> emit,
  ) {
    if (state is AccountManagementLoaded) {
      final currentState = state as AccountManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allAccounts,
        currentState.searchQuery,
        event.page,
        currentState.roleFilter,
        currentState.statusFilter,
      );
    }
  }

  Future<void> _onRefreshAccounts(
    RefreshAccountsEvent event,
    Emitter<AccountManagementState> emit,
  ) async {
    if (state is AccountManagementLoaded) {
      final currentState = state as AccountManagementLoaded;
      try {
        final accounts = await accountRepository.getAllAccounts();
        _emitLoadedState(
          emit,
          accounts,
          currentState.searchQuery,
          currentState.currentPage,
          currentState.roleFilter,
          currentState.statusFilter,
        );
      } catch (e) {
        emit(
          AccountManagementError('Không thể làm mới dữ liệu: ${e.toString()}'),
        );
      }
    }
  }

  void _emitLoadedState(
    Emitter<AccountManagementState> emit,
    List<AccountDto> allAccounts,
    String searchQuery,
    int currentPage,
    String? roleFilter,
    int? statusFilter,
  ) {
    // Apply filters
    List<AccountDto> filteredAccounts = allAccounts;

    // Search filter
    if (searchQuery.isNotEmpty) {
      filteredAccounts =
          filteredAccounts.where((account) {
            final query = searchQuery.toLowerCase();
            return account.user.fullname!.toLowerCase().contains(query) ||
                account.user.email!.toLowerCase().contains(query) ||
                account.user.phoneNumber.toLowerCase().contains(query) ||
                account.role.toLowerCase().contains(query);
          }).toList();
    }

    // Role filter
    if (roleFilter != null) {
      filteredAccounts =
          filteredAccounts
              .where((account) => account.role == roleFilter)
              .toList();
    }

    // Status filter
    if (statusFilter != null) {
      filteredAccounts =
          filteredAccounts
              .where((account) => account.status == statusFilter)
              .toList();
    }

    // Pagination
    const itemsPerPage = 10;
    final totalPages = (filteredAccounts.length / itemsPerPage).ceil();
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(
      0,
      filteredAccounts.length,
    );
    final currentAccounts = filteredAccounts.sublist(startIndex, endIndex);

    emit(
      AccountManagementLoaded(
        allAccounts: allAccounts,
        filteredAccounts: filteredAccounts,
        currentAccounts: currentAccounts,
        currentPage: currentPage,
        totalPages: totalPages,
        searchQuery: searchQuery,
        roleFilter: roleFilter,
        statusFilter: statusFilter,
      ),
    );
  }
}
