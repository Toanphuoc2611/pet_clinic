import 'package:admin/bloc/log_user_credit/log_user_credit_bloc.dart';
import 'package:admin/bloc/log_user_credit/log_user_credit_event.dart';
import 'package:admin/bloc/log_user_credit/log_user_credit_state.dart';
import 'package:admin/bloc/user/user_bloc.dart';
import 'package:admin/bloc/user/user_event.dart';
import 'package:admin/bloc/user/user_state.dart';
import 'package:admin/bloc/pet/pet_bloc.dart';
import 'package:admin/bloc/pet/pet_event.dart';
import 'package:admin/bloc/pet/pet_state.dart';
import 'package:admin/dto/user/user_response.dart';
import 'package:admin/dto/pet/pet_get_dto.dart';
import 'package:admin/mixins/search_pagination_mixin.dart';
import 'package:admin/widgets/search_widget.dart';
import 'package:admin/widgets/pagination_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SearchPaginationMixin {
  List<UserResponse> _allUsers = [];
  List<UserResponse> _filteredUsers = [];
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(UserGetCustomerStarted());
  }

  // Implement required methods from SearchPaginationMixin
  @override
  void onSearchChanged(String query) {
    _applyFilters();
  }

  @override
  void onPageChanged(int page) {
    // Pagination is handled in UI
  }

  @override
  void onItemsPerPageChanged(int itemsPerPage) {
    // Pagination is handled in UI
  }

  @override
  void onSearchCleared() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = applySearch<UserResponse>(_allUsers, (user, query) {
        final fullname = user.user.fullname?.toLowerCase() ?? '';
        final phoneNumber = user.user.phoneNumber.toLowerCase();
        final address = user.user.address?.toLowerCase() ?? '';

        return fullname.contains(query) ||
            phoneNumber.contains(query) ||
            address.contains(query);
      });
      setTotalItems(_filteredUsers.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SearchWidget(
                hintText: 'Tìm kiếm theo tên, số điện thoại, địa chỉ...',
                onSearchChanged: setSearchQuery,
                onClear: clearSearch,
              ),
              const Spacer(),
              Text(
                'Tổng: ${totalItems} khách hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserGetCustomerInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UserGeCustomerSuccess) {
                  // Cập nhật dữ liệu khi có thay đổi
                  if (_allUsers != state.customers) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _allUsers = state.customers;
                        _applyFilters();
                      });
                    });
                  }
                  return _buildUserListWithPagination();
                } else if (state is UserGetCustomerFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${state.message}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<UserBloc>().add(
                              UserGetCustomerStarted(),
                            );
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('Không có dữ liệu'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListWithPagination() {
    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy khách hàng nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final paginatedUsers = applyPagination<UserResponse>(_filteredUsers);

    return Column(
      children: [
        Expanded(child: _buildUserList(paginatedUsers)),
        if (totalPages > 1)
          PaginationWidget(
            currentPage: currentPage,
            totalPages: totalPages,
            totalItems: totalItems,
            itemsPerPage: itemsPerPage,
            onPageChanged: setCurrentPage,
            onItemsPerPageChanged: setItemsPerPage,
          ),
      ],
    );
  }

  Widget _buildUserList(List<UserResponse> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text('Không có khách hàng nào', style: TextStyle(fontSize: 16)),
      );
    }

    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Tên khách hàng',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Số điện thoại',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Giới tính',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Số dư',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Hành động',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userResponse = users[index];
                final user = userResponse.user;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullname ?? 'Chưa có tên',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (user.address != null)
                              Text(
                                user.address!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Text(user.phoneNumber)),
                      Expanded(
                        flex: 1,
                        child: Text(_getGenderText(user.gender)),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap:
                              () => _showLogUserCreditDialog(
                                context,
                                user.id,
                                user.fullname ?? 'Khách hàng',
                              ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                              ).format(userResponse.balance),
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.pets, color: Colors.blue),
                              onPressed:
                                  () => _showUserPets(
                                    context,
                                    user.id,
                                    user.fullname ?? 'Khách hàng',
                                  ),
                              tooltip: 'Xem thú cưng',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.history,
                                color: Colors.green,
                              ),
                              onPressed:
                                  () => _showLogUserCreditDialog(
                                    context,
                                    user.id,
                                    user.fullname ?? 'Khách hàng',
                                  ),
                              tooltip: 'Lịch sử giao dịch',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getGenderText(int? gender) {
    switch (gender) {
      case 0:
        return 'Nữ';
      case 1:
        return 'Nam';
      default:
        return 'Khác';
    }
  }

  void _showUserPets(BuildContext context, String userId, String userName) {
    // Gọi API để lấy danh sách pet
    context.read<PetBloc>().add(PetGetByUserIdStarted(userId));

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: 900,
              height: 700,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thú cưng của $userName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: BlocBuilder<PetBloc, PetState>(
                      builder: (context, state) {
                        if (state is PetGetInProgress) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is PetGetByUserIdSuccess) {
                          return _buildPetList(state.petList);
                        } else if (state is PetGetFailure) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Lỗi: ${state.message}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<PetBloc>().add(
                                      PetGetByUserIdStarted(userId),
                                    );
                                  },
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          );
                        }
                        return const Center(
                          child: Text('Chưa có dữ liệu thú cưng'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildPetList(List<PetGetDto> pets) {
    if (pets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Người dùng này chưa có thú cưng nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Tên thú cưng',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Loại',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Giống',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Giới tính',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Cân nặng',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            if (pet.birthday != null)
                              Text(
                                'Sinh: ${pet.birthday}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(flex: 1, child: Text(pet.type ?? 'Chưa có')),
                      Expanded(flex: 1, child: Text(pet.breed ?? 'Chưa có')),
                      Expanded(
                        flex: 1,
                        child: Text(_getPetGenderText(pet.gender)),
                      ),
                      Expanded(flex: 1, child: Text('${pet.weight} kg')),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getPetGenderText(int gender) {
    switch (gender) {
      case 0:
        return 'Đực';
      case 1:
        return 'Cái';
      default:
        return 'Khác';
    }
  }

  void _showUserDetails(BuildContext context, UserResponse userResponse) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Chi tiết khách hàng: ${userResponse.user.fullname ?? 'Chưa có tên'}',
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('ID', userResponse.user.id),
                  _buildDetailRow(
                    'Họ tên',
                    userResponse.user.fullname ?? 'Chưa có',
                  ),
                  _buildDetailRow(
                    'Số điện thoại',
                    userResponse.user.phoneNumber,
                  ),
                  _buildDetailRow(
                    'Ngày sinh',
                    userResponse.user.birthday ?? 'Chưa có',
                  ),
                  _buildDetailRow(
                    'Giới tính',
                    _getGenderText(userResponse.user.gender),
                  ),
                  _buildDetailRow(
                    'Địa chỉ',
                    userResponse.user.address ?? 'Chưa có',
                  ),
                  _buildDetailRow(
                    'Số dư',
                    NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: '₫',
                    ).format(userResponse.balance),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showLogUserCreditDialog(
    BuildContext context,
    String userId,
    String userName,
  ) {
    context.read<LogUserCreditBloc>().add(
      LogUserCreditGetByUserIdStarted(userId),
    );

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: 800,
              height: 600,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lịch sử giao dịch - $userName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: BlocBuilder<LogUserCreditBloc, LogUserCreditState>(
                      builder: (context, state) {
                        if (state is LogUserCreditGetInProgress) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is LogUserCreditGetByUserIdSuccess) {
                          if (state.logList.isEmpty) {
                            return const Center(
                              child: Text('Không có lịch sử giao dịch'),
                            );
                          }
                          return ListView.builder(
                            itemCount: state.logList.length,
                            itemBuilder: (context, index) {
                              final log = state.logList[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getActionColor(
                                      log.action,
                                    ),
                                    child: Icon(
                                      _getActionIcon(log.action),
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(log.content),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Hành động: ${log.action}'),
                                      Text(
                                        'Thời gian: ${_formatDateTime(log.createdAt)}',
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Trước: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(log.balanceCurr)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Sau: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(log.balanceAfter)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (state is LogUserCreditGetFailure) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text('Lỗi: ${state.message}'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<LogUserCreditBloc>().add(
                                      LogUserCreditGetByUserIdStarted(userId),
                                    );
                                  },
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          );
                        }
                        return const Center(child: Text('Không có dữ liệu'));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'deposit':
      case 'nạp tiền':
        return Colors.green;
      case 'withdraw':
      case 'rút tiền':
        return Colors.red;
      case 'payment':
      case 'thanh toán':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'Hoàn tiền':
        return Icons.add;
      case 'Thanh toán':
        return Icons.payment;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}
