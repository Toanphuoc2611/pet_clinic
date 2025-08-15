import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:admin/bloc/account_management/account_management_bloc.dart';
import 'package:admin/bloc/account_management/account_management_event.dart';
import 'package:admin/bloc/account_management/account_management_state.dart';
import 'package:admin/dto/account/account_dto.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AccountManagementBloc>().add(LoadAccountsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            BlocConsumer<AccountManagementBloc, AccountManagementState>(
              listener: (context, state) {
                if (state is AccountManagementActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is AccountManagementActionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AccountManagementLoading ||
                    state is AccountManagementActionLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is AccountManagementError) {
                  return Expanded(child: _buildErrorView(state.message));
                } else if (state is AccountManagementLoaded) {
                  return Expanded(
                    child: Column(
                      children: [
                        _buildFiltersAndSearch(state),
                        const SizedBox(height: 16),
                        _buildStatsCards(state),
                        const SizedBox(height: 16),
                        Expanded(child: _buildAccountsList(state)),
                        const SizedBox(height: 16),
                        _buildPagination(state),
                      ],
                    ),
                  );
                } else if (state is AccountManagementActionSuccess ||
                    state is AccountManagementActionError) {
                  // Đợi trạng thái Loaded tiếp theo
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.account_circle, color: Colors.blue[600], size: 28),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý tài khoản',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Quản lý tài khoản người dùng và bác sĩ trong hệ thống',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {
            context.read<AccountManagementBloc>().add(RefreshAccountsEvent());
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Làm mới'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersAndSearch(AccountManagementLoaded state) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, email, số điện thoại...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                context.read<AccountManagementBloc>().add(
                  SearchAccountsEvent(value),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: state.roleFilter,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Lọc theo vai trò'),
              ),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Tất cả'),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'DOCTOR',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Bác sĩ'),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'USER',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Khách hàng'),
                  ),
                ),
              ],
              onChanged: (value) {
                context.read<AccountManagementBloc>().add(
                  FilterAccountsByRoleEvent(value),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: state.statusFilter,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Lọc theo trạng thái'),
              ),
              items: const [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Tất cả'),
                  ),
                ),
                DropdownMenuItem<int?>(
                  value: 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Đang hoạt động'),
                  ),
                ),
                DropdownMenuItem<int?>(
                  value: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Ngưng hoạt động'),
                  ),
                ),
              ],
              onChanged: (value) {
                context.read<AccountManagementBloc>().add(
                  FilterAccountsByStatusEvent(value),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showCreateDoctorDialog(),
          icon: const Icon(Icons.person_add),
          label: const Text('Thêm bác sĩ'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(AccountManagementLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tổng tài khoản',
            state.totalItems.toString(),
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Bác sĩ',
            state.doctorCount.toString(),
            Icons.medical_services,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Khách hàng',
            state.customerCount.toString(),
            Icons.person,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Đang hoạt động',
            state.activeCount.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Ngưng hoạt động',
            state.inactiveCount.toString(),
            Icons.block,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAccountsList(AccountManagementLoaded state) {
    if (state.currentAccounts.isEmpty) {
      return _buildEmptyView();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: state.currentAccounts.length,
              itemBuilder: (context, index) {
                final account = state.currentAccounts[index];
                return _buildAccountRow(account, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Không có tài khoản nào',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi bộ lọc hoặc thêm tài khoản mới',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Thông tin tài khoản',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Email',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Vai trò',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Trạng thái',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 120),
        ],
      ),
    );
  }

  Widget _buildAccountRow(AccountDto account, int index) {
    final isEven = index % 2 == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey[25] : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.user.fullname!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  account.user.phoneNumber,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (account.user.address!.isNotEmpty)
                  Text(
                    account.user.address!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(account.user.email!)),
          Expanded(flex: 1, child: _buildRoleChip(account.role)),
          Expanded(flex: 1, child: _buildStatusChip(account.status)),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showStatusUpdateDialog(account),
                  icon: Icon(
                    account.status == 1 ? Icons.block : Icons.check_circle,
                    color:
                        account.status == 1
                            ? Colors.red[600]
                            : Colors.green[600],
                  ),
                  tooltip: account.status == 1 ? 'Vô hiệu hóa' : 'Kích hoạt',
                ),
                IconButton(
                  onPressed: () => _showAccountDetails(account),
                  icon: Icon(Icons.info, color: Colors.blue[600]),
                  tooltip: 'Xem chi tiết',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    Color color;
    String text;

    switch (role) {
      case 'DOCTOR':
        color = Colors.green;
        text = 'Bác sĩ';
        break;
      case 'USER':
        color = Colors.blue;
        text = 'Khách hàng';
        break;
      default:
        color = Colors.grey;
        text = role;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    Color color = status == 1 ? Colors.green : Colors.red;
    String text = status == 1 ? 'Hoạt động' : 'Ngưng';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPagination(AccountManagementLoaded state) {
    if (state.totalPages <= 1) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Trang ${state.currentPage + 1} / ${state.totalPages}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    state.currentPage > 0
                        ? () => context.read<AccountManagementBloc>().add(
                          ChangePaginationEvent(state.currentPage - 1),
                        )
                        : null,
                icon: const Icon(Icons.chevron_left),
              ),
              ...List.generate(state.totalPages.clamp(0, 5), (index) {
                final page = index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap:
                        () => context.read<AccountManagementBloc>().add(
                          ChangePaginationEvent(page),
                        ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            state.currentPage == page
                                ? Colors.blue[600]
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${page + 1}',
                        style: TextStyle(
                          color:
                              state.currentPage == page
                                  ? Colors.white
                                  : Colors.grey[600],
                          fontWeight:
                              state.currentPage == page
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              IconButton(
                onPressed:
                    state.currentPage < state.totalPages - 1
                        ? () => context.read<AccountManagementBloc>().add(
                          ChangePaginationEvent(state.currentPage + 1),
                        )
                        : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<AccountManagementBloc>().add(LoadAccountsEvent());
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _showCreateDoctorDialog() {
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final birthdayController = TextEditingController();

    // Giới tính mặc định là nam (1)
    int selectedGender = 1;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thêm tài khoản bác sĩ'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: birthdayController,
                      decoration: const InputDecoration(
                        labelText: 'Ngày sinh (YYYY-MM-DD)',
                        border: OutlineInputBorder(),
                        hintText: 'Ví dụ: 1990-01-01',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Giới tính:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        Radio<int>(
                          value: 1,
                          groupValue: selectedGender,
                          onChanged: (value) {
                            if (value != null) {
                              selectedGender = value;
                              (context as Element).markNeedsBuild();
                            }
                          },
                        ),
                        const Text('Nam'),
                        const SizedBox(width: 16),
                        Radio<int>(
                          value: 0,
                          groupValue: selectedGender,
                          onChanged: (value) {
                            if (value != null) {
                              selectedGender = value;
                              (context as Element).markNeedsBuild();
                            }
                          },
                        ),
                        const Text('Nữ'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (emailController.text.isNotEmpty &&
                      fullNameController.text.isNotEmpty &&
                      phoneController.text.isNotEmpty &&
                      addressController.text.isNotEmpty) {
                    // Xử lý ngày sinh (nếu có)
                    String? birthday;
                    if (birthdayController.text.isNotEmpty) {
                      birthday = birthdayController.text.trim();
                    }

                    // Gọi API để tạo tài khoản bác sĩ
                    context.read<AccountManagementBloc>().add(
                      CreateDoctorAccountEvent(
                        email: emailController.text.trim(),
                        fullName: fullNameController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        address: addressController.text.trim(),
                        birthday: birthday,
                        gender: selectedGender,
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    // Hiển thị thông báo lỗi nếu thiếu thông tin
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng điền đầy đủ thông tin'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Tạo tài khoản'),
              ),
            ],
          ),
    );
  }

  void _showStatusUpdateDialog(AccountDto account) {
    final newStatus = account.status == 1 ? 0 : 1;
    final statusText = newStatus == 1 ? 'kích hoạt' : 'vô hiệu hóa';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${statusText.toUpperCase()} tài khoản'),
            content: Text(
              'Bạn có chắc chắn muốn $statusText tài khoản của ${account.user.fullname}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AccountManagementBloc>().add(
                    UpdateAccountStatusEvent(
                      accountId: account.id!,
                      status: newStatus,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text(statusText.toUpperCase()),
              ),
            ],
          ),
    );
  }

  void _showAccountDetails(AccountDto account) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Chi tiết tài khoản - ${account.user.fullname}'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Email', account.user.email!),
                  _buildDetailRow('Số điện thoại', account.user.phoneNumber),
                  _buildDetailRow('Địa chỉ', account.user.address!),
                  _buildDetailRow(
                    'Vai trò',
                    account.role == 'DOCTOR' ? 'Bác sĩ' : 'Khách hàng',
                  ),
                  _buildDetailRow(
                    'Trạng thái',
                    account.status == 1 ? 'Đang hoạt động' : 'Ngưng hoạt động',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
