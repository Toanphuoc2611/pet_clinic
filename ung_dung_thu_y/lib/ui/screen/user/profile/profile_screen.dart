import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_bloc.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_state.dart';
import 'package:ung_dung_thu_y/bloc/user/user_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user/user_event.dart';
import 'package:ung_dung_thu_y/bloc/user/user_state.dart';
import 'package:ung_dung_thu_y/bloc/user_credit/user_credit_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user_credit/user_credit_event.dart';
import 'package:ung_dung_thu_y/bloc/user_credit/user_credit_state.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common/format_date.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(UserGetStarted());
    context.read<InvoiceDepositBloc>().add(InvoiceDepositGetStarted());
    context.read<UserCreditBloc>().add(UserCreditGetStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Settings or notifications
            },
            icon: Icon(Icons.settings_outlined, color: TColor.primary),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<UserBloc>().add(UserGetStarted());
          context.read<InvoiceDepositBloc>().add(InvoiceDepositGetStarted());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Profile header
              _buildProfileHeader(),

              // Balance card
              _buildBalanceCard(),

              // Quick actions
              _buildQuickActions(),

              // Recent invoices
              _buildRecentInvoices(),

              // Menu items
              _buildMenuItems(),

              // Logout button
              _buildLogoutButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColor.primary, TColor.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TColor.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return switch (state) {
            UserGetSuccess() => _buildUserInfo(state.userGetDto),
            UserGetInProgress() => _buildLoadingProfile(),
            _ => _buildErrorProfile(),
          };
        },
      ),
    );
  }

  Widget _buildUserInfo(UserGetDto user) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                context.push(RouteName.updateInfo, extra: user);
              },
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: FadeInImage.assetNetwork(
                        placeholder: "assets/image/avatar_default.jpg",
                        image:
                            user.avatar ??
                            "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678194/avatar_default_a1gudv.jpg",
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/image/avatar_default.jpg",
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: TColor.primary, width: 2),
                      ),
                      child: Icon(Icons.edit, color: TColor.primary, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullname ?? "Người dùng",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phoneNumber ?? "Chưa cập nhật số điện thoại",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Thành viên',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingProfile() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white24,
          child: CircularProgressIndicator(color: Colors.white),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Đang tải...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Thông tin người dùng",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorProfile() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white24,
          child: Icon(Icons.error, color: Colors.white, size: 40),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lỗi tải dữ liệu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Không thể tải thông tin người dùng",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Số dư tài khoản",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  BlocBuilder<UserCreditBloc, UserCreditState>(
                    builder: (context, state) {
                      return switch (state) {
                        UserCreditGetInProgress() => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        UserCreditGetSuccess() => Text(
                          '${NumberFormat('#,###').format(state.userCredits.balance)} VNĐ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        _ => const Text(
                          "0 VNĐ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      };
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thao tác nhanh',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Đặt chuồng',
                  Icons.home_outlined,
                  Colors.blue,
                  () => context.push(RouteName.bookKennel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Lịch sử chuồng',
                  Icons.history_outlined,
                  Colors.green,
                  () => context.push(RouteName.historyKennel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Hóa đơn',
                  Icons.receipt_long_outlined,
                  Colors.orange,
                  () {
                    context.push(RouteName.invoice);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Bệnh án',
                  Icons.medical_services_outlined,
                  Colors.purple,
                  () {
                    // Navigate to medical records
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInvoices() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hóa đơn gần đây',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: TColor.primaryText,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push(RouteName.invoice);
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(color: TColor.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<InvoiceDepositBloc, InvoiceDepositState>(
            builder: (context, state) {
              return switch (state) {
                InvoiceDepositGetStartedInProgress() => const Center(
                  child: CircularProgressIndicator(),
                ),
                InvoiceDepositGetStartedSuccess() => _buildInvoicesList(
                  state.lists,
                ),
                _ => _buildEmptyInvoices(),
              };
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList(List<InvoiceDepositDto> invoices) {
    if (invoices.isEmpty) {
      return _buildEmptyInvoices();
    }

    return Column(
      children:
          invoices.take(3).map((invoice) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        FormatDate.formatDate(invoice.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  _buildStatusChip(_getStatusText(invoice.status)),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEmptyInvoices() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Chưa có hóa đơn nào',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDivider(),
          _buildMenuItem('Cài đặt thông báo', Icons.notifications_outlined, () {
            // Navigate to notification settings
          }),
          _buildDivider(),
          _buildMenuItem('Hỗ trợ khách hàng', Icons.help_outline, () {
            // Navigate to support
          }),
          _buildDivider(),
          _buildMenuItem('Điều khoản sử dụng', Icons.description_outlined, () {
            // Navigate to terms
          }),
          _buildDivider(),
          _buildMenuItem('Về ứng dụng', Icons.info_outline, () {
            // Navigate to about
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: TColor.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: TColor.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.grey[200], height: 1),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutDialog();
        },
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Đăng xuất',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận đăng xuất',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutStarted());
                context.go(RouteName.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return "Chưa thanh toán";
      case 1:
        return "Đã thanh toán";
      case 2:
        return "Đã hủy";
      default:
        return "Không xác định";
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'hoàn thành':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green;
        break;
      case 'chưa thanh toán':
        backgroundColor = Colors.red[50]!;
        textColor = Colors.grey;
        break;
      case 'Đã hủy':
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red;
        break;
      case 'đã thanh toán':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
